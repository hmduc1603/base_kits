import 'package:firebase_auth/firebase_auth.dart';

class AuthKit {
  static final AuthKit _instance = AuthKit._internal();
  AuthKit._internal();
  factory AuthKit() => _instance;

  Future<String> getAnnonymousUserIdToken() async {
    final user = FirebaseAuth.instance.currentUser ??
        (await FirebaseAuth.instance.signInAnonymously()).user;
    final token = await user?.getIdToken();
    if (token != null) {
      return token;
    } else {
      throw Exception("Failed to get user id token!");
    }
  }
}
