// import "package:cc_chat/pages/chat.dart";
import "package:cc_chat/pages/login.dart" show ChatterLogin;
import 'package:cc_chat/pages/sign_up.dart' show ChatterSignUp;
import "package:flutter/material.dart";
import "package:cc_chat/pages/chatter_screen.dart" show ChatterScreen;
import "pages/material_splash.dart" show ChatterHome;

Future<void> main() async {
  runApp(const ChatterApp());
}

class ChatterApp extends StatelessWidget {
  const ChatterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Chatter",
      theme: ThemeData(
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
            fontFamily: "Poppins",
          ),
        ),
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => const ChatterHome(),
        "/login": (context) => const ChatterLogin(),
        "/sign_up": (context) => const ChatterSignUp(),
        "/chat": (context) => const ChatterScreen(),
        // "/chats":(context) => ChatterScreen()
      },
    );
  }
}
