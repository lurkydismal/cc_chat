import "package:flutter/material.dart";

import "package:animated_text_kit/animated_text_kit.dart"
    show AnimatedTextKit, TyperAnimatedText;

import "package:cc_chat/widgets/custom_button.dart";
import "package:cc_chat/config.dart" as config;

class MaterialSplashScreen extends StatefulWidget {
  const MaterialSplashScreen({super.key});

  @override
  State<MaterialSplashScreen> createState() => _MaterialSplashScreenState();
}

class _MaterialSplashScreenState extends State<MaterialSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation _mainAnimation;
  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration:
          const Duration(milliseconds: config.splashScreenAnimationDuration),
      vsync: this,
    );
    _mainAnimation =
        ColorTween(begin: Colors.deepPurple[900], end: Colors.grey[100])
            .animate(_mainController);
    _mainController.forward();
    _mainController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _mainAnimation.value,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Spacer(
                flex: 12,
              ),
              Hero(
                tag: "chat_app_logo",
                child: Icon(
                  Icons.textsms,
                  size: (_mainController.value * 100),
                  color: Colors.deepPurple[900],
                ),
              ),
              const Spacer(
                flex: 2,
              ),
              Hero(
                tag: "chat_app_title",
                child: Text(
                  config.title,
                  style: TextStyle(
                      color: Colors.deepPurple[900],
                      fontFamily: config.fontFamily,
                      fontSize: 26,
                      fontWeight: FontWeight.w700),
                ),
              ),
              Hero(
                tag: "phrase",
                child: AnimatedTextKit(
                  animatedTexts: [
                    TyperAnimatedText(
                      "World's most simple chatting app".toUpperCase(),
                      speed: const Duration(milliseconds: 60),
                      textStyle: const TextStyle(
                          fontFamily: config.fontFamily,
                          fontSize: 12,
                          color: Colors.deepPurple),
                    )
                  ],
                  isRepeatingAnimation: false,
                ),
              ),
              const Spacer(
                flex: 10,
              ),
              Hero(
                tag: "login_button",
                child: CustomButton(
                  text: "Login",
                  accentColor: Colors.white,
                  mainColor: Colors.deepPurple,
                  onpress: () {
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                ),
              ),
              const Spacer(
                flex: 1,
              ),
              Hero(
                tag: "sign_up_button",
                child: CustomButton(
                  text: "Sign up",
                  accentColor: Colors.white,
                  mainColor: Colors.deepPurple,
                  onpress: () {
                    Navigator.pushReplacementNamed(context, "/sign_up");
                  },
                ),
              ),
              const Spacer(
                flex: 8,
              ),
              const Hero(
                tag: "copyright",
                child: Text(
                  "Made by LurkyDismal",
                  style: TextStyle(fontFamily: config.fontFamily),
                ),
              ),
              const Spacer(
                flex: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
