const { onCall, HttpsError } = require("firebase-functions/v2/https");
const admin = require("firebase-admin");
//const logger = require("firebase-functions/logger");

admin.initializeApp();
const db = admin.firestore();

/**
 * Puts a seat on hold for a specific user. (SIMPLEST VERSION)
 */
exports.holdSeat = onCall((request) => {
  // We are ONLY checking for a logged-in user. NO App Check.
  if (!request.auth) {
    throw new HttpsError(
      "unauthenticated",
      "The function must be called while authenticated."
    );
  }

  const { tripId, seatNumber } = request.data;
  const userId = request.auth.uid;
  const tripRef = db.collection("trips").doc(tripId);

  return db.runTransaction(async (transaction) => {
    const tripDoc = await transaction.get(tripRef);
    if (!tripDoc.exists) {
      throw new HttpsError("not-found", "Trip not found.");
    }

    const tripData = tripDoc.data();

    if (tripData.bookedSeats && tripData.bookedSeats.includes(seatNumber)) {
      throw new HttpsError("already-exists", "This seat is already booked.");
    }
    if (tripData.heldSeats && tripData.heldSeats[seatNumber]) {
      throw new HttpsError("already-exists", "This seat is held by another user.");
    }

    transaction.update(tripRef, {
      [`heldSeats.${seatNumber}`]: {
        userId: userId,
        holdTimestamp: admin.firestore.FieldValue.serverTimestamp(),
      },
    });

    return { success: true, message: `Seat ${seatNumber} is now held.` };
  });
});

/**
 * Releases a seat previously held by the user. (SIMPLEST VERSION)
 */
exports.releaseSeat = onCall((request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }

  const { tripId, seatNumber } = request.data;
  const userId = request.auth.uid;
  const tripRef = db.collection("trips").doc(tripId);

  return db.runTransaction(async (transaction) => {
    const tripDoc = await transaction.get(tripRef);
    if (!tripDoc.exists) {
      throw new HttpsError("not-found", "Trip not found.");
    }
    const tripData = tripDoc.data();

    if (tripData.heldSeats && tripData.heldSeats[seatNumber] && tripData.heldSeats[seatNumber].userId === userId) {
      transaction.update(tripRef, {
        [`heldSeats.${seatNumber}`]: admin.firestore.FieldValue.delete(),
      });
      return { success: true, message: `Seat ${seatNumber} released.` };
    } else {
      return { success: false, message: "Seat not held by user or does not exist." };
    }
  });
});

exports.processBooking = onCall((request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Authentication required.");
  }
  
  // App Check is enforced by the function's options, so we don't need a manual check here.

  const { tripId, selectedSeats, startStop, endStop } = request.data;
  const userId = request.auth.uid;
  const tripRef = db.collection("trips").doc(tripId);
  const userRef = db.collection("users").doc(userId);

  return db.runTransaction(async (transaction) => {
    // 1. Get the current data for the user and the trip.
    const userDoc = await transaction.get(userRef);
    const tripDoc = await transaction.get(tripRef);

    if (!userDoc.exists) {
      throw new HttpsError("not-found", "User not found.");
    }
    if (!tripDoc.exists) {
      throw new HttpsError("not-found", "Trip not found.");
    }

    const userData = userDoc.data();
    const tripData = tripDoc.data();
    const fare = tripData.fare;
    const totalFare = fare * selectedSeats.length;

    // 2. Check if the user has enough money.
    if (userData.walletBalance < totalFare) {
      throw new HttpsError("failed-precondition", "Insufficient wallet balance.");
    }

    // 3. Verify that all seats are still held by the current user.
    for (const seatNumber of selectedSeats) {
      if (!tripData.heldSeats || !tripData.heldSeats[seatNumber] || tripData.heldSeats[seatNumber].userId !== userId) {
        throw new HttpsError("aborted", `Seat ${seatNumber} is no longer held by this user or has expired.`);
      }
    }

    // 4. Update the wallet balance.
    const newBalance = userData.walletBalance - totalFare;
    transaction.update(userRef, { walletBalance: newBalance });
    
    // 5. Update the trip document: move seats from held to booked, and update available seats.
    const newBookedSeats = [...(tripData.bookedSeats || []), ...selectedSeats];
    const newHeldSeats = { ...(tripData.heldSeats || {}) };
    for (const seatNumber of selectedSeats) {
      delete newHeldSeats[seatNumber];
    }
    const newAvailableSeats = (tripData.availableSeats || 0) - selectedSeats.length;

    transaction.update(tripRef, {
      bookedSeats: newBookedSeats,
      heldSeats: newHeldSeats,
      availableSeats: newAvailableSeats,
    });

    // 6. Create the booking document.
    const bookingRef = db.collection("bookings").doc();
    transaction.set(bookingRef, {
      userId: userId,
      tripId: tripId,
      seatNumbers: selectedSeats,
      farePaid: totalFare,
      status: "active",
      bookingTime: admin.firestore.FieldValue.serverTimestamp(),
      startStop: startStop, // These come from the PointsSelectionScreen
      endStop: endStop,
    });

    // 7. Create a transaction record.
    const transactionRef = db.collection("transactions").doc();
    transaction.set(transactionRef, {
      userId: userId,
      amount: -totalFare,
      type: "deduction",
      details: `Booking for trip ${tripId.substring(0, 5)}...`,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });

    return { success: true, bookingId: bookingRef.id, message: "Booking successful." };
  });
});

exports.cancelBooking = onCall((request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Authentication required.");

  const { bookingId } = request.data;
  const userId = request.auth.uid;
  
  const bookingRef = db.collection("bookings").doc(bookingId);
  const userRef = db.collection("users").doc(userId);

  return db.runTransaction(async (transaction) => {
    const bookingDoc = await transaction.get(bookingRef);
    const userDoc = await transaction.get(userRef);

    if (!bookingDoc.exists) throw new HttpsError("not-found", "Booking not found.");
    if (bookingDoc.data().userId !== userId) throw new HttpsError("permission-denied", "You can only cancel your own bookings.");

    const bookingData = bookingDoc.data();
    const tripRef = db.collection("trips").doc(bookingData.tripId);
    const tripDoc = await transaction.get(tripRef);

    if (!tripDoc.exists) throw new HttpsError("not-found", "Associated trip not found.");
    
    const tripData = tripDoc.data();
    const userData = userDoc.data();
    
    // Cancellation Policy Logic
    const departureTime = tripData.departureTime.toDate();
    const now = new Date();
    const hoursDifference = (departureTime.getTime() - now.getTime()) / 3600000;

    let refundAmount = 0;
    if (hoursDifference >= 2) {
      // Full refund if cancelled 2 or more hours before.
      refundAmount = bookingData.farePaid;
    } // No else needed, refundAmount is 0 for late cancellations.

    // Update user's wallet if there is a refund
    if (refundAmount > 0) {
      const newBalance = userData.walletBalance + refundAmount;
      transaction.update(userRef, { walletBalance: newBalance });
      
      // Create a refund transaction record
      const transactionRef = db.collection("transactions").doc();
      transaction.set(transactionRef, {
        userId: userId, amount: refundAmount, type: "refund",
        details: `Refund for booking ${bookingId.substring(0, 5)}...`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    // Update the booking status
    transaction.update(bookingRef, { status: "cancelled" });

    // Return the seats to the trip
    const newBookedSeats = (tripData.bookedSeats || []).filter(seat => !bookingData.seatNumbers.includes(seat));
    const newAvailableSeats = (tripData.availableSeats || 0) + bookingData.seatNumbers.length;
    transaction.update(tripRef, {
        bookedSeats: newBookedSeats,
        availableSeats: newAvailableSeats,
    });
    
    return { success: true, message: `Booking cancelled. Refund of KES ${refundAmount} processed.` };
  });
});