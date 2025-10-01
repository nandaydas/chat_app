import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/firebase_api.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/routes/route_names.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'routes/app_routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'JCF Communication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        appBarTheme: const AppBarTheme(
            backgroundColor: primaryColor, foregroundColor: Colors.white),
        scaffoldBackgroundColor: backgroundColor,
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: primaryColor, foregroundColor: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor, foregroundColor: Colors.white),
        ),
        useMaterial3: true,
      ),
      getPages: AppRoutes.appRoutes(),
      initialRoute: RouteNames.splashScreen,
    );
  }
}
