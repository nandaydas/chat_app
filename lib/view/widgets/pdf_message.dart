import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/controllers/encryption_controller.dart';
import 'package:chat_app/routes/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import '../../constants/colors.dart';

class PdfMessage extends StatelessWidget {
  PdfMessage({
    super.key,
    required this.message,
    required this.chatKey,
    required this.type,
  });

  final EncryptionController ec = Get.put(EncryptionController());
  final ChatController cc = Get.put(ChatController());

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map message;
  final int chatKey;
  final String type;

  final RxString senderName = "".obs;
  void getUsername(String id) async {
    senderName.value = "-";
    try {
      await _firestore.collection("Users").doc(id).get().then(
        (snapshot) {
          senderName.value = snapshot.data()!['name'];
        },
      );
    } catch (e) {
      log("getUsername exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isMe = message['uid'] == _auth.currentUser!.uid;
    String decryptedMessage = ec.messageDecrypt(message['message'], chatKey);

    if (type == 'Group') {
      getUsername(message['uid']);
    }

    return Obx(
      () => Container(
        alignment: isMe ? Alignment.topRight : Alignment.topLeft,
        color: cc.selectedMsg.contains(message)
            ? primaryColor.withOpacity(0.2)
            : Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: GestureDetector(
          onLongPress: () {
            if (isMe) {
              cc.selectedMsg.add(message);
            }
          },
          onTap: () {
            if (cc.selectedMsg.isEmpty) {
              Get.toNamed(
                RouteNames.pdfPlayer,
                arguments: [
                  decryptedMessage,
                  message['uid'] == _auth.currentUser!.uid
                      ? 'You'
                      : senderName.value,
                  DateFormat('KK:mm a ')
                      .format(message['time'].toDate())
                      .toLowerCase(),
                ],
              );
            } else {
              if (cc.selectedMsg.contains(message)) {
                cc.selectedMsg.remove(message);
              } else {
                cc.selectedMsg.add(message);
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(
              minHeight: 50,
              minWidth: 50,
              maxWidth: 150,
            ),
            decoration: BoxDecoration(
              color: isMe ? primaryColor : Colors.white,
              borderRadius: isMe
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    )
                  : const BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 0.5,
                  blurRadius: 0.5,
                  offset: isMe ? const Offset(0.5, 1) : const Offset(-0.5, 1),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Visibility(
                  visible: !isMe && type == 'Group',
                  child: Column(
                    children: [
                      Obx(
                        () => Text(
                          senderName.value,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                ),
                Stack(
                  alignment:
                      isMe ? Alignment.bottomRight : Alignment.bottomLeft,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 50,
                          minWidth: 50,
                          maxWidth: 150,
                        ),
                        decoration:
                            BoxDecoration(color: Colors.black.withOpacity(0.4)),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.description_rounded,
                                color: Colors.white,
                              ),
                              Text(
                                ' PDF Document',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 5),
                      child: Text(
                        DateFormat('KK:mm a ')
                            .format(message['time'].toDate())
                            .toLowerCase(),
                        style:
                            const TextStyle(fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
