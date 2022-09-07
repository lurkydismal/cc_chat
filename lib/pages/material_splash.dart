import "package:cc_chat/widgets/custombutton.dart" show CustomButton;
import "package:flutter/material.dart";
import "package:animated_text_kit/animated_text_kit.dart"
    show AnimatedTextKit, TyperAnimatedText;

class ChatterHome extends StatefulWidget {
  const ChatterHome({super.key});

  @override
  State<ChatterHome> createState() => _ChatterHomeState();
}

class _ChatterHomeState extends State<ChatterHome>
    with TickerProviderStateMixin {
  late AnimationController mainController;
  late Animation mainAnimation;
  @override
  void initState() {
    super.initState();
    mainController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    mainAnimation =
        ColorTween(begin: Colors.deepPurple[900], end: Colors.grey[100])
            .animate(mainController);
    mainController.forward();
    mainController.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainAnimation.value,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Hero(
                tag: "heroicon",
                child: Icon(
                  Icons.textsms,
                  size: mainController.value * 100,
                  color: Colors.deepPurple[900],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              Hero(
                tag: "HeroTitle",
                child: Text(
                  "Chatter",
                  style: TextStyle(
                      color: Colors.deepPurple[900],
                      fontFamily: "Poppins",
                      fontSize: 26,
                      fontWeight: FontWeight.w700),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    "World's most private chatting app".toUpperCase(),
                    speed: const Duration(milliseconds: 60),
                    textStyle: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 12,
                        color: Colors.deepPurple),
                  )
                ],
                isRepeatingAnimation: false,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
              ),
              Hero(
                tag: "loginbutton",
                child: CustomButton(
                  text: "Login",
                  accentColor: Colors.white,
                  mainColor: Colors.deepPurple,
                  onpress: () {
                    Navigator.pushReplacementNamed(context, "/login");
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Hero(
                tag: "signupbutton",
                child: CustomButton(
                  text: "Sign up",
                  accentColor: Colors.white,
                  mainColor: Colors.deepPurple,
                  onpress: () {
                    Navigator.pushReplacementNamed(context, "/sign_up");
                  },
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              ),
              const Text("Made with ♥ by ur mom")
            ],
          ),
        ),
      ),
    );
  }
}
