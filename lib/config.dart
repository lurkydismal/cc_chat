import "package:flutter/material.dart";

const fontFamily = "Poppins";
const hostAddress = "localhost";
const splashScreenAnimationDuration = 500;
const title = "Chat App";

const messageContainerDecoration = BoxDecoration(
  border: Border(
    top: BorderSide(color: Colors.lightBlueAccent, width: 2.0),
  ),
);

const messageTextFieldDecoration = InputDecoration(
  contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
  hintText: "Type your message here...",
  hintStyle: TextStyle(fontFamily: fontFamily, fontSize: 14),
  border: InputBorder.none,
);
