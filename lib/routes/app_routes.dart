import 'package:chat_app/routes/route_names.dart';
import 'package:chat_app/splash_screen.dart';
import 'package:chat_app/view/auth/edit_profile.dart';
import 'package:chat_app/view/auth/forget_password_page.dart';
import 'package:chat_app/view/auth/login_page.dart';
import 'package:chat_app/view/auth/register_page.dart';
import 'package:chat_app/view/chat/chat_page.dart';
import 'package:chat_app/view/chat/user_list.dart';
import 'package:chat_app/view/chat/video_player.dart';
import 'package:chat_app/view/home/home_page.dart';
import 'package:get/get.dart';
import '../view/chat/image_viewer.dart';
import '../view/notification_page.dart';

class AppRoutes {
  static appRoutes() => [
        GetPage(
          name: RouteNames.homeScreen,
          page: () => MyHomePage(),
        ),
        GetPage(
          name: RouteNames.splashScreen,
          page: () => SplashScreen(),
        ),
        GetPage(
          name: RouteNames.loginScreen,
          page: () => Mylogin(),
        ),
        GetPage(
          name: RouteNames.registerScreen,
          page: () => RegisterPage(),
        ),
        GetPage(
          name: RouteNames.passwordForget,
          page: () => ForgetPassowrd(),
        ),
        GetPage(
          name: RouteNames.editProfile,
          page: () => EditProfile(),
        ),
        GetPage(
          name: RouteNames.chatScreen,
          page: () => ChatPage(
            userData: Get.arguments[0],
            chatId: Get.arguments[1],
            chatKey: Get.arguments[2],
          ),
        ),
        GetPage(
          name: RouteNames.notificationPage,
          page: () => const NotificationPage(),
        ),
        GetPage(
          name: RouteNames.userList,
          page: () => UserList(),
        ),
        GetPage(
          name: RouteNames.imageViewer,
          page: () => ImageViewer(
            imageUrl: Get.arguments[0],
            senderName: Get.arguments[1],
            timeStamp: Get.arguments[2],
          ),
        ),
        GetPage(
          name: RouteNames.videoPlayer,
          page: () => VideoPlayer(
            videoUrl: Get.arguments[0],
            senderName: Get.arguments[1],
            timeStamp: Get.arguments[2],
          ),
        ),
      ];
}
