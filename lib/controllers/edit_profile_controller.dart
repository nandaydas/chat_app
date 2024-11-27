import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  final RxString selectedGender = 'Male'.obs;
  XFile? image;
  final List<String> options = ['Male', 'Female', 'Other'];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void pickImage(BuildContext context) async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );
      if (pickedFile != null) {
        image = pickedFile;
      }
    } catch (e) {
      log(e.toString());
    }
  }

  RxBool isSaving = false.obs;

  void saveChanges(BuildContext context) async {
    log('Save Changes');
    try {
      isSaving.value = true;

      
      await _firestore.collection("Users").doc(_auth.currentUser!.uid).update(
        {
          'name': nameController.text,
          'phone': phoneController.text,
          'gender': selectedGender.value,
          'address': addressController.text
        },
      ).then(
        (_) {
          Fluttertoast.showToast(msg: 'Changes saved successfully ');
          isSaving.value = false;
          Navigator.pop(context);
        },
      );
    } catch (e) {
      log(e.toString());
    }
  }
}
