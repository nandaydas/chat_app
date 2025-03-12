import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/controllers/encryption_controller.dart';
import 'package:chat_app/routes/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

final EncryptionController ec = EncryptionController();
final ChatController cc = Get.put(ChatController());

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

Widget imageMsg(
    BuildContext context, Map message, int key, String timeStamp, String type) {
  bool isMe = message['uid'] == _auth.currentUser!.uid;
  String decryptedMessage = ec.messageDecrypt(message['message'], key);

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
          cc.selectedMsg.add(message);
        },
        onTap: () {
          if (cc.selectedMsg.isEmpty) {
            Get.toNamed(
              RouteNames.imageViewer,
              arguments: [
                decryptedMessage,
                message['uid'] == _auth.currentUser!.uid
                    ? 'You'
                    : senderName.value,
                timeStamp,
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
          constraints: BoxConstraints(
            minHeight: 150,
            minWidth: 150,
            maxWidth:
                MediaQuery.of(context).size.width / 1.425, //70% width of screen
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
              ]),
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
                alignment: isMe ? Alignment.bottomRight : Alignment.bottomLeft,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Hero(
                      tag: decryptedMessage,
                      child: CachedNetworkImage(
                        imageUrl: decryptedMessage,
                        placeholder: (context, url) =>
                            ColoredBox(color: Colors.grey.shade300),
                        errorWidget: (context, url, error) =>
                            ColoredBox(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                    child: Text(
                      DateFormat('KK:mm a ')
                          .format(message['time'].toDate())
                          .toLowerCase(),
                      style: TextStyle(
                        fontSize: 10,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 1
                          ..color = Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                    child: Text(
                      DateFormat('KK:mm a ')
                          .format(message['time'].toDate())
                          .toLowerCase(),
                      style: const TextStyle(fontSize: 10, color: Colors.white),
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
