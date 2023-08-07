import "package:edge_alerts/edge_alerts.dart";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;

import "package:chat_app/config.dart" as config;
import "package:chat_app/chat/chat_stream.dart";
import "package:chat_app/user.dart";

class MaterialChatScreen extends StatefulWidget {
  const MaterialChatScreen({super.key});

  @override
  State<MaterialChatScreen> createState() => _MaterialChatScreenState();
}

class _MaterialChatScreenState extends State<MaterialChatScreen> {
  final _chatMessageTextController = TextEditingController();
  late String _email;
  String? _messageText;
  bool _messageTyping = false;
  late String _username;

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      setState(() {
        _username = User.displayName!;
        _email = User.email!;
      });

      debugPrint(
          "User ID: ${User.id}, name: ${User.displayName}, email: ${User.email}");
    } catch (exception) {
      edgeAlert(context,
          title: "Something Went Wrong",
          description: exception.toString(),
          gravity: Gravity.bottom,
          icon: Icons.error,
          backgroundColor: Colors.deepPurple[900]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.deepPurple),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size(25, 10),
          child: Container(
            constraints: const BoxConstraints.expand(height: 1),
            child: LinearProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.blue[100],
            ),
          ),
        ),
        backgroundColor: Colors.white10,
        title: const Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  config.title,
                  style: TextStyle(
                      fontFamily: config.fontFamily,
                      fontSize: 16,
                      color: Colors.deepPurple),
                ),
                Text("by LurkyDismal",
                    style: TextStyle(
                        fontFamily: config.fontFamily,
                        fontSize: 8,
                        color: Colors.deepPurple))
              ],
            ),
          ],
        ),
        actions: <Widget>[
          GestureDetector(
            child: const Icon(Icons.more_vert),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple[900],
              ),
              accountName: Text(_username),
              accountEmail: Text(_email),
              currentAccountPicture: CircleAvatar(
                foregroundImage: User.accountPicture,
              ),
              onDetailsPressed: () {},
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Logout"),
              subtitle: const Text("Sign out of this account"),
              onTap: () async {
                setState(() {
                  User.signOut();
                });

                if (mounted) {
                  Navigator.pushReplacementNamed(context, "/");
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const ChatStream(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            decoration: config.messageContainerDecoration,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Material(
                    borderRadius: BorderRadius.circular(50),
                    color: Colors.white,
                    elevation: 5,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 8.0, top: 2, bottom: 2),
                      child: TextField(
                        onChanged: (value) {
                          if (value.trim().isNotEmpty) {
                            _messageText = value;
                            _messageTyping = true;
                          }
                        },
                        controller: _chatMessageTextController,
                        decoration: config.messageTextFieldDecoration,
                      ),
                    ),
                  ),
                ),
                MaterialButton(
                    shape: const CircleBorder(),
                    color: Colors.blue,
                    onPressed: () {
                      _chatMessageTextController.clear();
                      if (_messageTyping) {
                        http.post(
                            Uri.http(config.hostAddress, "/message_send.php"),
                            body: {
                              "peer": User.id.toString(),
                              "text": _messageText?.trim()
                            });

                        _messageTyping = false;
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
