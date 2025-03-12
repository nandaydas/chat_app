import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class AddGroupMember extends StatelessWidget {
  AddGroupMember({super.key, required this.chatData});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map chatData;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Members"),
      content: SizedBox(
        width: double.maxFinite,
        child: Scrollbar(
          radius: const Radius.circular(50),
          interactive: true,
          child: FirestoreListView(
            shrinkWrap: true,
            query: _firestore
                .collection('Users')
                .where("id", whereNotIn: chatData['users']),
            padding: const EdgeInsets.only(top: 6),
            emptyBuilder: (context) => const Center(
              child: Text("No new members found !"),
            ),
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Text("Something went wrong"),
            ),
            itemBuilder: (context, doc) {
              var user = doc.data();
              return userCard(context, user);
            },
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(elevation: 0),
          child: const Text("Done"),
        ),
      ],
    );
  }

  Widget userCard(BuildContext context, Map user) {
    return InkWell(
      onTap: () async {
        if (chatData['users'].contains(user['id'])) {
          Fluttertoast.showToast(msg: "User already in group");
        } else {
          Navigator.pop(context);
          try {
            await _firestore.collection("Chats").doc(chatData['cid']).update(
              {
                'users': FieldValue.arrayUnion([user['id']]),
              },
            ).then(
              (_) {
                Fluttertoast.showToast(msg: "'${user['name']}' added to group");
                Get.back();
              },
            );
          } catch (e) {
            log("addGroupMember exception: $e");
          }
        }
      },
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: CachedNetworkImage(
            imageUrl: user['image'] ?? '',
            height: 50,
            width: 50,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) =>
                ColoredBox(color: Colors.grey.shade300),
            placeholder: (context, url) =>
                ColoredBox(color: Colors.grey.shade300),
          ),
        ),
        title: Text(user['name'] ?? ''),
        subtitle: Text("+91 ${user['phone']}"),
      ),
    );
  }
}
