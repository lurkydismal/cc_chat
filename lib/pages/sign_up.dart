import "package:cc_chat/widgets/custombutton.dart" show CustomButton;
import "package:cc_chat/widgets/customtextinput.dart" show CustomTextInput;
import "package:edge_alerts/edge_alerts.dart" show Gravity, edgeAlert;
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "package:cc_chat/config.dart" as config;
import "package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart"
    show ModalProgressHUD;

class ChatterSignUp extends StatefulWidget {
  const ChatterSignUp({super.key});

  @override
  State<ChatterSignUp> createState() => _ChatterSignUpState();
}

class _ChatterSignUpState extends State<ChatterSignUp> {
  String? email;
  String? password;
  String? name;
  bool signingup = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: signingup,
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            // margin: EdgeInsets.only(top:MediaQuery.of(context).size.height*0.2),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Hero(
                    tag: "heroicon",
                    child: Icon(
                      Icons.textsms,
                      size: 120,
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
                  // Text(
                  //   "World"s most private chatting app".toUpperCase(),
                  //   style: TextStyle(
                  //       fontFamily: "Poppins",
                  //       fontSize: 12,
                  //       color: Colors.deepPurple),
                  // ),
                  CustomTextInput(
                    hintText: "Name",
                    leading: Icons.text_format,
                    obscure: false,
                    userTyped: (value) {
                      name = value;
                    },
                  ),
                  const SizedBox(
                    height: 0,
                  ),
                  const SizedBox(
                    height: 0,
                  ),
                  CustomTextInput(
                    hintText: "Email",
                    leading: Icons.mail,
                    keyboard: TextInputType.emailAddress,
                    obscure: false,
                    userTyped: (value) {
                      email = value;
                    },
                  ),
                  const SizedBox(
                    height: 0,
                  ),
                  CustomTextInput(
                    hintText: "Password",
                    leading: Icons.lock,
                    keyboard: TextInputType.visiblePassword,
                    obscure: true,
                    userTyped: (value) {
                      password = value;
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Hero(
                    tag: "signupbutton",
                    child: CustomButton(
                      onpress: () async {
                        if (name != null && password != null && email != null) {
                          setState(() {
                            signingup = true;
                          });
                          try {
                            final response = await http.post(
                                Uri.http(config.hostAddress, "/sign_up.php"),
                                body: {
                                  "name": name!,
                                  "email": email!,
                                  "password": password!
                                });

                            if ((response.statusCode == 200) &&
                                (response.body == "OK")) {
                              setState(() {
                                signingup = false;
                              });
                              if (mounted) {
                                Navigator.pushNamed(context, "/login");
                              }
                            } else {
                              throw "Sign up page status: ${response.statusCode} with response ${response.body}";
                            }
                          } catch (error) {
                            setState(() {
                              signingup = false;
                            });
                            edgeAlert(context,
                                title: "Sign up Failed",
                                description: error.toString(),
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
                  const SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, "/login");
                      },
                      child: const Text(
                        "or log in instead",
                        style: TextStyle(
                            fontFamily: "Poppins",
                            fontSize: 12,
                            color: Colors.deepPurple),
                      )),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  const Hero(
                    tag: "footer",
                    child: Text(
                      "Made by LurkyDismal",
                      style: TextStyle(fontFamily: "Poppins"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
