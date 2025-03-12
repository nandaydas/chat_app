import 'package:chat_app/constants/colors.dart';
import 'package:chat_app/controllers/auth_controller.dart';
import 'package:chat_app/controllers/home_controller.dart';
import 'package:chat_app/view/home/chat_list.dart';
import 'package:chat_app/view/home/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyHomePage extends StatelessWidget {
  MyHomePage({super.key});

  final HomeController hc = Get.put(HomeController());
  final AuthController ac = Get.put(AuthController());

  final List screenList = [
    ChatList(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    ac.getUserData();
    return Scaffold(
      body: Obx(
        () => screenList[hc.currentTab.value],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () async {
      //     final url = Uri.parse(services);
      //     if (await canLaunchUrl(url)) {
      //       await launchUrl(
      //         url,
      //         mode: LaunchMode.externalApplication,
      //       );
      //     } else {
      //       Fluttertoast.showToast(msg: 'Something went wrong !');
      //     }
      //   },
      //   heroTag: 'Services',
      //   icon: const Icon(Icons.open_in_new_rounded),
      //   label: const Text('Services'),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          child: NavigationBar(
            height: 64,
            backgroundColor: Colors.white,
            selectedIndex: hc.currentTab.value,
            onDestinationSelected: (value) {
              hc.currentTab.value = value;
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.chat_outlined),
                selectedIcon: Icon(
                  Icons.chat_rounded,
                  color: primaryColor,
                ),
                label: 'Chats',
              ),
              NavigationDestination(
                icon: Icon(Icons.account_circle_outlined),
                selectedIcon: Icon(
                  Icons.account_circle_rounded,
                  color: primaryColor,
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
