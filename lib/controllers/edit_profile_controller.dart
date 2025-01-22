import 'dart:developer';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import "package:path/path.dart" as path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class EditProfileController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final RxString imgUrl = ''.obs;

  final RxString selectedGender = 'Male'.obs;
  XFile? image;
  final List<String> options = ['Male', 'Female', 'Other'];

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  File? imageFile;
  String fileName = "";
  final RxBool isImageUploading = false.obs;
  
  Future pickImage(String type) async {
    XFile? tempImage = await ImagePicker().pickImage(
      source: type == 'camera' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 30,
    );

    if (tempImage != null) {
      isImageUploading.value = true;

      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: tempImage.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      );

      fileName = path.basename(croppedFile!.path);
      String extention = fileName.split('.')[1];
      fileName =
          "Profiles/${_auth.currentUser!.uid}-${DateTime.now().millisecondsSinceEpoch.toString()}.$extention";
      imageFile = File(croppedFile.path);
      try {
        await _storage.ref(fileName).putFile(
              imageFile!,
            );
        Fluttertoast.showToast(msg: "Uploaded");
        final storageRef = FirebaseStorage.instance.ref();
        imgUrl.value = await storageRef.child(fileName).getDownloadURL();
        log(imgUrl.value);
        await _firestore.collection("Users").doc(_auth.currentUser!.uid).update(
          {
            'image': imgUrl.value,
          },
        );
        isImageUploading.value = false;
      } catch (e) {
        debugPrint(
          e.toString(),
        );

        isImageUploading.value = false;
      }
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
          'address': addressController.text,
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
