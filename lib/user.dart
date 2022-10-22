import "package:flutter/painting.dart";

class User {
  static ImageProvider<Object>? accountPicture;
  static String? displayName;
  static String? email;
  static int? id;
  static bool isActive = false;

  static Future<void> signOut() async {
    displayName = null;
    email = null;
    id = null;
    isActive = false;
  }
}
