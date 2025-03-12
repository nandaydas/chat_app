import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/controllers/encryption_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import '../../controllers/chat_controller.dart';

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

class TextMessage extends StatelessWidget {
  const TextMessage(
      {super.key,
      required this.message,
      required this.chatKey,
      required this.type});

  final Map message;
  final int chatKey;
  final String type;

  @override
  Widget build(BuildContext context) {
    bool isMe = message['uid'] == _auth.currentUser!.uid;
    String decryptedMessage =
        ec.messageDecrypt(message['message'] ?? '', chatKey);

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
            if (cc.selectedMsg.isNotEmpty) {
              if (cc.selectedMsg.contains(message)) {
                cc.selectedMsg.remove(message);
              } else {
                cc.selectedMsg.add(message);
              }
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width /
                  1.425, //70% width of screen
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
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Visibility(
                    visible: !isMe && type == 'Group',
                    child: Text(
                      senderName.value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ),
                Text(
                  decryptedMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: isMe ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  DateFormat('KK:mm a ')
                      .format(message['time'].toDate())
                      .toLowerCase(),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.grey[200] : Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
