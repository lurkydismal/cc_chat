import "package:edge_alerts/edge_alerts.dart";
// import "package:firebase_auth/firebase_auth.dart";
// import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
// import "package:cloud_firestore/cloud_firestore.dart";
import "package:http/http.dart" as http;
import "package:cc_chat/config.dart" as config;
// import 'package:cc_chat/constants.dart';
import "package:cc_chat/user.dart";

late String username;
late String email;
String? messageText;
bool messageTyping = false;

class ChatterScreen extends StatefulWidget {
  const ChatterScreen({super.key});

  @override
  State<ChatterScreen> createState() => _ChatterScreenState();
}

class _ChatterScreenState extends State<ChatterScreen> {
  final chatMsgTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      setState(() {
        username = User.displayName!;
        email = User.email!;
      });

      // debugPrint( "User ID: ${ User.id }, name: ${ User.displayName }, email: ${ User.email }" );
    } catch (error) {
      edgeAlert(context,
          title: "Something Went Wrong",
          description: error.toString(),
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
            decoration: const BoxDecoration(
                // color: Colors.blue,
                // borderRadius: BorderRadius.circular( 20 )
                ),
            constraints: const BoxConstraints.expand(height: 1),
            child: LinearProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              backgroundColor: Colors.blue[100],
            ),
          ),
        ),
        backgroundColor: Colors.white10,
        // leading: Padding(
        //   padding: const EdgeInsets.all( 12.0 ),
        //   child: CircleAvatar(backgroundImage: NetworkImage("https://cdn.clipart.email/93ce84c4f719bd9a234fb92ab331bec4_frisco-specialty-clinic-vail-health_480-480.png"),),
        // ),
        title: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const <Widget>[
                Text(
                  "Chatter",
                  style: TextStyle(
                      fontFamily: "Poppins",
                      fontSize: 16,
                      color: Colors.deepPurple),
                ),
                Text("by LurkyDismal",
                    style: TextStyle(
                        fontFamily: "Poppins",
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
              accountName: Text(username),
              accountEmail: Text(email),
              currentAccountPicture: const CircleAvatar(
                backgroundImage: NetworkImage(
                    "https://cdn.clipart.email/93ce84c4f719bd9a234fb92ab331bec4_frisco-specialty-clinic-vail-health_480-480.png"),
              ),
              onDetailsPressed: () {},
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Logout"),
              subtitle: const Text("Sign out of this account"),
              onTap: () async {
                await User.signOut();

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
            decoration: kMessageContainerDecoration,
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
                            messageText = value;
                            messageTyping = true;
                          }
                        },
                        controller: chatMsgTextController,
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                  ),
                ),
                MaterialButton(
                    shape: const CircleBorder(),
                    color: Colors.blue,
                    onPressed: () {
                      chatMsgTextController.clear();
                      // _firestore.collection("messages").add({
                      //   "sender": username,
                      //   "text": messageText,
                      //   "timestamp": DateTime.now().millisecondsSinceEpoch,
                      //   "senderemail": email
                      // });
                      if (messageTyping) {
                        http.post(
                            Uri.http(config.hostAddress, "/message_send.php"),
                            body: {
                              "peer": User.id.toString(),
                              "text": messageText?.trim()
                            });

                        messageTyping = false;
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                    )
                    // Text(
                    //   "Send",
                    //   style: kSendButtonTextStyle,
                    // ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatStream extends StatefulWidget {
  const ChatStream({super.key});

  @override
  State<ChatStream> createState() => _ChatStreamState();
}

class _ChatStreamState extends State<ChatStream> {
  List<MessageBubble> messageWidgets = [];

  void getMessages() async {
    var messageCount = 0;
    var id = 1;
    var messages = <MessageBubble>[];

    for (;;) {
      final response =
          await http.post(Uri.http(config.hostAddress, "/message_count.php"));

      if ((response.statusCode == 200) && (response.body != "")) {
        messageCount = int.parse(response.body);
      } else {
        throw "Message count status: ${response.statusCode} with response ${response.body}";
      }

      while (id <= messageCount) {
        final response = await http.post(
            Uri.http(config.hostAddress, "/message_get.php"),
            body: {"id": id.toString()});
        debugPrint(
            "Message body: ${response.body} and status: ${response.statusCode}");

        if ((response.statusCode == 200) && (response.body != "")) {
          // final message = [0, id.toString(), DateTime.now()];
          final message = response.body.split("|");
          final messageSender = int.parse( message[0] );
          final messageText = message[1].trim();
          // ignore: unused_local_variable
          final messageDate = DateTime.parse(message[2]);

          final msgBubble = MessageBubble(
              msgText: messageText,
              msgSender: messageSender,
              user: User.id == messageSender);

          messages.add(msgBubble);
        } else {
          throw "Message getting status: ${response.statusCode} with response ${response.body}";
        }

        id++;
      }

      setState(() {
        messageWidgets = messages;
      });

      await Future.delayed(const Duration(seconds: 5));
    }
  }

  @override
  void initState() {
    super.initState();

    getMessages();
  }

  @override
  Widget build(BuildContext context) {
    if (messageWidgets.isNotEmpty) {
      return Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          children: messageWidgets,
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(backgroundColor: Colors.deepPurple),
      );
    }
  }
}

class MessageBubble extends StatelessWidget {
  final String msgText;
  final int msgSender;
  final bool user;
  const MessageBubble(
      {super.key,
      required this.msgText,
      required this.msgSender,
      required this.user});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment:
            user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              msgSender.toString(),
              style: const TextStyle(
                  fontSize: 13, fontFamily: "Poppins", color: Colors.black87),
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              bottomLeft: const Radius.circular(50),
              topLeft:
                  user ? const Radius.circular(50) : const Radius.circular(0),
              bottomRight: const Radius.circular(50),
              topRight:
                  user ? const Radius.circular(0) : const Radius.circular(50),
            ),
            color: user ? Colors.blue : Colors.white,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                msgText,
                style: TextStyle(
                  color: user ? Colors.white : Colors.blue,
                  fontFamily: "Poppins",
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const kSendButtonTextStyle = TextStyle(
  color: Colors.lightBlueAccent,
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
);

const kMessageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: "Type your message here...",
  hintStyle: TextStyle(fontFamily: "Poppins", fontSize: 14),
  border: InputBorder.none,
);

const kMessageContainerDecoration = BoxDecoration(
// border: Border(
//   top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
// ),
    );
