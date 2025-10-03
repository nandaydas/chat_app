// Importing project and package dependencies
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/firebase_api.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/routes/route_names.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Entry point of the application
Future<void> main() async {
  // Ensures Flutter bindings are initialized before using platform channels
  WidgetsFlutterBinding.ensureInitialized();

  // Loads environment variables from the .env file
  await dotenv.load(fileName: ".env");

  // Initializes Firebase with platform-specific options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initializes Firebase Cloud Messaging notifications
  await FirebaseApi().initNotifications();

  // Runs the main application widget
  runApp(const MyApp());
}

// Root widget of the application
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'JCF Communication', // App title
      debugShowCheckedModeBanner: false, // Hides the debug banner
      theme: ThemeData(
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.teal), // Sets color scheme
        appBarTheme: const AppBarTheme(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white), // AppBar styling
        scaffoldBackgroundColor:
            backgroundColor, // Background color for scaffold
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white), // FAB styling
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white), // Button styling
        ),
        useMaterial3: true, // Enables Material 3 design
      ),
      getPages: AppRoutes.appRoutes(), // Defines app routes for navigation
      initialRoute: RouteNames.splashScreen, // Sets initial route
    );
  }
}
