// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// //import 'package.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:twende_bus_ui/core/theme/app_theme.dart';
// import 'firebase_options.dart';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

//   await FirebaseAppCheck.instance.activate();

//   final prefs = await SharedPreferences.getInstance();
//   final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

//   runApp(ProviderScope(child: MyApp(hasSeenOnboarding: hasSeenOnboarding)));
// }

// class MyApp extends StatelessWidget {
//   final bool hasSeenOnboarding;
//   const MyApp({super.key, required this.hasSeenOnboarding});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'TwendeBus',
//       theme: getAppThemeData(),
//       home: AuthWrapper(hasSeenOnboarding: hasSeenOnboarding),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twende_bus_ui/core/theme/app_theme.dart';
import 'package:twende_bus_ui/features/auth/screens/auth_wrapper.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(ProviderScope(child: MyApp(hasSeenOnboarding: hasSeenOnboarding)));
}

class MyApp extends StatelessWidget {
  final bool hasSeenOnboarding;
  const MyApp({super.key, required this.hasSeenOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TwendeBus',
      theme: getAppThemeData(),
      home: AuthWrapper(hasSeenOnboarding: hasSeenOnboarding),
      debugShowCheckedModeBanner: false,
    );
  }
}
