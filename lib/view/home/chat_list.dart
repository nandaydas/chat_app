import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/view/chat/chat_page.dart';
import 'package:chat_app/view/chat/user_list.dart';
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
            onPressed: () {},
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
              physics: const NeverScrollableScrollPhysics(),
              emptyBuilder: (context) =>
                  const Center(child: Text('No Chats Found !')),
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Text('Something went wrong !'),
              ),
              itemBuilder: (context, doc) {
                final data = doc.data();
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

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            userData: {
                              'name': userName.value,
                              'image': userImage.value,
                              'id': data['users'][0] == _auth.currentUser!.uid
                                  ? data['users'][1]
                                  : data['users'][0],
                              'push_token': userToken.value,
                            },
                            chatId: data['cid'] ?? '',
                          ),
                        ),
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: ListTile(
                        leading: Obx(
                          () => Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: CachedNetworkImage(
                                  imageUrl: userImage.value,
                                  height: 50,
                                  width: 50,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      ColoredBox(color: Colors.grey.shade300),
                                  errorWidget: (context, url, error) =>
                                      ColoredBox(color: Colors.grey.shade300),
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
                                  })
                            ],
                          ),
                        ),
                        title: Obx(() => Text(userName.value)),
                        subtitle: Text(
                          data['last_msg'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Text(
                          cc.getTime(data['last_update']),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
      floatingActionButton: Obx(
        () => Visibility(
          visible: ac.userType.value != 'Client',
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserList(),
                ),
              );
            },
            heroTag: 'New Chat',
            child: const Icon(Icons.chat_rounded),
          ),
        ),
      ),
    );
  }
}
