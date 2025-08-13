<<<<<<< HEAD
**TwendeBus: A Real-Time Bus Booking & Tracking Platform**

A complete, end-to-end bus booking application for both passengers and drivers, built with Flutter and Firebase. This platform provides a modern, Uber-like experience for public transport in Nairobi.
    
This repository contains the source code for the TwendeBus Passenger App. A separate branch exists for the TwendeBus Driver App.

**Table of Contents**

🚀 Features

🛠️ Technology Stack

📁 Project Structure

🔥 Getting Started

**Prerequisites**

1. Firebase Project Setup

2. API Keys & Credentials

3. Local Project Setup

4. Cloud Functions Setup

🏃‍♂️ Running the Applications

🛣️ Future Work

🚀 Features
**Passenger App (twende_bus_ui)**

Secure Authentication: Sign up and sign in with Email/Password or Google Sign-In.

Onboarding Logic: Onboarding screen is shown only once to new users.

Dynamic Home Screen: Displays live user data and a list of available routes from Firestore.

Route & Trip Discovery: Users can search for routes or select from a list to see available trips for a specific day.

Real-Time Seat Selection: A visual seat map shows booked, selected, and available seats in real-time.

Timed Seat Holding: A 3-minute hold is placed on selected seats to prevent double-booking while the user completes their purchase (backend logic for this is implemented).

Dynamic Points Selection: Users can select from a live list of boarding and deboarding points specific to their chosen route.

Wallet System: A fully functional in-app wallet for payments.

M-Pesa Integration:

Users can top up their wallet using a simulated M-Pesa STK Push.

Users can pay for bookings directly with M-Pesa.

Booking Management: A dedicated "Bookings" screen with "Active," "Completed," and "Cancelled" tabs showing a live list of the user's rides.

Real-Time Ride Tracking: A live map on the RideDetailsScreen shows the bus's location, which updates in real-time.

Profile Management: Users can edit their profile information and upload a profile picture to Firebase Storage.

Secure Cancellation: A backend-driven cancellation system that processes refunds to the user's wallet based on a time-based policy.

Notification System: A functional backend system to create notifications for key events like booking confirmation and cancellation.

Driver App (twende_bus_driver)

Secure Driver Login: A separate, simple login screen for users with a "driver" role.

Trip Dashboard: Displays the next scheduled trip assigned to the logged-in driver.

Live Location Broadcasting: On starting a trip, the app uses the phone's GPS to continuously update the bus's location in Firestore every 15 seconds.

Trip Management: Drivers can start and end trips, which updates the trip's status for all passengers in real-time.

🛠️ Technology Stack

Frontend: Flutter (Web & Android)

Backend & Database: Firebase

Authentication: For user management.

Firestore: As the primary NoSQL real-time database.

Cloud Functions (2nd Gen): For all secure backend logic (bookings, payments, cancellations).

Cloud Storage: For user profile pictures.

State Management: Flutter Riverpod

Payment Gateway: Safaricom Daraja API (Sandbox)

Mapping & Geolocation:

Google Maps Platform (Maps JavaScript API, Maps SDK for Android)

Flutter google_maps_flutter package

Flutter location package (for the Driver App)

Key Packages: image_picker, shared_preferences, intl, axios (in Cloud Functions).

📁 Project Structure

The project follows a feature-first architecture to keep the code organized and scalable.

code
Code
download
content_copy
expand_less

lib/
|-- core/               # Shared logic: models, services, providers, theme
|   |-- models/
|   |-- services/
|   |-- theme/
|   |-- providers.dart
|-- features/           # Each feature as a self-contained module
|   |-- auth/
|   |-- booking/
|   |-- home/
|   |-- profile/
|   |-- ... (etc.)
|-- shared/             # Reusable widgets (e.g., BottomNavBar)
|-- main.dart           # App entry point
🔥 Getting Started
Prerequisites

Flutter SDK installed.

Node.js and npm installed (for Firebase CLI).

A Firebase account.

A Safaricom Daraja Developer account.

1. Firebase Project Setup

Create Firebase Project: Go to the Firebase Console and create a new project.

Enable Services: In the "Build" section, enable Authentication (with Email/Password and Google providers), Firestore Database (start in test mode), and Cloud Storage (start in test mode).

Upgrade to Blaze Plan: To use Cloud Functions for external requests (like M-Pesa), you must upgrade your project to the Blaze (Pay as you go) plan. This has a generous free tier.

2. API Keys & Credentials

Google Maps API Key:

Go to the Google Cloud Console.

Ensure your Firebase project is selected.

Find the "Browser key (auto created by Firebase)".

Enable the Maps JavaScript API and Maps SDK for Android.

Restrict the key: Add application restrictions for "Websites" (localhost:* and your-project-id.firebaseapp.com) and for "Android apps" (using your package name and SHA-1 certificate).

Safaricom Daraja API Credentials:

Go to the Safaricom Developer Portal.

Create a new app, check the "Lipa Na M-PESA Sandbox" box, and get your Consumer Key and Consumer Secret.

Register Callback URLs: Go to the Lipa Na M-PESA API page and use the "Register URL" tool to register your callback URLs (e.g., https://us-central1-your-project-id.cloudfunctions.net/mpesaCallback).

3. Local Project Setup

Clone the Repository: git clone <repository_url>

Get Dependencies: flutter pub get

Install Firebase CLI: npm install -g firebase-tools

Install FlutterFire CLI: dart pub global activate flutterfire_cli

Configure Firebase: From the root of your project, run flutterfire configure and select your Firebase project and desired platforms (web, android).

4. Cloud Functions Setup

Initialize: From the root of your project, run firebase init functions. Choose JavaScript.

Install Dependencies: Navigate into the new functions folder (cd functions) and run npm install axios.

Add Credentials: Open functions/index.js and paste your Safaricom Consumer Key and Secret into the placeholder variables.

Deploy: From the root of your project, run firebase deploy --only functions.

🏃‍♂️ Running the Applications
Passenger App (twende_bus_ui)

To run the web version for development:

code
Bash
download
content_copy
expand_less
IGNORE_WHEN_COPYING_START
IGNORE_WHEN_COPYING_END
flutter run -d web-server

Copy the localhost URL into your Chrome browser.

Driver App (twende_bus_driver)

Connect a physical Android/iOS device or run an emulator.

code
Bash
download
content_copy
expand_less
IGNORE_WHEN_COPYING_START
IGNORE_WHEN_COPYING_END
flutter run
🛣️ Future Work

Implement the server-side "janitor" function to clean up expired temporary seat holds.

Build a full Admin Panel for managing routes, trips, drivers, and viewing analytics.

Integrate Firebase Cloud Messaging (FCM) for real-time push notifications.

Implement user reviews and ratings for drivers and trips.

Collect data and build AI/ML models for demand forecasting and dynamic pricing.
=======
# TwendeBus
>>>>>>> passenger/main
