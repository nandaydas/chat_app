import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat_app/controllers/encryption_controller.dart';
import 'package:chat_app/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// ignore: depend_on_referenced_packages
import "package:path/path.dart" as path;
import 'package:record/record.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider/path_provider.dart';

class ChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();

  bool scrollable = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final EncryptionController ec = EncryptionController();

  final RxString messageText = "".obs;
  final RxBool isRecording = false.obs;

  final record = AudioRecorder();

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

  void sendMessage(String cid, String message, String type, int key) async {
    try {
      String mid = DateTime.now().microsecondsSinceEpoch.toString();
      String encryptedMessage = ec.messageEncrypt(message, key);

      messageController.clear();
      messageText.value = "";

      await _firestore
          .collection('Chats')
          .doc(cid)
          .collection('Messages')
          .doc(mid)
          .set(
        {
          'message': encryptedMessage,
          'type': type,
          'uid': _auth.currentUser!.uid,
          'time': Timestamp.now(),
          'mid': mid,
        },
      );

      await _firestore.collection('Chats').doc(cid).update(
        {
          'last_update': Timestamp.now(),
          'last_msg': encryptedMessage,
        },
      ).then(
        (_) {
          log(message);
        },
      );
    } catch (e) {
      log(
        e.toString(),
      );
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

  //To Upload a image before sending it
  final RxBool isImageUploading = false.obs;
  void sendImage(String type, String chatId, int key, String receiverToken,
      String senderName) async {
    FirebaseStorage storage = FirebaseStorage.instance;

    XFile? tempImage = await ImagePicker().pickImage(
      source: type == 'camera' ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 50,
    );

    if (tempImage != null) {
      isImageUploading.value = true;
      String fileName = path.basename(tempImage.path);
      String extention = fileName.split('.')[1];
      fileName =
          "Chats/$chatId-${DateTime.now().millisecondsSinceEpoch.toString()}.$extention";
      File imageFile = File(tempImage.path);
      try {
        await storage.ref(fileName).putFile(
              imageFile,
            );

        final storageRef = FirebaseStorage.instance.ref();
        String imageUrl = await storageRef.child(fileName).getDownloadURL();
        sendMessage(chatId, imageUrl, 'image', key);
        isImageUploading.value = false;
        sendPushMessage(senderName, '📷 Photo', chatId, receiverToken);
      } catch (e) {
        debugPrint(
          e.toString(),
        );
        isImageUploading.value = false;
      }
    }
  }

  // To send a Push Notification when a text or image message is sent
  void sendPushMessage(String senderName, String message, String chatId,
      String receiverToken) async {
    const String projectId = "jasda-care-family";
    final String serverKey = await GetServerKey().getServerKeyToken();

    log('Sending push message...');

    if (receiverToken.isNotEmpty) {
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
            'token': receiverToken,
            'notification': {
              'title': senderName,
              'body': message,
              // 'image': type == 'Image' ? message : null,
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
              // 'id': userData['id'],
              // 'name': userData['name'],
              // 'image': userData['name'],
              // 'push_token': userData['name'],
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

  Future<void> startVoiceRecording() async {
    try {
      isRecording.value = true;

      HapticFeedback.vibrate();

      // Check and request permission if needed
      if (await record.hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final filePath =
            '${dir.path}/jcf-${Timestamp.now().microsecondsSinceEpoch}.m4a';

        // Start recording to file
        await record.start(
            const RecordConfig(
              bitRate: 32000,
              sampleRate: 16000,
            ),
            path: filePath);
      }
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> stopVoiceRecording(String chatId, int chatKey,
      String receiverToken, String senderName) async {
    try {
      isRecording.value = false;

      HapticFeedback.vibrate();

      final path = await record.stop();
      uploadToFirebase(path!, chatId, chatKey, receiverToken, senderName);
    } catch (e) {
      log(e.toString());
    }
  }

  Future<void> uploadToFirebase(String filePath, String chatId, int chatKey,
      String receiverToken, String senderName) async {
    try {
      final file = File(filePath);

      if (!file.existsSync()) {
        log('File not found at $filePath');
        return;
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('Chats/Audio/${DateTime.now().millisecondsSinceEpoch}.m4a');

      final uploadTask = storageRef.putFile(file);

      // Monitor upload progress (optional)
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      log('File uploaded successfully: $downloadUrl');
      sendMessage(chatId, downloadUrl, 'audio', chatKey);
      sendPushMessage(senderName, '📷 Voice message', chatId, receiverToken);
    } catch (e) {
      log('Error uploading file: ${e.toString()}');
    }
  }
}
