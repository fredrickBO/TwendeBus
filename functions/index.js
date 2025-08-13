const { onCall, onRequest, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

const mpesaCallbackURL = "https://us-central1-twendebus-app.cloudfunctions.net/mpesaCallback";
const corsOptions = { cors: true };


// --- A powerful, reusable helper function for M-Pesa STK Push ---
async function initiateStkPush(amount, phoneNumber, accountReference, transactionDesc, callbackURL) {
  const consumerKey = "h9IL64UUaapuOGO1AGe62dpiVqPZGG6SScKTGb1G0aJjqKhr";
  const consumerSecret = "xRyW5iliTfTTnX5oDuSiF5P3pQMj5POIR3oxr6BKOjGc3OqeWLesgJGDm4GRAwi4";
  const shortCode = 174379;
  const passkey = "bfb279f9aa9bdbcf158e97dd71a467cd2e0c893059b10f78e6b72ada1ed2c919";

  const auth = "Basic " + Buffer.from(consumerKey + ":" + consumerSecret).toString("base64");
  const tokenUrl = "https://sandbox.safaricom.co.ke/oauth/v1/generate?grant_type=client_credentials";

  let accessToken;
  try {
    const tokenResponse = await axios.get(tokenUrl, { headers: { Authorization: auth } });
    accessToken = tokenResponse.data.access_token;
  } catch (err) {
    logger.error("Failed to get M-Pesa token:", err.response ? err.response.data : err.message);
    throw new HttpsError("internal", "Could not get M-Pesa access token.");
  }

  const timestamp = new Date().toISOString().replace(/[^0-9]/g, "").slice(0, -3);
  const password = Buffer.from(shortCode + passkey + timestamp).toString("base64");
  const stkUrl = "https://sandbox.safaricom.co.ke/mpesa/stkpush/v1/processrequest";

  const stkPayload = {
    BusinessShortCode: shortCode, Password: password, Timestamp: timestamp,
    TransactionType: "CustomerPayBillOnline", Amount: amount, PartyA: phoneNumber,
    PartyB: shortCode, PhoneNumber: phoneNumber, CallBackURL: callbackURL,
    AccountReference: accountReference, TransactionDesc: transactionDesc,
  };

  logger.info("Sending STK Push with payload:", stkPayload);

  try {
    const stkResponse = await axios.post(stkUrl, stkPayload, { headers: { Authorization: `Bearer ${accessToken}` } });
    return stkResponse.data;
  } catch (err) {
    logger.error("STK Push failed:", err.response ? err.response.data : err.message);
    throw new HttpsError("internal", "Failed to initiate M-Pesa payment.");
  }
}


//helper function to create a notification
async function createNotification(userId, title, body) {
  if(!userId || !title || !body) {
    logger.error("Attempted to create notification with missing data:", { userId, title, body });

    return;
  }
  try {
    const notificationRef = db.collection("notifications");
    await notificationRef.add({
      userId: userId,
      title: title,
      body: body,
      isRead: false,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      read: false,
    });
    logger.info(`Notification created for user ${userId}: ${title}`);
  } catch (error) {
    logger.error("Error creating notification:", error);
    throw new HttpsError("internal", "Failed to create notification.");
  }
}


/**
 * Creates a new booking with a 'pending' status for 5 minutes and
 * immediately marks the seats as booked.
 */
exports.createPendingBooking = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }

  const { tripId, selectedSeats, startStop, endStop } = request.data;
  const userId = request.auth.uid;
  const tripRef = db.collection("trips").doc(tripId);

  return db.runTransaction(async (transaction) => {
    const tripDoc = await transaction.get(tripRef);
    if (!tripDoc.exists) throw new HttpsError("not-found", "Trip not found.");
    
    const tripData = tripDoc.data();
    
    // Check if any of the selected seats are already in the main bookedSeats list.
    for (const seat of selectedSeats) {
        if (tripData.bookedSeats && tripData.bookedSeats.includes(seat)) {
            throw new HttpsError("already-exists", `Seat ${seat} is already booked.`);
        }
    }
    
    // All seats are available.
    // THE NEW LOGIC: Add seats directly to the main bookedSeats list.
    transaction.update(tripRef, {
      bookedSeats: admin.firestore.FieldValue.arrayUnion(...selectedSeats),
      availableSeats: admin.firestore.FieldValue.increment(-selectedSeats.length),
    });

    // Create the booking document with 'pending' status.
    const bookingRef = db.collection("bookings").doc();
    const totalFare = tripData.fare * selectedSeats.length;
    transaction.set(bookingRef, {
      userId: userId,
      tripId: tripId,
      seatNumbers: selectedSeats,
      farePaid: totalFare,
      status: "pending",
      bookingTime: admin.firestore.FieldValue.serverTimestamp(),
      startStop: startStop,
      endStop: endStop,
    });

    return { success: true, bookingId: bookingRef.id };
  });
});

/**
 * A scheduled function that runs every 5 minutes to clean up expired pending bookings.
 */
exports.cancelExpiredBookings = onSchedule("every 5 minutes", async (event) => {
  logger.info("Running cancelExpiredBookings job.");
  
  // Get the timestamp for 5 minutes ago.
  const fiveMinutesAgo = new Date(Date.now() - 5 * 60 * 1000);

  // Find all pending bookings older than 5 minutes.
  const querySnapshot = await db.collection("bookings")
      .where("status", "==", "pending")
      .where("bookingTime", "<=", fiveMinutesAgo)
      .get();
  
  if (querySnapshot.empty) {
    logger.info("No expired bookings to cancel.");
    return null;
  }

  // Use a batch to perform all writes together for efficiency.
  const batch = db.batch();

  for (const doc of querySnapshot.docs) {
    const booking = doc.data();
    logger.info(`Cancelling expired booking ${doc.id} for user ${booking.userId}`);
    
    // 1. Mark the booking itself as 'cancelled'.
    batch.update(doc.ref, { status: "cancelled" });

    // 2. Find the associated trip and return the seats.
    const tripRef = db.collection("trips").doc(booking.tripId);
    batch.update(tripRef, {
      bookedSeats: admin.firestore.FieldValue.arrayRemove(...booking.seatNumbers),
      availableSeats: admin.firestore.FieldValue.increment(booking.seatNumbers.length),
    });
  }

  await batch.commit();
  logger.info(`Cancelled ${querySnapshot.size} expired bookings.`);
  return null;
});


// --- THIS IS THE CORRECTED FUNCTION ---
exports.processWalletPayment = onCall(corsOptions, async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Authentication required.");

  const { bookingId } = request.data;
  const userId = request.auth.uid;
  
  const bookingRef = db.collection("bookings").doc(bookingId);
  const userRef = db.collection("users").doc(userId);

  try {
    await db.runTransaction(async (transaction) => {
      const userDoc = await transaction.get(userRef);
      const bookingDoc = await transaction.get(bookingRef);

      if (!userDoc.exists) throw new HttpsError("not-found", "User not found.");
      if (!bookingDoc.exists) throw new HttpsError("not-found", "Booking not found.");

      const userData = userDoc.data();
      const bookingData = bookingDoc.data();

      if (bookingData.userId !== userId) throw new HttpsError("permission-denied", "You can only pay for your own bookings.");
      if (bookingData.status !== "pending") throw new HttpsError("failed-precondition", "This booking is no longer pending payment.");
      if (userData.walletBalance < bookingData.farePaid) throw new HttpsError("failed-precondition", "Insufficient wallet balance.");

      const newBalance = userData.walletBalance - bookingData.farePaid;
      transaction.update(userRef, { walletBalance: newBalance });
      transaction.update(bookingRef, { status: "confirmed" });

      const transactionRef = db.collection("transactions").doc();
      transaction.set(transactionRef, {
        userId: userId,
        amount: -bookingData.farePaid,
        type: "deduction",
        details: `Payment for booking ${bookingId.substring(0, 5)}...`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    // THE FIX: The transaction is complete and successful.
    // Now, we can create the notification and return the success message.
    await createNotification(
      userId,
      "Booking Confirmed!",
      `Your payment was successful and your booking is confirmed.`
    );

    return { success: true, message: "Payment successful." };

  } catch (error) {
    logger.error("Error processing wallet payment:", error);
    // Re-throw the error so the client app knows something went wrong.
    if (error instanceof HttpsError) {
      throw error;
    } else {
      throw new HttpsError("internal", "An unexpected error occurred during payment.");
    }
  }
});

// --- M-PESA TOP-UP FUNCTION (Now uses the helper) ---
exports.initiateMpesaTopUp = onCall(corsOptions, async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Authentication required.");

  const { amount, phoneNumber } = request.data;
  if (!amount || !phoneNumber || amount <= 0) throw new HttpsError("invalid-argument", "Valid amount and phone number are required.");

  const callbackURL = "https://us-central1-twendebus-app.cloudfunctions.net/mpesaTopUpCallback";
  const stkResponse = await initiateStkPush(amount, phoneNumber, "TwendeBusTopUp", "Wallet Top Up", callbackURL);
  
  const { MerchantRequestID, CheckoutRequestID, ResponseCode } = stkResponse;
  if (ResponseCode === "0" || ResponseCode === 0) {
    const transactionRef = db.collection("transactions").doc(CheckoutRequestID);
    await transactionRef.set({
      userId: request.auth.uid, amount, phoneNumber, status: "pending", type: "deposit",
      checkoutRequestId: CheckoutRequestID, merchantRequestId: MerchantRequestID,
      timestamp: admin.firestore.FieldValue.serverTimestamp(), details: "Wallet Top Up via M-Pesa",
    });
    return { success: true, message: "Request sent. Please check your phone." };
  } else {
    throw new HttpsError("internal", stkResponse.ResponseDescription || "Unknown M-Pesa error");
  }
});

// --- M-PESA wallet top up CALLBACK FUNCTION (This will now work) ---
exports.mpesaCallback = onRequest(corsOptions, async (req, res) => {
  logger.info("M-Pesa Callback received:", req.body);
  if (!req.body || !req.body.Body || !req.body.Body.stkCallback) {
    logger.error("Invalid callback format received.");
    res.status(200).send("OK");
    return;
  }
  const callbackData = req.body.Body.stkCallback;
  const resultCode = callbackData.ResultCode;
  const checkoutRequestId = callbackData.CheckoutRequestID;
  const transactionRef = db.collection("transactions").doc(checkoutRequestId);
  const transactionDoc = await transactionRef.get();
  if (!transactionDoc.exists) {
    logger.error("Callback for unknown transaction received:", checkoutRequestId);
    res.status(200).send("OK");
    return;
  }
  if (resultCode === 0) {
    const transactionData = transactionDoc.data();
    const userId = transactionData.userId;
    const amount = transactionData.amount;
    const userRef = db.collection("users").doc(userId);
    await db.runTransaction(async (transaction) => {
      transaction.update(transactionRef, { status: "completed" });
      transaction.update(userRef, { walletBalance: admin.firestore.FieldValue.increment(amount) });
    });
    logger.info(`Successfully updated wallet for user ${userId} with amount ${amount}.`);
  } else {
    await transactionRef.update({ status: "failed", resultCode: resultCode });
    logger.error("M-Pesa transaction failed for:", checkoutRequestId, "Result code:", resultCode);
  }
  res.status(200).send("OK");
});

// --- M-PESA BOOKING PAYMENT FUNCTION (Now uses the helper) ---
exports.initiateMpesaBookingPayment = onCall(corsOptions, async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Authentication required.");

  const { bookingId, phoneNumber } = request.data;
  if (!bookingId || !phoneNumber) throw new HttpsError("invalid-argument", "Valid bookingId and phoneNumber are required.");
  
  const bookingRef = db.collection("bookings").doc(bookingId);
  const bookingDoc = await bookingRef.get();
  if (!bookingDoc.exists) throw new HttpsError("not-found", "Booking not found.");
  if (bookingDoc.data().userId !== request.auth.uid) throw new HttpsError("permission-denied", "You can only pay for your own bookings.");

  const amount = bookingDoc.data().farePaid;
  const callbackURL = "https://us-central1-twendebus-app.cloudfunctions.net/mpesaBookingCallback";
  const stkResponse = await initiateStkPush(amount, phoneNumber, `Booking ${bookingId.substring(0,5)}`, "Bus Booking Payment", callbackURL);
  
  const { MerchantRequestID, CheckoutRequestID, ResponseCode } = stkResponse;
  if (ResponseCode === "0" || ResponseCode === 0) {
    await bookingRef.update({
      mpesaCheckoutRequestId: CheckoutRequestID, mpesaMerchantRequestId: MerchantRequestID,
    });
    return { success: true, message: "Request sent. Please check your phone." };
  } else {
    throw new HttpsError("internal", stkResponse.ResponseDescription || "Unknown M-Pesa error");
  }
});

// --- NEW CALLBACK FUNCTION for booking payments with direct mpesa---
exports.mpesaBookingCallback = onRequest(corsOptions, async (req, res) => {
  logger.info("M-Pesa Booking Callback received:", req.body);

  if (!req.body || !req.body.Body || !req.body.Body.stkCallback) {
    res.status(200).send("OK"); return;
  }
  const callbackData = req.body.Body.stkCallback;
  const resultCode = callbackData.ResultCode;
  const checkoutRequestId = callbackData.CheckoutRequestID;

  // Find the booking using the CheckoutRequestID.
  const bookingsQuery = db.collection("bookings").where("mpesaCheckoutRequestId", "==", checkoutRequestId);
  const querySnapshot = await bookingsQuery.get();

  if (querySnapshot.empty) {
    logger.error("Callback for unknown booking received:", checkoutRequestId);
    res.status(200).send("OK"); return;
  }
  
  const bookingDoc = querySnapshot.docs[0];

  if (resultCode === 0) {
    // Payment was successful. Confirm the booking AND create a notification.
    await bookingDoc.ref.update({ status: "confirmed" });
    const bookingData = bookingDoc.data();
    createNotification(
      bookingData.userId,
      "Booking Confirmed!",
      `Your M-Pesa payment was successful and your booking ${bookingDoc.id.substring(0,5)}... is confirmed.`
    );
    logger.info(`Successfully confirmed booking ${bookingDoc.id} via M-Pesa.`);
  } else {
    // Payment failed. We can either mark it as 'failed' or let the janitor function handle it.
    // For simplicity, we'll let the janitor cancel it.
    logger.error("M-Pesa booking payment failed for:", checkoutRequestId, "Result code:", resultCode);
  }

  res.status(200).send("OK");
});

// --- NEW FUNCTION for fetching directions from Google Maps API ---
exports.getDirections = onCall({ cors: true }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }

  const { originLat, originLng, destLat, destLng } = request.data;
  const apiKey = "AIzaSyCWr4Yme3_wAK0YAk--ekAQf6VDjRG_k0U"; // The same key you used in index.html

  const url = `https://maps.googleapis.com/maps/api/directions/json?origin=${originLat},${originLng}&destination=${destLat},${destLng}&key=${apiKey}`;

  try {
    const response = await axios.get(url);
    const data = response.data;

    if (data.status === 'OK') {
      const route = data.routes[0];
      const leg = route.legs[0];
      
      return {
        success: true,
        points: route.overview_polyline.points, // The encoded polyline
        durationText: leg.duration.text, // e.g., "5 mins"
        distanceText: leg.distance.text, // e.g., "1.2 km"
      };
    } else {
      throw new HttpsError("not-found", data.error_message || "Could not fetch directions.");
    }
  } catch (error) {
    logger.error("Directions API error:", error);
    throw new HttpsError("internal", "Failed to get directions from Google Maps API.");
  }
});

// --- NEW FUNCTION for cancelling a booking and processing refunds ---
exports.cancelBooking = onCall(corsOptions, async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Authentication required.");

  const { bookingId } = request.data;
  const userId = request.auth.uid;
  
  const bookingRef = db.collection("bookings").doc(bookingId);
  const userRef = db.collection("users").doc(userId);

  // Use a variable outside the transaction to store the refund amount.
  let refundAmount = 0;

  try {
    // Run the transaction to update the database.
    await db.runTransaction(async (transaction) => {
      const bookingDoc = await transaction.get(bookingRef);
      const userDoc = await transaction.get(userRef);

      if (!bookingDoc.exists) throw new HttpsError("not-found", "Booking not found.");
      if (bookingDoc.data().userId !== userId) throw new HttpsError("permission-denied", "You can only cancel your own bookings.");
      if (bookingDoc.data().status !== 'confirmed' && bookingDoc.data().status !== 'active') {
        throw new HttpsError("failed-precondition", "This booking cannot be cancelled.");
      }

      const bookingData = bookingDoc.data();
      const tripRef = db.collection("trips").doc(bookingData.tripId);
      const tripDoc = await transaction.get(tripRef);
      if (!tripDoc.exists) throw new HttpsError("not-found", "Associated trip not found.");
      
      const tripData = tripDoc.data();
      const userData = userDoc.data();
      
      const departureTime = tripData.departureTime.toDate();
      const now = new Date();
      const hoursDifference = (departureTime.getTime() - now.getTime()) / 3600000;

      // Calculate and store the refund amount.
      if (hoursDifference >= 5) refundAmount = bookingData.farePaid;
      else if (hoursDifference >= 1) refundAmount = bookingData.farePaid * 0.5;

      if (refundAmount > 0) {
        transaction.update(userRef, { walletBalance: admin.firestore.FieldValue.increment(refundAmount) });
        const transactionRef = db.collection("transactions").doc();
        transaction.set(transactionRef, {
          userId, amount: refundAmount, type: "refund",
          details: `Refund for booking ${bookingId.substring(0, 5)}...`,
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });
      }

      transaction.update(bookingRef, { status: "cancelled" });
      transaction.update(tripRef, {
        bookedSeats: admin.firestore.FieldValue.arrayRemove(...bookingData.seatNumbers),
        availableSeats: admin.firestore.FieldValue.increment(bookingData.seatNumbers.length),
      });
    });

    // THE FIX: The transaction is complete. Now we can safely create the notification.
    await createNotification(
      userId,
      "Booking Cancelled",
      `Your booking ${bookingId.substring(0,5)}... has been cancelled. Your refund of KES ${refundAmount.toFixed(2)} is being processed.`
    );

    // Finally, return the success message to the app.
    return { success: true, message: `Booking cancelled. A refund of KES ${refundAmount.toFixed(2)} has been processed to your wallet.` };

  } catch(error) {
    logger.error("Error in cancelBooking for booking:", bookingId, "Error:", error);
    if (error instanceof HttpsError) throw error;
    throw new HttpsError("internal", "An unexpected error occurred during cancellation.");
  }
});

// --- NEW FUNCTION for deleting notifications ---
exports.deleteNotifications = onCall(corsOptions, async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Authentication required.");

  const { notificationIds } = request.data;
  const userId = request.auth.uid;

  if (!notificationIds || !Array.isArray(notificationIds) || notificationIds.length === 0) {
    throw new HttpsError("invalid-argument", "A valid array of notificationIds is required.");
  }
  
  const batch = db.batch();
  const notificationsRef = db.collection("notifications");

  // We must verify ownership before deleting.
  for (const id of notificationIds) {
    const docRef = notificationsRef.doc(id);
    const doc = await docRef.get();
    if (doc.exists && doc.data().userId === userId) {
      batch.delete(docRef);
    } else {
      logger.warn(`User ${userId} attempted to delete unowned notification ${id}.`);
    }
  }

  await batch.commit();
  return { success: true, message: "Notifications deleted." };
});
exports.setAdminClaim = onRequest({ cors: true }, async (req, res) => {
  try {
    // THIS IS YOUR SPECIFIC USER UID
    const uidToMakeAdmin = "VchFNbvWUaV7Vij9bDPBLrS0Pb73";
    
    // This is the secure claim we are setting.
    const claims = { isAdmin: true };

    // This is the command that sets the claim on the server.
    await admin.auth().setCustomUserClaims(uidToMakeAdmin, claims);

    const successMessage = `Success! User with UID: ${uidToMakeAdmin} is now an admin. You can now log in to the admin panel. Please comment out or delete this function and redeploy for security.`;
    logger.info(successMessage);
    res.status(200).send(successMessage);

  } catch (error) {
    const errorMessage = `ERROR: Could not set admin claim. Reason: ${error.message}`;
    logger.error(errorMessage);
    res.status(500).send(errorMessage);
  }
});

// --- NEW FUNCTION for deleting a route ---
exports.deleteRoute = onCall(corsOptions, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  
  const userId = request.auth.uid;
  const { routeId } = request.data;
  
  // THE FIX: We will now check the user's role directly from the Firestore database.
  // This is the single source of truth and is always up-to-date.
  const userDoc = await db.collection('users').doc(userId).get();
  if (!userDoc.exists || userDoc.data().role !== 'admin') {
    throw new HttpsError("permission-denied", "You must be an admin to delete routes.");
  }

  // If the check passes, proceed with the deletion.
  if (!routeId) {
    throw new HttpsError("invalid-argument", "A valid routeId is required.");
  }

  try {
    await db.collection('routes').doc(routeId).delete();
    return { success: true, message: "Route deleted successfully." };
  } catch (error) {
    logger.error("Error deleting route:", error);
    throw new HttpsError("internal", "Could not delete route.");
  }
});

// --- NEW FUNCTION for changing a user's role ---
exports.changeUserRole = onCall({ cors: true }, async (request) => {
  // 1. Verify the caller is a super_admin.
  if (request.auth.token.role !== 'super_admin') {
    throw new HttpsError("permission-denied", "You must be a super admin to change roles.");
  }

  const { targetUid, newRole } = request.data;
  const allowedRoles = ['admin', 'support', 'driver', 'passenger'];

  if (!targetUid || !newRole || !allowedRoles.includes(newRole)) {
    throw new HttpsError("invalid-argument", "A valid target UID and role are required.");
  }
  
  try {
    // 2. Update the role in the user's Firestore document.
    await db.collection('users').doc(targetUid).update({ role: newRole });
    return { success: true, message: `User role updated to ${newRole}.` };
  } catch (error) {
    logger.error(`Failed to change role for user ${targetUid}`, error);
    throw new HttpsError("internal", "Could not update user role.");
  }
});

// --- NEW FUNCTION for creating staff users ---
exports.createStaffUser = onCall({ cors: true }, async (request) => {
  // 1. Security Check: Only a super_admin can call this function.
  if (request.auth.token.role !== 'super_admin') {
    throw new HttpsError("permission-denied", "You must be a super admin to create staff users.");
  }

  const { email, password, firstName, lastName, phoneNumber, role } = request.data;
  const allowedRoles = ['admin', 'support', 'driver'];

  if (!email || !password || !firstName || !lastName || !role) {
    throw new HttpsError("invalid-argument", "All fields are required.");
  }
  if (!allowedRoles.includes(role)) {
    throw new HttpsError("invalid-argument", "Invalid role specified.");
  }

  try {
    // 2. Create the user in Firebase Authentication.
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      displayName: `${firstName} ${lastName}`,
    });

    // 3. Create the user's profile document in Firestore with their role.
    await db.collection("users").doc(userRecord.uid).set({
      uid: userRecord.uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber || "",
      role: role,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      walletBalance: 0,
      notificationsEnabled: true,
    });

    return { success: true, message: `Successfully created ${role} user.` };

  } catch (error) {
    logger.error("Error creating staff user:", error);
    // Translate common auth errors into user-friendly messages
    if (error.code === 'auth/email-already-exists') {
        throw new HttpsError('already-exists', 'The email address is already in use by another account.');
    }
    throw new HttpsError("internal", "Could not create staff user.");
  }
});
