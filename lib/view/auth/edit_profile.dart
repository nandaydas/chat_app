import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/controllers/edit_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/colors.dart';
import '../../constants/links.dart';
import '../../controllers/auth_controller.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class EditProfile extends StatelessWidget {
  EditProfile({super.key});

  final AuthController ac = Get.put(AuthController());
  final EditProfileController epc = Get.put(EditProfileController());

  @override
  Widget build(BuildContext context) {
    epc.nameController.text = ac.userName.value;
    epc.emailController.text = ac.userEmail.value;
    epc.phoneController.text = ac.userPhone.value;
    epc.selectedGender.value = ac.userGender.value;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Form(
            key: epc.formKey,
            child: Column(
              children: [
                const SizedBox(height: 8),
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: epc.image != null
                          ? Image.file(
                              File(epc.image!.path),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : CachedNetworkImage(
                              imageUrl: ac.userImage.value,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                              errorWidget: (context, url, error) =>
                                  ColoredBox(color: Colors.grey.shade300),
                              placeholder: (context, url) =>
                                  ColoredBox(color: Colors.grey.shade300),
                            ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: InkWell(
                        onTap: () => epc.pickImage(context),
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: primaryColor.withOpacity(0.8),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: epc.nameController,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: backgroundColor.withOpacity(0.5),
                      labelText: 'Full Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: epc.emailController,
                  enabled: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: backgroundColor.withOpacity(0.5),
                      labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: epc.phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: backgroundColor.withOpacity(0.5),
                      prefixText: '+91 ',
                      labelText: 'Phone'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'This field is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: epc.addressController,
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: backgroundColor.withOpacity(0.5),
                      labelText: 'Address'),
                ),
                const SizedBox(height: 16),
                const SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Gender',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RepaintBoundary(
                      child: InkWell(
                        onTap: () {
                          epc.selectedGender.value = epc.options[0];
                        },
                        child: Row(
                          children: [
                            Obx(
                              () => Radio(
                                value: epc.options[0],
                                groupValue: epc.selectedGender.value,
                                activeColor: primaryColor,
                                onChanged: (value) {
                                  epc.selectedGender.value = value as String;
                                },
                              ),
                            ),
                            const Text('Male'),
                          ],
                        ),
                      ),
                    ),
                    RepaintBoundary(
                      child: InkWell(
                        onTap: () {
                          epc.selectedGender.value = epc.options[1];
                        },
                        child: Row(
                          children: [
                            Obx(
                              () => Radio(
                                value: epc.options[1],
                                groupValue: epc.selectedGender.value,
                                activeColor: primaryColor,
                                onChanged: (value) {
                                  epc.selectedGender.value = value as String;
                                },
                              ),
                            ),
                            const Text('Female'),
                          ],
                        ),
                      ),
                    ),
                    RepaintBoundary(
                      child: InkWell(
                        onTap: () {
                          epc.selectedGender.value = epc.options[2];
                        },
                        child: Row(
                          children: [
                            Obx(
                              () => Radio(
                                value: epc.options[2],
                                groupValue: epc.selectedGender.value,
                                activeColor: primaryColor,
                                onChanged: (value) {
                                  epc.selectedGender.value = value as String;
                                },
                              ),
                            ),
                            const Text('Others'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Obx(() {
                  return SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (epc.formKey.currentState!.validate()) {
                          epc.saveChanges(context);
                        }
                      },
                      child: epc.isSaving.value
                          ? const CircularProgressIndicator()
                          : const Text('Save Changes'),
                    ),
                  );
                }),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Joined'),
                        Obx(
                          () => Text(
                            DateFormat('d MMM y')
                                .format(ac.joinDate.value.toDate())
                                .toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () async {
                        final url = Uri.parse(deleteAccount);
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.externalApplication,
                          );
                        } else {
                          Fluttertoast.showToast(msg: 'Something went wrong !');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.red.withOpacity(0.2),
                          foregroundColor: Colors.red.shade600),
                      child: const Text('Delete Account'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
