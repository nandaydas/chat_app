import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ui_firestore/firebase_ui_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/controllers/group_controller.dart';

class CreateGroup extends StatelessWidget {
  CreateGroup({super.key});

  final GroupController gc = Get.put(GroupController());

  final RxBool searchOn = false.obs;
  final RxString searchTerm = "".obs;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => searchOn.value
            ? Card(
                child: TextFormField(
                  autofocus: true,
                  decoration: const InputDecoration(
                      prefixText: "  ",
                      border: InputBorder.none,
                      hintText: "Search"),
                  onChanged: (value) {
                    searchTerm.value = value;
                  },
                ),
              )
            : const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "New Group",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "Add members",
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              )),
        actions: [
          Obx(
            () => IconButton(
                onPressed: () {
                  searchOn.value = !searchOn.value;
                  searchTerm.value = "";
                },
                icon: Icon(searchOn.value
                    ? Icons.close_rounded
                    : Icons.search_rounded)),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (gc.selectedMembers.isEmpty) {
            Fluttertoast.showToast(msg: "At least 1 user must be selected");
          } else {
            showDialog(
              context: context,
              builder: (context) {
                return groupConfirmation(context);
              },
            );
          }
        },
        foregroundColor: Colors.white,
        child: const Icon(Icons.arrow_forward_rounded),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => Visibility(
              visible: gc.selectedMembers.isNotEmpty,
              child: Container(
                color: Colors.white,
                height: 100,
                width: double.infinity,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: gc.selectedMembers.length,
                  itemBuilder: (context, index) {
                    final Map user = gc.selectedMembers[index];
                    return InkWell(
                      onTap: () {
                        gc.selectedMembers.remove(user);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(left: 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: CachedNetworkImage(
                                      imageUrl: user['image'] ?? '',
                                      height: 50,
                                      width: 50,
                                      fit: BoxFit.cover,
                                      errorWidget: (context, url, error) =>
                                          ColoredBox(
                                              color: Colors.grey.shade300),
                                      placeholder: (context, url) => ColoredBox(
                                          color: Colors.grey.shade300),
                                    ),
                                  ),
                                ),
                                Obx(
                                  () => Visibility(
                                    visible: gc.selectedMembers.contains(user),
                                    child: const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor: Colors.grey,
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Text(user['name']),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Scrollbar(
              radius: const Radius.circular(50),
              interactive: true,
              child: Obx(
                () => searchTerm.value == ""
                    ? FirestoreListView(
                        shrinkWrap: true,
                        query: _firestore
                            .collection('Users')
                            .where('id', isNotEqualTo: _auth.currentUser!.uid),
                        padding: const EdgeInsets.only(top: 6),
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                          child: Text("Something went wrong"),
                        ),
                        loadingBuilder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        emptyBuilder: (context) => const Center(
                          child: Text("No users founc"),
                        ),
                        itemBuilder: (context, doc) {
                          var user = doc.data();

                          return !user['name']
                                  .toLowerCase()
                                  .contains(searchTerm.toLowerCase())
                              ? const SizedBox()
                              : userCard(context, user);
                        },
                      )
                    : FirestoreListView(
                        shrinkWrap: true,
                        query: _firestore
                            .collection('Users')
                            .where('id', isNotEqualTo: _auth.currentUser!.uid),
                        padding: const EdgeInsets.only(top: 6),
                        errorBuilder: (context, error, stackTrace) =>
                            const Center(
                          child: Text("Something went wrong"),
                        ),
                        loadingBuilder: (context) => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        emptyBuilder: (context) => const Center(
                          child: Text("No users founc"),
                        ),
                        itemBuilder: (context, doc) {
                          var user = doc.data();

                          return !user['name']
                                  .toLowerCase()
                                  .contains(searchTerm.toLowerCase())
                              ? const SizedBox()
                              : userCard(context, user);
                        },
                      ),
              ),
            ),
          ),
        ],
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
        onTap: () {
          if (gc.selectedMembers.contains(user)) {
            gc.selectedMembers.remove(user);
          } else {
            gc.selectedMembers.add(user);
          }
        },

        //TODO: bug, user can be added multiple times when searched
        borderRadius: BorderRadius.circular(14),
        child: ListTile(
          leading: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: ClipRRect(
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
              ),
              Obx(
                () => Visibility(
                  visible: gc.selectedMembers.contains(user),
                  child: const Positioned(
                    right: 0,
                    bottom: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: primaryColor,
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          title: Text(user['name'] ?? ''),
          subtitle: Text("+91 ${user['phone']}"),
        ),
      ),
    );
  }

  Widget groupConfirmation(BuildContext context) {
    return AlertDialog(
      title: const Text("New Group"),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8.0),
          TextFormField(
            controller: gc.groupName,
            decoration: const InputDecoration(
              labelText: "Group name",
              border: OutlineInputBorder(),
            ),
            maxLength: 100,
          ),
          const SizedBox(height: 8.0),
          Text("Selected Members: ${gc.selectedMembers.length}")
        ],
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
            gc.createGroup();
          },
          style: ElevatedButton.styleFrom(elevation: 0),
          child: const Text("Create"),
        ),
      ],
    );
  }
}
