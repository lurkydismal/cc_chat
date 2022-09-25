import "package:cc_chat/widgets/custombutton.dart" show CustomButton;
import "package:cc_chat/widgets/customtextinput.dart" show CustomTextInput;
import "package:edge_alerts/edge_alerts.dart" show Gravity, edgeAlert;
import "package:http/http.dart" as http;
import "package:cc_chat/config.dart" as config;
import "package:cc_chat/user.dart";
import "package:flutter/material.dart";
import "package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart"
    show ModalProgressHUD;

class ChatterLogin extends StatefulWidget {
  const ChatterLogin({super.key});

  @override
  State<ChatterLogin> createState() => _ChatterLoginState();
}

// class _ChatterLoginState extends State<ChatterLogin> {
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }

class _ChatterLoginState extends State<ChatterLogin> {
  String? email;
  String? password;
  bool loggingin = false;
  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: loggingin,
      child: Scaffold(
        // backgroundColor: Colors.transparent,
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
                    hintText: "Email",
                    leading: Icons.mail,
                    obscure: false,
                    keyboard: TextInputType.emailAddress,
                    userTyped: (val) {
                      email = val;
                    },
                  ),
                  const SizedBox(
                    height: 0,
                  ),
                  CustomTextInput(
                    hintText: "Password",
                    leading: Icons.lock,
                    obscure: true,
                    userTyped: (val) {
                      password = val;
                    },
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Hero(
                    tag: "loginbutton",
                    child: CustomButton(
                      text: "login",
                      accentColor: Colors.white,
                      mainColor: Colors.deepPurple,
                      onpress: () async {
                        if (password != null && email != null) {
                          setState(() {
                            loggingin = true;
                          });
                          try {
                            final response = await http.post(
                                Uri.http(config.hostAddress, "/login.php"),
                                body: {"email": email!, "password": password!});

                            if ((response.statusCode == 200) &&
                                (response.body != "")) {
                              setState(() {
                                loggingin = false;
                              });
                              if (mounted) {
                                final userData = response.body.split("|");
                                User.id = int.parse(userData[0]);
                                User.displayName = userData[1];
                                User.email = userData[2];
                                debugPrint("Current user id: ${User.id}");
                                debugPrint("Current user name: ${User.displayName}");
                                debugPrint("Current user email: ${User.email}");
                                Navigator.pushNamed(context, "/chat");
                              }
                            } else {
                              throw "Sign up page status: ${response.statusCode} with response ${response.body}";
                            }
                          } catch (e) {
                            setState(() {
                              loggingin = false;
                            });
                            edgeAlert(context,
                                title: "Login Failed",
                                description: e.toString(),
                                gravity: Gravity.bottom,
                                icon: Icons.error,
                                backgroundColor: Colors.deepPurple[900]);
                          }
                        } else {
                          edgeAlert(context,
                              title: "Uh oh!",
                              description:
                                  "Please enter the email and password.",
                              gravity: Gravity.bottom,
                              icon: Icons.error,
                              backgroundColor: Colors.deepPurple[900]);
                        }
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, "/sign_up");
                      },
                      child: const Text(
                        "or create an account",
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
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
