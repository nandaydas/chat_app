import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

class TextMsg extends StatelessWidget {
  const TextMsg({
    super.key,
    required this.messageData,
  });

  final Map messageData;

  @override
  Widget build(BuildContext context) {
    bool isMe = messageData['uid'] == _auth.currentUser!.uid;
    return Container(
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        constraints: BoxConstraints(
          maxWidth:
              MediaQuery.of(context).size.width / 1.425, //70% width of screen
        ),
        decoration: BoxDecoration(
            color: isMe ? primaryColor : Colors.white,
            borderRadius: isMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
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
              messageData['message'],
              style: TextStyle(
                fontSize: 15,
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            Text(
              DateFormat('KK:mm a ')
                  .format(messageData['time'].toDate())
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
}

class ImageMsg extends StatelessWidget {
  const ImageMsg({
    super.key,
    required this.message,
  });

  final Map message;

  @override
  Widget build(BuildContext context) {
    bool isMe = message['uid'] == _auth.currentUser!.uid;
    return Container(
      alignment: isMe ? Alignment.topRight : Alignment.topLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 5),
        padding: const EdgeInsets.all(5),
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
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  )
                : const BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
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
              child: CachedNetworkImage(
                imageUrl: message['message'],
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.withOpacity(0.5),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: Colors.white,
                        ),
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
    );
  }
}
