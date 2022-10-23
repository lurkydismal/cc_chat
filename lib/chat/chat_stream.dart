import "dart:io";

import "package:flutter/material.dart";
// import "package:flutter/cupertino.dart";
import "package:http/http.dart" as http;

import "package:chat_app/config.dart" as config;
// import "package:chat_app/chat/message_bubble_cupertino.dart";
import "package:chat_app/chat/message_bubble_material.dart";
import "package:chat_app/user.dart";

class ChatStream extends StatefulWidget {
  const ChatStream({super.key});

  @override
  State<ChatStream> createState() => _ChatStreamState();
}

class _ChatStreamState extends State<ChatStream> {
  List<MessageBubbleMaterial> _messageWidgets = [];

  void getMessages() async {
    var messageCount = 0;
    var id = 1;
    var messages = <MessageBubbleMaterial>[];

    while (User.isActive) {
      final response =
          await http.post(Uri.http(config.hostAddress, "/message_count.php"));

      if ((response.statusCode == 200) && (response.body != "")) {
        messageCount = int.parse(response.body);
      } else {
        throw "Message count status: ${response.statusCode} with response ${response.body}";
      }

      while (id <= messageCount) {
        var response = await http.post(
            Uri.http(config.hostAddress, "/message_get.php"),
            body: {"id": id.toString()});
        debugPrint(
            "Message body: ${response.body} and status: ${response.statusCode}");

        if ((response.statusCode == 200) && (response.body != "")) {
          final message = response.body.split("|");
          final messageSenderId = int.parse(message[0]);
          final messageText = message[1];
          // ignore: unused_local_variable
          final messageDate = DateTime.parse(message[2]);

          response = await http.post(
              Uri.http(config.hostAddress, "/get_user_by_id.php"),
              body: {"id": messageSenderId.toString()});
          debugPrint(
              "Message body: ${response.body} and status: ${response.statusCode}");

          if ((response.statusCode == 200) && (response.body != "")) {
            final messageSenderName = response.body;

            final messageBubble = MessageBubbleMaterial(
                messageText: messageText,
                messageSender: messageSenderName,
                senderIsCurrentUser: User.id == messageSenderId);

            messages.add(messageBubble);
          } else {
            throw "Message getting status: ${response.statusCode} with response ${response.body}";
          }
        } else {
          throw "Message getting status: ${response.statusCode} with response ${response.body}";
        }

        id++;
      }

      setState(() {
        _messageWidgets = messages;
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
    if (_messageWidgets.isNotEmpty) {
      return Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          children: _messageWidgets,
        ),
      );
    } else {
      return Center(
        child: (Platform.isIOS || Platform.isMacOS)
            ? const CircularProgressIndicator(backgroundColor: Colors.deepPurple)
            : const CircularProgressIndicator(backgroundColor: Colors.deepPurple),
      );
    }
  }
}
