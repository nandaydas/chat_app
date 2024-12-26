import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/controllers/encryption_controller.dart';
import 'package:chat_app/routes/route_names.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final EncryptionController ec = EncryptionController();

Widget textMessage(BuildContext context, Map message, int key) {
  bool isMe = message['uid'] == _auth.currentUser!.uid;
  String decryptedMessage = ec.messageDecrypt(message['message'], key);

  return Container(
    alignment: isMe ? Alignment.topRight : Alignment.topLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      constraints: BoxConstraints(
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
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            decryptedMessage,
            style: TextStyle(
              fontSize: 15,
              color: isMe ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 2),
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
  );
}

Widget imageMsg(BuildContext context, Map message, int key, String senderName,
    String timeStamp) {
  bool isMe = message['uid'] == _auth.currentUser!.uid;
  String decryptedMessage = ec.messageDecrypt(message['message'], key);

  return Container(
    alignment: isMe ? Alignment.topRight : Alignment.topLeft,
    child: InkWell(
      onTap: () {
        Get.toNamed(RouteNames.imageViewer,
            arguments: [decryptedMessage, senderName, timeStamp]);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
        child: Stack(
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
              padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
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
