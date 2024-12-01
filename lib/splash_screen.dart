import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'view/auth/login_page.dart';
import 'view/home/home_page.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    Future.delayed(
      const Duration(seconds: 1),
      () {
        if (_auth.currentUser != null) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => MyHomePage()));
        } else {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Mylogin()));
        }
      },
    );
    return Scaffold(
      body: Center(
        child: Image.asset(
          'images/jcf_communication_logo.png',
          height: 50,
          width: double.infinity,
        ),
      ),
    );
  }
}
