const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const logger = require("firebase-functions/logger");

admin.initializeApp();
const db = admin.firestore();

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