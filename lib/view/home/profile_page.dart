import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/controllers/home_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../constants/colors.dart';
import '../../constants/links.dart';
import '../auth/edit_profile.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final AuthController ac = Get.put(AuthController());
  final HomeController hc = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontFamily: 'Sarabun', fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            hc.currentTab.value = 0;
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Container(
                height: height * 0.14,
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xff4C92C9),
                        Color(0xff1a3975),
                      ]),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Obx(
                        () => CachedNetworkImage(
                          imageUrl: ac.userImage.value,
                          height: 75,
                          width: 75,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              ColoredBox(color: Colors.grey.shade300),
                          placeholder: (context, url) =>
                              ColoredBox(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(
                            () => Text(
                              ac.userName.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              ac.userEmail.value,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            listItem(
              () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => EditProfile(),
                  ),
                );
              },
              'Edit Profile',
              Icons.edit_outlined,
            ),
            listItem(
              () {
                Share.share(
                    'Follow this link to download Jasda Care Family Android Application: $rateUs',
                    subject: 'Share Application');
              },
              "Invite a Friend",
              CupertinoIcons.person_add,
            ),
            listItem(
              () async {
                final url = Uri.parse(contactUrl);
                if (await canLaunchUrl(url)) {
                  await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  Fluttertoast.showToast(msg: 'Something went wrong !');
                }
              },
              "Help and Support",
              CupertinoIcons.chat_bubble_2,
            ),
            listItem(
              () async {
                final url = Uri.parse(termsofUse);
                if (await canLaunchUrl(url)) {
                  await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  Fluttertoast.showToast(msg: 'Something went wrong !');
                }
              },
              "Terms of Use",
              CupertinoIcons.archivebox,
            ),
            listItem(
              () async {
                final url = Uri.parse(privacyPolicy);
                if (await canLaunchUrl(url)) {
                  await launchUrl(
                    url,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  Fluttertoast.showToast(msg: 'Something went wrong !');
                }
              },
              "Privacy Policy",
              CupertinoIcons.lock,
            ),
            listItem(
              () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Logout'),
                      content: const Text('Are you sure?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            ac.logOut(context);
                          },
                          child: const Text('Logout'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Cancel'),
                        ),
                      ],
                    );
                  },
                );
              },
              'Logout',
              Icons.exit_to_app_outlined,
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                SizedBox(width: 20),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'Sarabun',
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget listItem(action, String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [backgroundColor, Colors.white, backgroundColor])),
      child: InkWell(
        onTap: action,
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
            ),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                fontFamily: 'Sarabun',
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.grey,
              size: 20,
            )
          ],
        ),
      ),
    );
  }
}
