// Importing project and package dependencies
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/firebase_api.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/routes/route_names.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // --- Enable Edge-to-Edge Layout ---
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Make system bars transparent for immersive layout
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // Transparent status bar
    systemNavigationBarColor: Colors.transparent, // Transparent nav bar
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Icons for light backgrounds
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Lock app orientation (optional, can remove if not needed)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), // Color scheme
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0, // Make it flush with the system bar
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent, // Edge-to-edge status bar
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        scaffoldBackgroundColor: backgroundColor, // Scaffold background
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
        ),
        useMaterial3: true,
      ),
      getPages: AppRoutes.appRoutes(), // Defines app routes
      initialRoute: RouteNames.splashScreen, // Sets initial route
    );
  }
}
