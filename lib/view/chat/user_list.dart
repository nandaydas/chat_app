import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/routes/route_names.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math' as math;

class UserList extends StatelessWidget {
  UserList({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final AuthController ac = Get.put(AuthController());

  final RxBool searchOn = false.obs;
  final RxString searchTerm = "".obs;

  final math.Random random = math.Random();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => searchOn.value
              ? Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextFormField(
                      autofocus: false,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Search',
                      ),
                      onChanged: (value) {
                        searchTerm.value = value;
                      },
                    ),
                  ),
                )
              : const Text('New Chat'),
        ),
        actions: [
          IconButton(
            onPressed: () {
              searchOn.value = !searchOn.value;
              searchTerm.value = "";
            },
            icon: Obx(
              () => Icon(
                  searchOn.value ? Icons.close_rounded : Icons.search_rounded),
            ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: ac.userType.value == "Employee",
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.toNamed(RouteNames.createGroup);
          },
          foregroundColor: Colors.white,
          icon: const Icon(Icons.group_add_rounded),
          label: const Text("New group"),
        ),
      ),
      body: Scrollbar(
        radius: const Radius.circular(50),
        interactive: true,
        child: Obx(
          () => searchTerm.value == ""
              ? FirestoreListView(
                  query: _firestore
                      .collection('Users')
                      .where('user_type', isEqualTo: 'Client'),
                  padding: const EdgeInsets.only(top: 6),
                  itemBuilder: (context, doc) {
                    var user = doc.data();
                    return userCard(context, user);
                  },
                )
              : FirestoreListView(
                  query: _firestore
                      .collection('Users')
                      .where('user_type', isEqualTo: 'Client'),
                  padding: const EdgeInsets.only(top: 6),
                  itemBuilder: (context, doc) {
                    var user = doc.data();
                    if (user['name']
                        .toLowerCase()
                        .contains(searchTerm.value.toLowerCase())) {
                      return userCard(context, user);
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
        ),
      ),
    );
  }

  Widget userCard(BuildContext context, Map user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () async {
          try {
            final RxString chatId = ''.obs;
            final RxInt chatKey = 0.obs;

            final RxMap chatData = {}.obs;

            await _firestore
                .collection('Chats')
                .where("type", isEqualTo: "Normal")
                .where('users', arrayContains: _auth.currentUser!.uid)
                .get()
                .then(
              (snapshot) {
                for (var s in snapshot.docs) {
                  if (s.data()['users'].contains(user['id'])) {
                    chatId.value = s.id; //if chat exists with current user
                    chatKey.value =
                        s.data()['key']; //if chat exists with current user

                    chatData.value = s.data();
                  }
                }
              },
            );
            if (chatId.value == "") {
              chatId.value = Timestamp.now().microsecondsSinceEpoch.toString();
              int encryptionKey = random.nextInt(90) + 10;

              await _firestore.collection('Chats').doc(chatId.value).set(
                {
                  'cid': chatId.value,
                  'users': [
                    _auth.currentUser!.uid,
                    user['id'],
                  ],
                  'last_msg': '',
                  'last_update': Timestamp.now(),
                  'key': encryptionKey,
                  'type': 'Normal',
                },
              ); //Creates new chat

              chatKey.value = encryptionKey;

              chatData.value = {
                'cid': chatId.value,
                'users': [
                  _auth.currentUser!.uid,
                  user['id'],
                ],
                'last_msg': '',
                'last_update': Timestamp.now(),
                'key': encryptionKey,
                'type': 'Normal',
              };
            }

            Get.offAndToNamed(
              RouteNames.chatScreen,
              arguments: [
                [
                  user,
                ],
                chatData,
                chatKey.value,
              ],
            );
          } catch (e) {
            log(e.toString());
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
          subtitle: Text("${user['email']}"),
        ),
      ),
    );
  }
}
