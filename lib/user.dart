class User {
  static int? id;
  static String? displayName;
  static String? email;

  static Future<void> signOut() async {
    id = null;
    displayName = null;
    email = null;
  }
}
