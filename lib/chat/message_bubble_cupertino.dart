import "package:flutter/cupertino.dart";

import "package:cc_chat/config.dart" as config;

class MessageBubbleCupertino extends StatelessWidget {
  final String messageText;
  final String messageSender;
  final bool senderIsCurrentUser;
  const MessageBubbleCupertino(
      {super.key,
      required this.messageText,
      required this.messageSender,
      required this.senderIsCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment:
            (senderIsCurrentUser) ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              messageSender,
              style: const TextStyle(
                  fontSize: 13,
                  fontFamily: config.fontFamily,
                  color: Colors.black87),
            ),
          ),
          Material(
            borderRadius: BorderRadius.only(
              bottomLeft: const Radius.circular(50),
              topLeft:
                  (senderIsCurrentUser) ? const Radius.circular(50) : const Radius.circular(0),
              bottomRight: const Radius.circular(50),
              topRight:
                  (senderIsCurrentUser) ? const Radius.circular(0) : const Radius.circular(50),
            ),
            color: (senderIsCurrentUser) ? Colors.blue : Colors.white,
            elevation: 5,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                messageText,
                style: TextStyle(
                  color: (senderIsCurrentUser) ? Colors.white : Colors.blue,
                  fontFamily: config.fontFamily,
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
