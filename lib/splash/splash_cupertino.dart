import "package:flutter/cupertino.dart";

import "package:animated_text_kit/animated_text_kit.dart"
    show AnimatedTextKit, TyperAnimatedText;

import "package:cc_chat/widgets/custom_button.dart";
import "package:cc_chat/config.dart" as config;

class CupertinoSplashScreen extends StatefulWidget {
  const CupertinoSplashScreen({super.key});

  @override
  State<CupertinoSplashScreen> createState() => _CupertinoSplashScreenState();
}

class _CupertinoSplashScreenState extends State<CupertinoSplashScreen>
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
    _mainAnimation = ColorTween(
            begin: CupertinoColors.systemBlue, end: CupertinoColors.systemGrey5)
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
      child: SafeArea(
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
                  CupertinoIcons.text_bubble_fill,
                  size: (_mainController.value * 100),
                  color: CupertinoColors.systemBlue,
                ),
              ),
              const Spacer(
                flex: 2,
              ),
              const Hero(
                tag: "chat_app_title",
                child: Text(
                  config.title,
                  style: TextStyle(
                      color: CupertinoColors.systemBlue,
                      fontFamily: config.fontFamily,
                      fontSize: 26,
                      fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(
                flex: 1,
              ),
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    "World's most simple chatting app".toUpperCase(),
                    speed: const Duration(milliseconds: 60),
                    textStyle: const TextStyle(
                        fontFamily: config.fontFamily,
                        fontSize: 12,
                        color: CupertinoColors.systemBlue),
                  )
                ],
                isRepeatingAnimation: false,
              ),
              const Spacer(
                flex: 10,
              ),
              Hero(
                tag: "login_button",
                child: CustomButton(
                  text: "Login",
                  accentColor: CupertinoColors.white,
                  mainColor: CupertinoColors.systemBlue,
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
                  accentColor: CupertinoColors.white,
                  mainColor: CupertinoColors.systemBlue,
                  onpress: () {
                    Navigator.pushReplacementNamed(context, "/sign_up");
                  },
                ),
              ),
              const Spacer(
                flex: 1,
              ),
              const Hero(
                tag: "copyright",
                child: Text(
                  "Made by LurkyDismal",
                  style: TextStyle(fontFamily: config.fontFamily),
                ),
              ),
              const Spacer(
                flex: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
