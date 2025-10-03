import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/controllers/encryption_controller.dart';
import 'package:chat_app/routes/route_names.dart';
import 'package:chat_app/view/widgets/carousel_slider.dart';
import 'package:chat_app/view/widgets/my_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatList extends StatelessWidget {
  ChatList({super.key});

  final ChatController cc = Get.put(ChatController());
  final AuthController ac = Get.put(AuthController());
  final EncryptionController ec = EncryptionController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'images/jcf_communication_logo.png',
          height: 28,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: () {
              Get.toNamed(RouteNames.notificationPage);
            },
            icon: const Icon(Icons.notifications_outlined),
          )
        ],
      ),
      drawer: MyDrawer(),
      body: Scrollbar(
        radius: const Radius.circular(50),
        interactive: true,
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MySlider(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Text(
                    'Chats',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            FirestoreListView(
              query: _firestore
                  .collection('Chats')
                  .where('users', arrayContains: _auth.currentUser!.uid)
                  .orderBy('last_update', descending: true),
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 50),
              physics: const NeverScrollableScrollPhysics(),
              emptyBuilder: (context) =>
                  const Center(child: Text('No Chats Found !')),
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Text('Something went wrong !'),
              ),
              itemBuilder: (context, doc) {
                final Map<String, dynamic> data = doc.data();

                if (data['type'] == 'Normal') {
                  final RxString userName = "Loading...".obs;
                  final RxString userImage = "".obs;
                  final RxString userToken = "".obs;

                  try {
                    _firestore
                        .collection('Users')
                        .doc(data['users'][0] == _auth.currentUser!.uid
                            ? data['users'][1]
                            : data['users'][0])
                        .get()
                        .then(
                      (snapshot) {
                        userName.value = snapshot.data()!['name'];
                        userImage.value = snapshot.data()!['image'];
                        userToken.value = snapshot.data()!['push_token'];
                      },
                    );
                  } catch (e) {
                    log('ChatList Error: $e');
                  }

                  String decryptedMessage =
                      ec.messageDecrypt(data['last_msg'], data['key']);

                  return Card(
                    color: Colors.white,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: InkWell(
                      onTap: () {
                        Get.toNamed(
                          RouteNames.chatScreen,
                          arguments: [
                            [
                              {
                                'name': userName.value,
                                'image': userImage.value,
                                'id': data['users'][0] == _auth.currentUser!.uid
                                    ? data['users'][1]
                                    : data['users'][0],
                                'push_token': userToken.value,
                              }
                            ],
                            data,
                            data['key'] ?? 0,
                          ],
                        );
                      },
                      onLongPress: () {
                        deleteChat(context, data['cid']);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: ListTile(
                        leading: Obx(
                          () => SizedBox(
                            height: 50,
                            width: 50,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedNetworkImage(
                                    imageUrl: userImage.value,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.person_rounded),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.person_rounded),
                                    ),
                                  ),
                                ),
                                StreamBuilder(
                                    stream: _firestore
                                        .collection('Users')
                                        .doc(data['users'][0] ==
                                                _auth.currentUser!.uid
                                            ? data['users'][1]
                                            : data['users'][0])
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Visibility(
                                          visible: snapshot.data!['is_active'],
                                          child: Positioned(
                                            bottom: 2,
                                            right: 2,
                                            child: Container(
                                              height: 12,
                                              width: 12,
                                              decoration: BoxDecoration(
                                                  color: Colors.green,
                                                  border: Border.all(
                                                      color: Colors.white),
                                                  shape: BoxShape.circle),
                                            ),
                                          ),
                                        );
                                      } else {
                                        return const Text('NA');
                                      }
                                    })
                              ],
                            ),
                          ),
                        ),
                        title: Obx(
                          () => Text(
                            userName.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        subtitle: Text(
                          decryptedMessage.contains('.jpg')
                              ? '📷 Photo'
                              : decryptedMessage.contains('.m4a')
                                  ? '🎤 Voice message'
                                  : decryptedMessage.contains('.mp4')
                                      ? '📹 Video'
                                      : decryptedMessage.contains('.pdf')
                                          ? '📄 PDF File'
                                          : decryptedMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          cc.getTime(data['last_update']),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  );
                } else {
                  String decryptedMessage =
                      ec.messageDecrypt(data['last_msg'], data['key']);

                  final RxList<Map> userList = <Map>[].obs;

                  return Card(
                    color: Colors.white,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: InkWell(
                      onTap: () {
                        for (var i in data['users']) {
                          userList.add(
                            {'id': i},
                          );
                        }

                        Get.toNamed(
                          RouteNames.chatScreen,
                          arguments: [
                            userList,
                            data,
                            data['key'] ?? 0,
                          ],
                        );
                      },
                      onLongPress: () {
                        deleteChat(context, data['cid']);
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            imageUrl: data['image'] ?? '',
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.group_rounded),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey.shade300,
                              child: const Icon(Icons.group_rounded),
                            ),
                          ),
                        ),
                        title: Text(data['name'] ?? 'Group'),
                        subtitle: Text(
                          decryptedMessage.contains('.jpg')
                              ? '📷 Photo'
                              : decryptedMessage.contains('.m4a')
                                  ? '🎤 Voice message'
                                  : decryptedMessage.contains('.mp4')
                                      ? '📹 Video'
                                      : decryptedMessage.contains('.pdf')
                                          ? '📄 PDF File'
                                          : decryptedMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          cc.getTime(data['last_update']),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  );
                }
              },
            )
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => Visibility(
          visible: ac.userType.value != 'Client',
          child: FloatingActionButton.extended(
            onPressed: () {
              Get.toNamed(RouteNames.userList);
            },
            heroTag: 'New Chat',
            icon: const Icon(Icons.chat_rounded),
            label: const Text("New Chat"),
          ),
        ),
      ),
    );
  }

  // Shows a confirmation dialog before deleting a chat
  void deleteChat(BuildContext context, String cid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete chat"),
        content: const Text(
            "You are about to parmanently delete this chat. Are you sure?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
            },
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              cc.deleteChat(cid); // Delete chat
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
