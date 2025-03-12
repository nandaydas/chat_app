import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:chat_app/controllers/encryption_controller.dart';
import 'package:chat_app/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'package:file_picker/file_picker.dart';

class ChatController extends GetxController {
  final TextEditingController messageController = TextEditingController();

  bool scrollable = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final EncryptionController ec = EncryptionController();

  final RxString messageText = "".obs;
  final RxBool isRecording = false.obs;

  final RxBool isMediaUploading = false.obs;
  final RxBool isVoiceMessageSending = false.obs;

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

  // compressVideo(String filePath) async {
  //   final compressedFile = await VideoCompress.compressVideo(
  //     filePath,
  //     quality: VideoQuality.LowQuality,
  //   );

  //   return compressedFile!.file;
  // }

  //To Upload a image/Video before sending it
  void sendMedia(String type, ImageSource source, String chatId, int key,
      String receiverToken, String senderName) async {
    FirebaseStorage storage = FirebaseStorage.instance;

    XFile? tempImage;

    if (type == 'image') {
      tempImage = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 30,
        requestFullMetadata: false,
      );
    } else {
      tempImage = await ImagePicker().pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 10),
      );
    }

    if (tempImage != null) {
      isMediaUploading.value = true;

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
        sendMessage(chatId, imageUrl, type, key);

        sendPushMessage(
          senderName,
          type == 'image' ? '📷 Photo' : '📹 Video',
          chatId,
          receiverToken,
        );
        isMediaUploading.value = false;
      } catch (e) {
        debugPrint(
          e.toString(),
        );
        isMediaUploading.value = false;
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
      } else {
        Fluttertoast.showToast(msg: 'Enable mic permission in settings.');
      }
    } catch (e) {
      isRecording.value = false;
      log(e.toString());
    }
  }

  Future<void> stopVoiceRecording(String chatId, int chatKey,
      String receiverToken, String senderName) async {
    try {
      isRecording.value = false;
      isVoiceMessageSending.value = true;
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
      sendPushMessage(senderName, '🎤 Voice message', chatId, receiverToken);
      isVoiceMessageSending.value = false;
    } catch (e) {
      log('Error uploading file: ${e.toString()}');
    }
  }

  Future<void> uploadPDF(String chatId, int chatKey, String senderName,
      String receiverToken) async {
    // Pick PDF file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      try {
        isMediaUploading.value = true;

        // Upload to Firebase Storage
        Reference ref = FirebaseStorage.instance.ref().child('pdfs/$fileName');
        UploadTask uploadTask = ref.putFile(file);

        // Wait for upload completion
        TaskSnapshot snapshot = await uploadTask;
        String url = await snapshot.ref.getDownloadURL();

        sendMessage(chatId, url, 'pdf', chatKey);
        sendPushMessage(senderName, '📄 Pdf file', chatId, receiverToken);

        isMediaUploading.value = false;
      } catch (e) {
        isMediaUploading.value = false;
        log("uploadPDF exception $e");
      }
    }
  }

  final RxList<Map> selectedMsg = <Map>[].obs;

  void deleteMessages(String chatId) async {
    for (var msg in selectedMsg) {
      await _firestore
          .collection("Chats")
          .doc(chatId)
          .collection("Messages")
          .doc(msg['mid'])
          .update(
        {
          'type': 'deleted',
          'deleted': Timestamp.now(),
        },
      );
    }
    selectedMsg.clear();
  }

  void deleteChat(String cid) async {
    await _firestore.collection("Chats").doc(cid).delete();
  }

  void forwardMessages(Map chatData, int sendKey) async {
    try {
      for (Map msg in selectedMsg) {
        final String message = ec.messageEncrypt(
            ec.messageDecrypt(msg['message'], sendKey), chatData['key']);
        await _firestore
            .collection("Chats")
            .doc(chatData['cid'])
            .collection("Messages")
            .add(
          {
            'uid': _auth.currentUser!.uid,
            'time': Timestamp.now(),
            'mid': msg['mid'],
            'type': msg['type'],
            'message': message,
            'forwarded': true,
          },
        );

        await _firestore.collection("Chats").doc(chatData['cid']).update(
          {
            'last_msg': message,
            'last_update': Timestamp.now(),
          },
        );
      }
      selectedMsg.clear();
      Get.back();
    } catch (e) {
      log("forwardMessages exception: $e");
    }
  }

  void blockContact(String uid) async {
    await _firestore.collection("Users").doc(_auth.currentUser!.uid).update(
      {
        'blocked': FieldValue.arrayUnion([uid])
      },
    ).then(
      (_) {
        Fluttertoast.showToast(msg: 'User blocked');
      },
    );
  }

  void unblockContact(String uid) async {
    await _firestore.collection("Users").doc(_auth.currentUser!.uid).update(
      {
        'blocked': FieldValue.arrayRemove([uid])
      },
    ).then(
      (_) {
        Fluttertoast.showToast(msg: 'User unblocked');
      },
    );
  }
}
