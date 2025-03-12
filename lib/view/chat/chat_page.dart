import 'dart:developer';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/controllers/chat_controller.dart';
import 'package:chat_app/controllers/group_controller.dart';
import 'package:chat_app/view/widgets/video_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants/colors.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../widgets/audio_message.dart';
import '../widgets/chat_info_dialog.dart';
import '../widgets/image_message.dart';
import '../widgets/pdf_message.dart';
import '../widgets/text_message.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

class ChatPage extends StatelessWidget {
  ChatPage({
    super.key,
    required this.userData,
    required this.chatData,
    required this.chatKey,
  });

  final List<Map> userData;
  final Map chatData;
  final int chatKey;

  final ChatController cc = Get.put(ChatController());
  final AuthController ac = Get.put(AuthController());
  final GroupController gc = Get.put(GroupController());

  final RxInt _showEmoji = 0.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    cc.getClientPermission();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ChatInfoDialog(
                      chatData: chatData,
                      userData: userData,
                    );
                  },
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  imageUrl: chatData['type'] == 'Group'
                      ? chatData['image']
                      : userData[0]['image'] ?? '',
                  height: 45,
                  width: 45,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => ColoredBox(
                    color: Colors.grey.shade300,
                    child: Icon(chatData['type'] == 'Group'
                        ? Icons.group_rounded
                        : Icons.person_rounded),
                  ),
                  placeholder: (context, url) => ColoredBox(
                    color: Colors.grey.shade300,
                    child: Icon(chatData['type'] == 'Group'
                        ? Icons.group_rounded
                        : Icons.person_rounded),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ChatInfoDialog(
                            chatData: chatData,
                            userData: userData,
                          );
                        },
                      );
                    },
                    child: Text(chatData['type'] == 'Group'
                        ? chatData['name']
                        : userData[0]['name'] ?? ''),
                  ),
                  chatData['type'] == 'Group'
                      ? Text(
                          "${chatData['users'].length} Members",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        )
                      : StreamBuilder(
                          stream: _firestore
                              .collection('Users')
                              .doc(userData[0]['id'])
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
              ),
            )
          ],
        ),
        actions: [
          chatData['type'] != "Group"
              ? IconButton(
                  onPressed: () {
                    reportDialog(context);
                  },
                  icon: const Icon(Icons.report_outlined),
                )
              : PopupMenuButton(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        onTap: () {
                          reportDialog(context);
                        },
                        child: const Text("Report"),
                      ),
                      PopupMenuItem(
                        onTap: () {
                          groupExit(context);
                        },
                        enabled: !chatData['admins'].contains(ac.uid.value),
                        child: const Text("Exit group"),
                      ),
                      PopupMenuItem(
                        onTap: () {
                          groupDelete(context, chatData['cid']);
                        },
                        enabled: chatData['admins'].contains(ac.uid.value),
                        child: const Text("Delete group"),
                      ),
                    ];
                  },
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
            Obx(
              () => ClipRRect(
                child: AnimatedContainer(
                  height: cc.selectedMsg.isEmpty ? 0 : 50,
                  duration: const Duration(milliseconds: 200),
                  color: primaryColor,
                  child: cc.selectedMsg.isEmpty
                      ? const SizedBox()
                      : Column(
                          children: [
                            const Divider(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    cc.selectedMsg.clear();
                                  },
                                  icon: const Icon(
                                    Icons.close_outlined,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Cancel",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                Visibility(
                                  //TODO: Limit deleting to own messages
                                  child: TextButton.icon(
                                    onPressed: () {
                                      cc.deleteMessages(chatData['cid']);
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    if (cc.selectedMsg.isNotEmpty) {
                                      forwardMessage(context);
                                    }
                                  },
                                  icon: const Icon(
                                    Icons.arrow_outward_rounded,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    "Forward",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),
            Expanded(
                child: Scrollbar(
              radius: const Radius.circular(50),
              interactive: true,
              child: FirestoreListView(
                query: _firestore
                    .collection('Chats')
                    .doc(chatData['cid'])
                    .collection('Messages')
                    .orderBy('time', descending: true),
                reverse: true,
                emptyBuilder: (context) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          "images/chat_new.png",
                          height: 200,
                          width: double.infinity,
                        ),
                        const Text("Send a message to start Chatting !"),
                      ],
                    ),
                  );
                },
                itemBuilder: (context, doc) {
                  var message = doc.data();

                  if (message['type'] == 'text') {
                    return TextMessage(
                      message: message,
                      chatKey: chatKey,
                      type: chatData['type'],
                    );
                  } else if (message['type'] == 'image') {
                    return imageMsg(
                      context,
                      message,
                      chatKey,
                      DateFormat('KK:mm a ')
                          .format(message['time'].toDate())
                          .toLowerCase(),
                      chatData['type'],
                    );
                  } else if (message['type'] == 'audio') {
                    return VoiceMessageWidget(
                      message: message,
                      mkey: chatKey,
                    );
                  } else if (message['type'] == 'video') {
                    return VideoMessage(
                      message: message,
                      chatKey: chatKey,
                      type: chatData['type'],
                    );
                  } else if (message['type'] == 'pdf') {
                    return PdfMessage(
                      message: message,
                      chatKey: chatKey,
                      type: chatData['type'],
                    );
                  } else if (message['type'] == 'deleted') {
                    return const SizedBox();
                  } else {
                    return const Text('Unsupported Message Type');
                  }
                },
              ),
            )),
            Obx(
              () => Visibility(
                visible:
                    cc.isMediaUploading.value | cc.isVoiceMessageSending.value,
                child: const LinearProgressIndicator(
                  color: primaryColor,
                ),
              ),
            ),
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
              child: Obx(
                () => TextField(
                  minLines: 1,
                  maxLines: 5,
                  controller: cc.messageController,
                  enabled: !cc.isRecording.value,
                  onSubmitted: (value) {
                    cc.sendPushMessage(
                      ac.userName.value,
                      cc.messageController.text,
                      chatData['cid'],
                      chatData['type'] == 'Normal'
                          ? userData[0]['push_token']
                          : "", //TODO
                    );
                    cc.sendMessage(chatData['cid'], value, 'text', chatKey);
                    _showEmoji.value = 0; // Dismiss emoji after sending
                  },
                  onTap: () {
                    if (_showEmoji.value == 1) {
                      _showEmoji.value = 0; // Hide emoji on tap
                    }
                  },
                  onChanged: (value) {
                    cc.messageText.value = value;
                  },
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    hintText: cc.isRecording.value
                        ? 'Recording audio...'
                        : 'Type a message...',
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
                        _attachmentPicker(context);
                      },
                      icon: const Icon(Icons.attach_file_rounded),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 2,
          ),
          Obx(
            () => Visibility(
              visible: cc.messageText.value != "",
              child: ElevatedButton(
                onPressed: () {
                  if (cc.messageController.text != "") {
                    cc.sendPushMessage(
                      ac.userName.value,
                      cc.messageController.text,
                      chatData['cid'],
                      chatData['type'] == 'Normal'
                          ? userData[0]['push_token']
                          : "", //TODO
                    );

                    cc.sendMessage(
                      chatData['cid'],
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
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Obx(
            () => Visibility(
              visible: cc.messageText.value == "",
              child: GestureDetector(
                onLongPress: () => cc.startVoiceRecording(),
                onLongPressEnd: (_) => cc.stopVoiceRecording(
                  chatData['cid'],
                  chatKey,
                  chatData['type'] == 'Normal'
                      ? userData[0]['push_token']
                      : "", //TODO
                  ac.userName.value,
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(14)),
                  child: Padding(
                    padding: EdgeInsets.all(cc.isRecording.value ? 4.0 : 0.0),
                    child: const Icon(
                      Icons.mic_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _attachmentPicker(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
              onTap: () {
                cc.sendMedia(
                  'image',
                  ImageSource.camera,
                  chatData['cid'],
                  chatKey,
                  chatData['type'] == 'Normal'
                      ? userData[0]['push_token']
                      : "", //TODO
                  ac.userName.value,
                );
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  CircleAvatar(
                    radius: 24,
                    foregroundColor: primaryColor,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.photo_camera_rounded),
                  ),
                  const Text(
                    ' Camera ',
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                cc.sendMedia(
                  'image',
                  ImageSource.gallery,
                  chatData['cid'],
                  chatKey,
                  chatData['type'] == 'Normal'
                      ? userData[0]['push_token']
                      : "", //TODO
                  ac.userName.value,
                );
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  CircleAvatar(
                    radius: 24,
                    foregroundColor: primaryColor,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.image_rounded),
                  ),
                  const Text(
                    ' Image ',
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                cc.sendMedia(
                  'video',
                  ImageSource.gallery,
                  chatData['cid'],
                  chatKey,
                  chatData['type'] == 'Normal'
                      ? userData[0]['push_token']
                      : "", //TODO
                  ac.userName.value,
                );
                Navigator.pop(context);
              },
              borderRadius: BorderRadius.circular(100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  CircleAvatar(
                    radius: 24,
                    foregroundColor: primaryColor,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.videocam_rounded),
                  ),
                  const Text(
                    ' Video ',
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.pop(context);
                cc.uploadPDF(
                  chatData['cid'],
                  chatKey,
                  ac.userName.value,
                  chatData['type'] == 'Normal'
                      ? userData[0]['push_token']
                      : "", //TODO
                );
              },
              borderRadius: BorderRadius.circular(100),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  CircleAvatar(
                    radius: 24,
                    foregroundColor: primaryColor,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.description_rounded),
                  ),
                  const Text(
                    'Document',
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void reportDialog(BuildContext context) {
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
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text("Report"),
          )
        ],
      ),
    );
  }

  void groupDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Group"),
          content: const Text(
              "Are you sure? once you delete the group? this action is not reversable."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                gc.deleteGroup(id);
              },
              style: ElevatedButton.styleFrom(elevation: 0),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  void groupExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Exit Group"),
          content: const Text(
              "Are you sure? once you exit the group? this action is not reversable."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("CANCEL"),
            ),
            ElevatedButton(
              onPressed: () {
                gc.exitGroup(chatData, _auth.currentUser!.uid);
                chatData['users'].remove(_auth.currentUser!.uid);
                Fluttertoast.showToast(msg: "Group exited");
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(elevation: 0),
              child: const Text("EXIT"),
            ),
          ],
        );
      },
    );
  }

  void forwardMessage(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Forward to"),
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
        content: SizedBox(
          height: 400,
          width: double.maxFinite,
          child: FirestoreListView.separated(
            query: _firestore
                .collection('Chats')
                .where('users', arrayContains: _auth.currentUser!.uid)
                .orderBy('last_update', descending: true),
            shrinkWrap: true,
            emptyBuilder: (context) =>
                const Center(child: Text('No Chats Found !')),
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Text('Something went wrong !'),
            ),
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey.withOpacity(0.1),
            ),
            itemBuilder: (context, doc) {
              final Map<String, dynamic> data = doc.data();

              if (data['type'] == 'Normal') {
                final RxString userName = "Loading...".obs;
                final RxString userImage = "".obs;
                final RxString userToken = "".obs;
                final RxString userPhone = "".obs;

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
                      userPhone.value = snapshot.data()!['phone'];
                    },
                  );
                } catch (e) {
                  log('ChatList Error: $e');
                }

                return InkWell(
                  onTap: () {
                    cc.forwardMessages(data, chatData['key']);
                    Navigator.pop(context);
                  },
                  child: Obx(
                    () => ListTile(
                      leading: ClipRRect(
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
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey.shade300,
                            child: const Icon(Icons.person_rounded),
                          ),
                        ),
                      ),
                      title: Text(userName.value),
                      subtitle: Text("+91 ${userPhone.value}"),
                    ),
                  ),
                );
              } else {
                return InkWell(
                  onTap: () {
                    cc.forwardMessages(data, chatData['key']);
                    Navigator.pop(context);
                  },
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
                    subtitle: Text("${data['users'].length} Members"),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
