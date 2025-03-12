import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/controllers/group_controller.dart';
import 'package:chat_app/view/widgets/add_group_member.dart';

class ChatInfoDialog extends StatelessWidget {
  ChatInfoDialog({super.key, required this.chatData, required this.userData});

  final GroupController gc = Get.put(GroupController());
  final AuthController ac = Get.put(AuthController());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map> userData;
  final Map chatData;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor,
                width: 2,
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: CachedNetworkImage(
                imageUrl: chatData['type'] == 'Group'
                    ? chatData['image']
                    : userData[0]['image'] ?? '',
                height: 65,
                width: 65,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey.shade300,
                  child: Icon(chatData['type'] == 'Group'
                      ? Icons.group_rounded
                      : Icons.person_rounded),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade300,
                  child: Icon(chatData['type'] == 'Group'
                      ? Icons.group_rounded
                      : Icons.person_rounded),
                ),
              ),
            ),
          ),
          Text(
            chatData['type'] == 'Group'
                ? chatData['name']
                : userData[0]['name'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          chatData['type'] == 'Group'
              ? Column(
                  children: [
                    Text(
                      "Group Created ${DateFormat('d MMM hh:mm a').format(chatData['date_created'].toDate())}",
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "${chatData['users'].length} Members",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const Divider(),
                    groupMemberList(),
                  ],
                )
              : StreamBuilder(
                  stream: _firestore
                      .collection('Users')
                      .doc(userData[0]['id'])
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          Text(
                            "${snapshot.data!['email']}",
                            style: const TextStyle(fontSize: 12),
                          ),
                          snapshot.data!['is_active']
                              ? const Text(
                                  '● Online',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              : Text(
                                  "Last active ${DateFormat('d MMM hh:mm a').format(snapshot.data!['last_active'].toDate())}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return const Text(
                        'Something went wrong !',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      );
                    } else {
                      return const Text(
                        'Loading...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      );
                    }
                  },
                ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
        chatData['type'] == 'Group'
            ? Visibility(
                visible: ac.userType.value == "Admin",
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AddGroupMember(
                          chatData: chatData,
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(elevation: 0),
                  child: const Text("Add Members"),
                ),
              )
            : const SizedBox()
      ],
    );
  }

  Widget groupMemberList() {
    return SizedBox(
      width: double.maxFinite,
      height: 200,
      child: Scrollbar(
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: chatData['users'].length,
          itemBuilder: (context, index) {
            final RxMap userData = {}.obs;

            _firestore
                .collection("Users")
                .doc(chatData['users'][index])
                .get()
                .then(
              (snapshot) {
                userData.value = snapshot.data() as Map;
              },
            );

            return Obx(
              () => ListTile(
                dense: true,
                title: Text(
                  userData['name'] ?? 'Loading...',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text("${userData['email']}"),
                trailing: ac.userType.value == "Admin"
                    ? TextButton(
                        onPressed: () {
                          if (userData['id'] == ac.uid.value) {
                            null;
                          } else {
                            gc.exitGroup(chatData, userData['id']);
                            chatData['users'].remove(userData['id']);
                            Fluttertoast.showToast(msg: "Member removed");
                          }
                        },
                        child: Text(
                          "Remove",
                          style: TextStyle(
                              color: userData['id'] == ac.uid.value
                                  ? Colors.grey
                                  : Colors.red),
                        ),
                      )
                    : const SizedBox(),
              ),
            );
          },
        ),
      ),
    );
  }
}
