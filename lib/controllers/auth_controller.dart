import 'dart:developer';
import 'package:chat_app/view/home/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../view/auth/login_page.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userImage = ''.obs;
  final RxString userPhone = ''.obs;
  final RxString userType = 'Client'.obs;
  final RxString userGender = ''.obs;
  final Rx<Timestamp> joinDate = Timestamp.now().obs;

  @override
  void onInit() {
    setActivityStatus();
    super.onInit();
  }

  void setActivityStatus() async {
    try {
      if (_auth.currentUser != null) {
        _firebaseFirestore
            .collection('Users')
            .doc(_auth.currentUser!.uid)
            .update(
          {
            'last_active': Timestamp.now(),
            'is_active': true,
          },
        );
        SystemChannels.lifecycle.setMessageHandler(
          (status) {
            log(status!);
            if (status.contains('inactive')) {
              _firebaseFirestore
                  .collection('Users')
                  .doc(_auth.currentUser!.uid)
                  .update(
                {
                  'last_active': Timestamp.now(),
                  'is_active': false,
                },
              );
            } else if (status.contains('resumed')) {
              _firebaseFirestore
                  .collection('Users')
                  .doc(_auth.currentUser!.uid)
                  .update(
                {
                  'last_active': Timestamp.now(),
                  'is_active': true,
                },
              );
            }
            return Future.value(status);
          },
        );
      }
    } catch (e) {
      e.toString();
    }
  }

  void getUserData() async {
    _firebaseFirestore
        .collection('Users')
        .doc(_auth.currentUser!.uid)
        .get()
        .then(
      (snapshot) {
        userName.value = snapshot.data()!['name'];
        userEmail.value = snapshot.data()!['email'];
        userImage.value = snapshot.data()!['image'];
        userPhone.value = snapshot.data()!['phone'];
        userType.value = snapshot.data()!['user_type'];
        joinDate.value = snapshot.data()!['joined'];
        userGender.value = snapshot.data()!['gender'];
      },
    );
  }

  void emailLogin(BuildContext context) async {
    try {
      await _auth
          .signInWithEmailAndPassword(
              email: emailController.text, password: passController.text)
          .then(
            (value) => {
              log("SignIn successful !"),
              emailController.clear(),
              passController.clear(),
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MyHomePage(),
                ),
              ),
            },
          );
    } catch (e) {
      log(e.toString());
      if (e.toString().contains('[firebase_auth/invalid-credential]')) {
        emailController.printError();
        passController.printError();
        Fluttertoast.showToast(msg: "Invalid Credential");
      } else if (e.toString().contains('[firebase_auth/invalid-email]')) {
        emailController.printError();
        Fluttertoast.showToast(msg: "Invalid Email");
      } else {
        log(e.toString());
      }
    }
  }

  void emailSignUp(BuildContext context) async {
    try {
      await _auth
          .createUserWithEmailAndPassword(
            email: emailController.text,
            password: passController.text,
          )
          .then(
            (value) => {
              _firebaseFirestore.collection("Users").doc(value.user!.uid).set(
                {
                  "id": value.user!.uid,
                  "name": nameController.text,
                  "email": emailController.text,
                  "phone": phoneController.text,
                  "image": '',
                  "signin_type": 'Email',
                  "user_type": userType.value,
                  "joined": Timestamp.now(),
                  "push_token": "",
                  "gender": "",
                  "address": "",
                  'last_active': Timestamp.now(),
                  'is_active': false,
                },
              )
            },
          );
      nameController.clear();
      phoneController.clear();
      emailController.clear();
      passController.clear();
      confirmPassController.clear();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MyHomePage(),
        ),
      );
    } catch (e) {
      log(e.toString());
      Fluttertoast.showToast(msg: e.toString().split('] ')[1]);
    }
  }

  void passwordReset(BuildContext context) async {
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text).then(
        (value) {
          log('PasswordReset Success !');
          Fluttertoast.showToast(msg: 'Email sent !');
          Navigator.pop(context);
        },
      );
    } catch (e) {
      log('PasswordReset Error $e');
      Fluttertoast.showToast(msg: e.toString().split('] ')[1]);
    }
  }

  void logOut(BuildContext context) async {
    try {
      await _auth.signOut().then(
        (value) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => Mylogin(),
            ),
          );
        },
      );
    } catch (e) {
      e.toString();
    }
  }
}
