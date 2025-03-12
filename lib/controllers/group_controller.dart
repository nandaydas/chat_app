import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../routes/route_names.dart';
import 'dart:math' as math;

class GroupController extends GetxController {
  final RxList<Map> selectedMembers = <Map>[].obs;
  final TextEditingController groupName = TextEditingController();
  final RxString imageUrl = "".obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final math.Random random = math.Random();

  final List users = [];

  void createGroup() async {
    final RxString chatId = ''.obs;
    users.clear();

    chatId.value = Timestamp.now().microsecondsSinceEpoch.toString();
    int encryptionKey = random.nextInt(90) + 10;

    for (var i in selectedMembers) {
      users.add(i['id']);
    }
    users.add(_auth.currentUser!.uid);

    final Map<String, dynamic> chatData = {
      'type': 'Group',
      'name': groupName.text.trim(),
      'image': imageUrl.value,
      'cid': chatId.value,
      'users': users,
      'last_msg': '',
      'last_update': Timestamp.now(),
      'key': encryptionKey,
      'date_created': Timestamp.now(),
      'created_by': _auth.currentUser!.uid,
      'admins': [
        _auth.currentUser!.uid,
      ],
    };

    await _firestore
        .collection('Chats')
        .doc(chatId.value)
        .set(
          chatData,
        )
        .then(
      (_) {
        Fluttertoast.showToast(msg: "Group created");
        groupName.clear();
        Get.back();
      },
    );

    Get.offAndToNamed(
      RouteNames.chatScreen,
      arguments: [
        selectedMembers,
        chatData,
        encryptionKey,
      ],
    );
  }

  final RxList<Map> userDataList = <Map>[].obs;

  void getMembersInfo(List<Map> userList) async {
    userDataList.clear();
    for (var i in userList) {
      if (i['id'] != _auth.currentUser!.uid) {
        await _firestore.collection("Users").doc(i['id']).get().then(
          (snapshot) {
            userDataList.add(snapshot.data() as Map);
          },
        );
      }
    }
  }

  void exitGroup(Map chatData, String uid) async {
    try {
      await _firestore.collection("Chats").doc(chatData['cid']).update(
        {
          'users': FieldValue.arrayRemove([uid]),
        },
      ).then(
        (_) {
          Get.back();
        
        },
      );
    } catch (e) {
      log("exitGroup exception: $e");
    }
  }

  void deleteGroup(String id) async {
    await _firestore.collection("Chats").doc(id).delete().then(
      (_) {
        Fluttertoast.showToast(msg: "Group deleted");
        Get.back();
        Get.back();
      },
    );
  }
}
