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

//processing payment
exports.processWalletPayment = onCall(async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }

  const { bookingId } = request.data;
  const userId = request.auth.uid;
  
  const bookingRef = db.collection("bookings").doc(bookingId);
  const userRef = db.collection("users").doc(userId);

  return db.runTransaction(async (transaction) => {
    // 1. Get the current data for the user and the booking.
    const userDoc = await transaction.get(userRef);
    const bookingDoc = await transaction.get(bookingRef);

    if (!userDoc.exists) throw new HttpsError("not-found", "User not found.");
    if (!bookingDoc.exists) throw new HttpsError("not-found", "Booking not found.");

    const userData = userDoc.data();
    const bookingData = bookingDoc.data();

    // 2. Perform critical checks.
    if (bookingData.userId !== userId) {
      throw new HttpsError("permission-denied", "You can only pay for your own bookings.");
    }
    if (bookingData.status !== "pending") {
      throw new HttpsError("failed-precondition", "This booking is no longer pending payment.");
    }
    if (userData.walletBalance < bookingData.farePaid) {
      throw new HttpsError("failed-precondition", "Insufficient wallet balance.");
    }

    // 3. All checks passed. Perform the updates.
    // a. Deduct fare from user's wallet.
    const newBalance = userData.walletBalance - bookingData.farePaid;
    transaction.update(userRef, { walletBalance: newBalance });
    
    // b. Update the booking status to 'confirmed'.
    transaction.update(bookingRef, { status: "confirmed" });

    // c. Create a transaction record for their history.
    const transactionRef = db.collection("transactions").doc();
    transaction.set(transactionRef, {
      userId: userId,
      amount: -bookingData.farePaid,
      type: "deduction",
      details: `Payment for booking ${bookingId.substring(0, 5)}...`,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, message: "Payment successful." };
  });
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
    // Payment was successful. Confirm the booking.
    await bookingDoc.ref.update({ status: "confirmed" });
    logger.info(`Successfully confirmed booking ${bookingDoc.id} via M-Pesa.`);
  } else {
    // Payment failed. We can either mark it as 'failed' or let the janitor function handle it.
    // For simplicity, we'll let the janitor cancel it.
    logger.error("M-Pesa booking payment failed for:", checkoutRequestId, "Result code:", resultCode);
  }

  res.status(200).send("OK");
});