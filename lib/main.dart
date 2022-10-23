// import "dart:io" show Platform;

// import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";

// import "package:chat_app/chat/chat_cupertino.dart";
import "package:chat_app/chat/chat_material.dart";
import "package:chat_app/config.dart" as config;
// import "package:chat_app/login/login_cupertino.dart";
import "package:chat_app/login/login_material.dart";
// import "package:chat_app/sign_up/sign_up_cupertino.dart";
import "package:chat_app/sign_up/sign_up_material.dart";
// import "package:chat_app/splash/splash_cupertino.dart";
import "package:chat_app/splash/splash_material.dart";

void main() {
  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
  //   if (Platform.isIOS || Platform.isMacOS) {
  //     return CupertinoApp(
  //       title: config.title,
  //       // theme: MaterialBasedCupertinoThemeData(
  //       //   materialTheme: getMaterialThemeData,
  //       // ),
  //       initialRoute: "/",
  //       routes: getPlatformSpecificRoutes,
  //     );
  //   } else {
      return MaterialApp(
        title: config.title,
        // theme: getMaterialThemeData,
        initialRoute: "/",
        routes: getPlatformSpecificRoutes,
      );
    // }
  }
}

ThemeData get getMaterialThemeData {
  return ThemeData.localize(
    ThemeData.dark(),
    Typography.englishLike2021.merge(Typography.blackRedmond).copyWith(
          bodyLarge: const TextStyle(
            fontFamily: config.fontFamily,
          ),
        ),
  );
}

Map<String, WidgetBuilder> get getPlatformSpecificRoutes {
  // if (Platform.isIOS || Platform.isMacOS) {
  //   return {
  //     // "/": (context) => const CupertinoSplashScreen(),
  //     // "/login": (context) => const CupertinoLoginScreen(),
  //     // "/sign_up": (context) => const CupertinoSignUpScreen(),
  //     // "/chat": (context) => const CupertinoChatScreen(),
  //   };
  // } else {
    return {
      "/": (context) => const MaterialSplashScreen(),
      "/login": (context) => const MaterialLoginScreen(),
      "/sign_up": (context) => const MaterialSignUpScreen(),
      "/chat": (context) => const MaterialChatScreen(),
    };
  // }
}
