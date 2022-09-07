// import "package:firebase_auth/firebase_auth.dart";
// import 'package:flutter/foundation.dart';
// import "package:flutter/material.dart";
// import "package:cc_chat/constants.dart";

// class ChatScreen extends StatefulWidget {
//   const ChatScreen({super.key});

//   @override
//   State<ChatScreen> createState() => _ChatScreenState();
// }

// class _ChatScreenState extends State<ChatScreen> {
//   final _auth = FirebaseAuth.instance;
//   User? loggedInUser;

//   void getCurrentUser() {
//     try {
//       final user = _auth.currentUser;

//       if (user != null) {
//         loggedInUser = user;

//         if (kDebugMode) {
//           debugPrint(loggedInUser!.email);
//           debugPrint(loggedInUser!.displayName);
//         }
//       }
//     } catch (error) {
//       if (kDebugMode) {
//         print(error);
//       }
//     }
//   }

//   @override
//   void initState() {
//     super.initState();

//     getCurrentUser();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: null,
//         actions: <Widget>[
//           IconButton(
//               icon: const Icon(Icons.close),
//               onPressed: () {
//                 //Implement logout functionality
//               }),
//         ],
//         title: const Text("Chat"),
//         backgroundColor: Colors.lightBlueAccent,
//       ),
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: <Widget>[
//             Container(
//               decoration: kMessageContainerDecoration,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: <Widget>[
//                   Expanded(
//                     child: TextField(
//                       onChanged: (value) {
//                         //Do something with the user input.
//                       },
//                       decoration: kMessageTextFieldDecoration,
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       //Implement send functionality.
//                     },
//                     child: const Text(
//                       "Send",
//                       style: kSendButtonTextStyle,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
