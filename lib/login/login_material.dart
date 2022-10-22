import "package:flutter/material.dart";
import "package:http/http.dart" as http;

import "package:edge_alerts/edge_alerts.dart" show Gravity, edgeAlert;
import "package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart"
    show ModalProgressHUD;

import "package:cc_chat/config.dart" as config;
import "package:cc_chat/user.dart";
import "package:cc_chat/widgets/custom_button.dart" show CustomButton;
import "package:cc_chat/widgets/custom_text_input.dart" show CustomTextInput;

class MaterialLoginScreen extends StatefulWidget {
  const MaterialLoginScreen({super.key});

  @override
  State<MaterialLoginScreen> createState() => _MaterialLoginScreenState();
}

class _MaterialLoginScreenState extends State<MaterialLoginScreen> {
  String? _email;
  String? _password;
  bool _loggingIn = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _loggingIn,
      child: Scaffold(
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
                    size: 120,
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
                  child: Text(
                    "World's most private chatting app".toUpperCase(),
                    style: const TextStyle(
                        fontFamily: config.fontFamily,
                        fontSize: 12,
                        color: Colors.deepPurple),
                  ),
                ),
                const Spacer(
                  flex: 2,
                ),
                CustomTextInput(
                  hintText: "Email",
                  leading: Icons.mail,
                  obscure: false,
                  keyboard: TextInputType.emailAddress,
                  userTyped: (val) {
                    _email = val;
                  },
                ),
                CustomTextInput(
                  hintText: "Password",
                  leading: Icons.lock,
                  obscure: true,
                  userTyped: (val) {
                    _password = val;
                  },
                ),
                const Spacer(
                  flex: 1,
                ),
                Hero(
                  tag: "login_button",
                  child: CustomButton(
                    text: "login",
                    accentColor: Colors.white,
                    mainColor: Colors.deepPurple,
                    onpress: () async {
                      if ((_password != null) && (_email != null)) {
                        setState(() {
                          _loggingIn = true;
                        });
                        try {
                          final response = await http.post(
                              Uri.http(config.hostAddress, "/login.php"),
                              body: {"email": _email!, "password": _password!});

                          if ((response.statusCode == 200) &&
                              (response.body != "")) {
                            setState(() {
                              _loggingIn = false;
                            });
                            if (mounted) {
                              final userData = response.body.split("|");
                              User.id = int.parse(userData[0]);
                              User.displayName = userData[1];
                              User.email = userData[2];
                              User.isActive = true;
                              debugPrint("Current user id: ${User.id}");
                              debugPrint(
                                  "Current user name: ${User.displayName}");
                              debugPrint("Current user email: ${User.email}");
                              Navigator.pushNamed(context, "/chat");
                            }
                          } else {
                            throw "Sign up page status: ${response.statusCode} with response ${response.body}";
                          }
                        } catch (exception) {
                          setState(() {
                            _loggingIn = false;
                          });
                          edgeAlert(context,
                              title: "Login Failed",
                              description: exception.toString(),
                              gravity: Gravity.bottom,
                              icon: Icons.error,
                              backgroundColor: Colors.deepPurple[900]);
                        }
                      } else {
                        edgeAlert(context,
                            title: "Uh oh!",
                            description: "Please enter the email and password.",
                            gravity: Gravity.bottom,
                            icon: Icons.error,
                            backgroundColor: Colors.deepPurple[900]);
                      }
                    },
                  ),
                ),
                const Spacer(
                  flex: 1,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, "/sign_up");
                    },
                    child: const Text(
                      "or create an account",
                      style: TextStyle(
                          fontFamily: config.fontFamily,
                          fontSize: 12,
                          color: Colors.deepPurple),
                    )),
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
      ),
    );
  }
}
