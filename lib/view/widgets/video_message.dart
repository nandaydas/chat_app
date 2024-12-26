import 'package:chat_app/controllers/encryption_controller.dart';
import 'package:chat_app/routes/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import '../../constants/colors.dart';

class VideoMessage extends StatelessWidget {
  VideoMessage(
      {super.key,
      required this.message,
      required this.chatKey,
      required this.senderName});

  final EncryptionController ec = Get.put(EncryptionController());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Map message;
  final int chatKey;
  final String senderName;

  @override
  Widget build(BuildContext context) {
    bool isMe = message['uid'] == _auth.currentUser!.uid;
    String decryptedMessage = ec.messageDecrypt(message['message'], chatKey);

    return Container(
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      child: InkWell(
        onTap: () {
          Get.toNamed(RouteNames.videoPlayer, arguments: [
            decryptedMessage,
            senderName,
            DateFormat('KK:mm a ')
                .format(message['time'].toDate())
                .toLowerCase(),
          ]);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
              ]),
          child: Stack(
            alignment: isMe ? Alignment.bottomRight : Alignment.bottomLeft,
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
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                        ),
                        Text(
                          'Video file',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
                child: Text(
                  DateFormat('KK:mm a ')
                      .format(message['time'].toDate())
                      .toLowerCase(),
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
