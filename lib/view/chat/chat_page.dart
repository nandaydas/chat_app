import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/controllers/chat_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../widgets/message_bubbles.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class ChatPage extends StatelessWidget {
  ChatPage({
    super.key,
    required this.userData,
    required this.chatId,
    required this.chatKey,
  });

  final Map userData;
  final String chatId;
  final int chatKey;

  final ChatController cc = Get.put(ChatController());
  final AuthController ac = Get.put(AuthController());

  final RxInt _showEmoji = 0.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    cc.getClientPermission();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: userData['image'] ?? '',
                height: 45,
                width: 45,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) =>
                    ColoredBox(color: Colors.grey.shade300),
                placeholder: (context, url) =>
                    ColoredBox(color: Colors.grey.shade300),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(userData['name'] ?? ''),
                StreamBuilder(
                  stream: _firestore
                      .collection('Users')
                      .doc(userData['id'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return snapshot.data!['is_active']
                          ? Text(
                              'Online',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            )
                          : Text(
                              "Last active ${DateFormat('d MMM hh:mm a').format(snapshot.data!['last_active'].toDate())}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            );
                    } else if (snapshot.hasError) {
                      return Text(
                        'Something went wrong !',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      );
                    } else {
                      return Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      );
                    }
                  },
                )
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Report Chat'),
                  content: TextFormField(
                    controller: cc.reportReason,
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(), hintText: 'Reason'),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () {
                          cc.reportChat(context, chatId);
                        },
                        child: const Text('SUBMIT')),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.report_outlined),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/chat_bg.jpeg'), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Expanded(
                child: Scrollbar(
              radius: const Radius.circular(50),
              interactive: true,
              child: FirestoreListView(
                query: _firestore
                    .collection('Chats')
                    .doc(chatId)
                    .collection('Messages')
                    .orderBy('time', descending: true),
                reverse: true,
                itemBuilder: (context, doc) {
                  var message = doc.data();

                  if (message['type'] == 'text') {
                    return textMessage(context, message, chatKey);
                  } else if (message['type'] == 'image') {
                    return imageMsg(context, message, chatKey);
                  } else {
                    return const Text('Unsupported Message Type');
                  }
                },
              ),
            )),
            ac.userType.value == 'Client'
                ? Obx(
                    () => cc.clientChat.value
                        ? chatBar(context)
                        : Image.asset(
                            'images/Footer.png',
                            width: double.infinity,
                          ),
                  )
                : chatBar(context),
            Obx(
              () {
                if (_showEmoji.value == 1) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height / 2.85,
                    child: EmojiPicker(
                      textEditingController: cc.messageController,
                      onBackspacePressed: () {},
                      config: Config(
                        height: 256,
                        checkPlatformCompatibility: true,
                        emojiViewConfig: EmojiViewConfig(
                          // Issue: https://github.com/flutter/flutter/issues/28894
                          emojiSizeMax: 28 * (Platform.isIOS ? 1.20 : 1.0),
                        ),
                        viewOrderConfig: const ViewOrderConfig(
                          top: EmojiPickerItem.categoryBar,
                          middle: EmojiPickerItem.emojiView,
                          bottom: EmojiPickerItem.searchBar,
                        ),
                        skinToneConfig: const SkinToneConfig(),
                        categoryViewConfig: const CategoryViewConfig(),
                        bottomActionBarConfig: const BottomActionBarConfig(),
                        searchViewConfig: const SearchViewConfig(),
                      ),
                    ),
                  );
                } else {
                  return const SizedBox();
                }
              },
            )
          ],
        ),
      ),
    );
  }

  Widget chatBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(blurRadius: 2.0, color: Colors.black.withOpacity(0.2))
      ]),
      padding: const EdgeInsets.all(2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Card(
              elevation: 0,
              color: Colors.grey[100],
              margin: const EdgeInsets.all(4),
              shape: RoundedRectangleBorder(
                side: const BorderSide(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(100),
              ),
              child: TextField(
                onSubmitted: (value) {
                  cc.sendPushMessage(
                    userData['push_token'],
                    userData['name'],
                    cc.messageController.text,
                    'Text',
                    chatId,
                    userData,
                  );
                  cc.sendMessage(chatId, value, 'text', chatKey);
                  _showEmoji.value = 0; // Dismiss emoji after sending
                },
                onTap: () {
                  if (_showEmoji.value == 1) {
                    _showEmoji.value = 0; // Hide emoji on tap
                  }
                },
                controller: cc.messageController,
                textInputAction: TextInputAction.send,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: 'Type a message',
                  prefixIcon: IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _showEmoji.value = _showEmoji.value == 0 ? 1 : 0;
                    },
                    icon: Obx(
                      () => Icon(
                        Icons.face_outlined,
                        color: (_showEmoji.value == 1)
                            ? Colors.grey
                            : Colors.black,
                      ),
                    ),
                  ),
                  suffixIcon: IconButton(
                    color: Colors.black,
                    onPressed: () {
                      _imagePickerDialog(context);
                    },
                    icon: const Icon(Icons.image_outlined),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          ElevatedButton(
            onPressed: () {
              if (cc.messageController.text != "") {
                cc.sendPushMessage(
                  userData['push_token'],
                  userData['name'],
                  cc.messageController.text,
                  'Text',
                  chatId,
                  userData,
                );

                cc.sendMessage(
                  chatId,
                  cc.messageController.text,
                  'text',
                  chatKey,
                );

                _showEmoji.value = 0; // Dismiss emoji after sending
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14)),
            child: const RotationTransition(
                turns: AlwaysStoppedAnimation(315 / 360),
                child: Icon(Icons.send_rounded)),
          ),
        ],
      ),
    );
  }

  _imagePickerDialog(BuildContext context) {
    //Gives an option to pick image from camera or gallery
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  cc.sendImage('camera', chatId, chatKey);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(100),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 4),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                      child: Icon(Icons.camera_alt),
                    ),
                    Text(
                      'Camera',
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  cc.sendImage('gallery', chatId, chatKey);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(100),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(height: 4),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                      child: Icon(Icons.image_rounded),
                    ),
                    Text(
                      'Gallery',
                    ),
                    SizedBox(height: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
