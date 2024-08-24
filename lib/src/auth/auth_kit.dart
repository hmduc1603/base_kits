import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer';

class AuthKit {
  static final AuthKit _instance = AuthKit._internal();
  AuthKit._internal();
  factory AuthKit() => _instance;

  Future<String> getAnnonymousUserIdToken() async {
    final user = FirebaseAuth.instance.currentUser ??
        (await FirebaseAuth.instance.signInAnonymously()).user;
    final token = await user?.getIdToken();
    if (token != null) {
      log(token, name: "AuthKit");
      return token;
    } else {
      throw Exception("Failed to get user id token!");
    }
  }

  Future<void> revokeIdToken() {
    return FirebaseAuth.instance.signOut();
  }
}
