import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat_app/constants/links.dart';
import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class MyDrawer extends StatelessWidget {
  MyDrawer({super.key});

  final AuthController ac = Get.put(AuthController());
  final HomeController hc = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Obx(
                        () => CachedNetworkImage(
                          imageUrl: ac.userImage.value,
                          height: 65,
                          width: 65,
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
                                color: primaryColor,
                                fontFamily: 'Sarabun',
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(
                            () => Text(
                              ac.userEmail.value,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontFamily: 'Sarabun',
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    border: Border.all(width: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      " JCF Communication",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    listItem(
                      'My Profile',
                      Icons.account_circle_outlined,
                      () {
                        hc.currentTab.value = 1;
                        Navigator.pop(context);
                      },
                    ),
                    listItem('Contact Support', Icons.chat_outlined, () async {
                      final url = Uri.parse(contactUrl);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        Fluttertoast.showToast(msg: 'Something went wrong !');
                      }
                    }),
                    listItem('Services', Icons.open_in_new, () async {
                      final url = Uri.parse(services);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        Fluttertoast.showToast(msg: 'Something went wrong !');
                      }
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    border: Border.all(width: 0.1),
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      ' APP',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    listItem('Share this App', Icons.share_outlined, () {
                      Share.share(
                          'Follow this link to download Jasda Care Family Android Application: $rateUs',
                          subject: 'Share Application');
                    }),
                    listItem('Rate Us', Icons.star_outline, () async {
                      final url = Uri.parse(rateUs);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        Fluttertoast.showToast(msg: 'Something went wrong !');
                      }
                    }),
                    listItem('About us', Icons.info_outline, () async {
                      final url = Uri.parse(aboutUs);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        Fluttertoast.showToast(msg: 'Something went wrong !');
                      }
                    }),
                    listItem('Privacy Policy', Icons.lock_outline, () async {
                      final url = Uri.parse(privacyPolicy);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        Fluttertoast.showToast(msg: 'Something went wrong !');
                      }
                    }),
                    listItem(
                      'Logout',
                      Icons.logout_outlined,
                      () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Are you sure ?'),
                            actions: [
                              TextButton(
                                onPressed: () => ac.logOut(context),
                                child: const Text('LOGOUT'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('CANCEL'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Version 1.0.0',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget listItem(String title, IconData icon, Function action) {
    return InkWell(
      onTap: () => action(),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Icon(
              icon,
              size: 24,
              color: Colors.grey,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }
}
