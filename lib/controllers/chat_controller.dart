import 'dart:convert';
import 'dart:developer';
import 'package:chat_app/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();

  bool scrollable = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  getTime(Timestamp time) {
    if (DateFormat('yMd').format(time.toDate()) ==
        DateFormat('yMd').format(Timestamp.now().toDate())) {
      return DateFormat('jm').format(time.toDate()).toLowerCase();
    } else if (DateFormat('yMd').format(time.toDate()) ==
        DateFormat('yMd').format(
            Timestamp.now().toDate().subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else if (DateFormat('y').format(time.toDate()) ==
        DateFormat('y').format(Timestamp.now().toDate())) {
      return DateFormat('d MMM').format(time.toDate());
    } else {
      return DateFormat('d MMM y').format(time.toDate());
    }
  }

  final RxBool clientChat = false.obs;

  void getClientPermission() async {
    try {
      await _firestore.collection("App").doc('chat').get().then(
        (snapshot) {
          clientChat.value = snapshot.data()!['client'];
        },
      );
    } catch (e) {
      log(e.toString());
    }
  }

  void sendMessage(String cid, String message) async {
    messageController.clear();
    String mid = DateTime.now().microsecondsSinceEpoch.toString();

    await _firestore
        .collection('Chats')
        .doc(cid)
        .collection('Messages')
        .doc(mid)
        .set(
      {
        'message': message,
        'type': 'text',
        'uid': _auth.currentUser!.uid,
        'time': Timestamp.now(),
        'mid': mid,
      },
    );

    await _firestore.collection('Chats').doc(cid).update(
      {
        'last_update': Timestamp.now(),
        'last_msg': message,
      },
    ).then(
      (_) {
        log(message);
      },
    );
  }

  XFile? image;
  void sendImage() async {
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

  final TextEditingController reportReason = TextEditingController();

  void reportChat(BuildContext context, String chatID) async {
    await _firestore.collection('Reports').add(
      {
        'cid': chatID,
        'reason': reportReason.text,
        'reporter': _auth.currentUser!.uid,
      },
    ).then((_) {
      Navigator.pop(context);
    });
  }

  // To send a Push Notification when a text or image message is sent
  void sendPushMessage(String token, String title, String body, String type,
      String chatId, Map userData) async {
    const String projectId = "jasda-care-family";
    final String serverKey = await GetServerKey().getServerKeyToken();

    log('Sending push message...');

    if (token.isNotEmpty) {
      try {
        final url = Uri.parse(
            'https://fcm.googleapis.com/v1/projects/$projectId/messages:send');
        final headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $serverKey',
        };

        // Construct the payload
        final payload = {
          'message': {
            'token': token,
            'notification': {
              'title': title,
              'body': type == 'Text' ? body : 'Sent a 📷 Photo',
              'image': type == 'Image' ? body : null,
            },
            'android': {
              'priority': 'high',
              'notification': {
                'channel_id':
                    'chats', // Ensure the channel ID exists in the AndroidManifest
              },
            },
            'data': {
              'type': 'chat',
              'chat_id': chatId,
              'id': userData['id'],
              'name': userData['name'],
              'image': userData['name'],
              'push_token': userData['name'],
            },
          },
        };

        // Send the POST request
        final response = await http.post(
          url,
          headers: headers,
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          log('Push Notification sent successfully!');
        } else {
          log('Failed to send Push Notification: ${response.body}');
        }
      } catch (e) {
        log("sendPushMessage Error: $e");
      }
    } else {
      log("No token provided.");
    }
  }
}
