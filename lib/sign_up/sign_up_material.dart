import "package:http/http.dart" as http;

import "package:edge_alerts/edge_alerts.dart" show Gravity, edgeAlert;
import "package:flutter/material.dart";
import "package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart"
    show ModalProgressHUD;

import "package:cc_chat/config.dart" as config;
import "package:cc_chat/widgets/custom_button.dart" show CustomButton;
import "package:cc_chat/widgets/custom_text_input.dart" show CustomTextInput;

class MaterialSignUpScreen extends StatefulWidget {
  const MaterialSignUpScreen({super.key});

  @override
  State<MaterialSignUpScreen> createState() => _MaterialSignUpScreenState();
}

class _MaterialSignUpScreenState extends State<MaterialSignUpScreen> {
  String? _email;
  String? _name;
  String? _password;
  bool _signingUp = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _signingUp,
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
                  hintText: "Name",
                  leading: Icons.text_format,
                  obscure: false,
                  userTyped: (value) {
                    _name = value;
                  },
                ),
                CustomTextInput(
                  hintText: "Email",
                  leading: Icons.mail,
                  keyboard: TextInputType.emailAddress,
                  obscure: false,
                  userTyped: (value) {
                    _email = value;
                  },
                ),
                CustomTextInput(
                  hintText: "Password",
                  leading: Icons.lock,
                  keyboard: TextInputType.visiblePassword,
                  obscure: true,
                  userTyped: (value) {
                    _password = value;
                  },
                ),
                const Spacer(
                  flex: 1,
                ),
                Hero(
                  tag: "sign_up_button",
                  child: CustomButton(
                    onpress: () async {
                      if ((_name != null) &&
                          (_password != null) &&
                          (_email != null)) {
                        setState(() {
                          _signingUp = true;
                        });
                        try {
                          final response = await http.post(
                              Uri.http(config.hostAddress, "/sign_up.php"),
                              body: {
                                "name": _name!,
                                "email": _email!,
                                "password": _password!
                              });

                          if ((response.statusCode == 200) &&
                              (response.body == "OK")) {
                            setState(() {
                              _signingUp = false;
                            });
                            if (mounted) {
                              Navigator.pushNamed(context, "/login");
                            }
                          } else {
                            throw "Sign up page status: ${response.statusCode} with response ${response.body}";
                          }
                        } catch (exception) {
                          setState(() {
                            _signingUp = false;
                          });
                          edgeAlert(context,
                              title: "Sign up Failed",
                              description: exception.toString(),
                              gravity: Gravity.bottom,
                              icon: Icons.error,
                              backgroundColor: Colors.deepPurple[900]);
                        }
                      } else {
                        edgeAlert(context,
                            title: "Sign up Failed",
                            description: "All fields are required.",
                            gravity: Gravity.bottom,
                            icon: Icons.error,
                            backgroundColor: Colors.deepPurple[900]);
                      }
                    },
                    text: "sign up",
                    accentColor: Colors.white,
                    mainColor: Colors.deepPurple,
                  ),
                ),
                const Spacer(
                  flex: 1,
                ),
                GestureDetector(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, "/login");
                    },
                    child: const Text(
                      "or log in instead",
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
