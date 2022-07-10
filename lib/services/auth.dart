import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:hey_chat/model/user_model.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create user object based on FirebaseUser
  UserModelStream? userFromFirebase(User? user) {
    return user != null ? UserModelStream(uid: user.uid) : null;
  }

  // Auth change user stream
  Stream<UserModelStream?> get user {
    return _auth.authStateChanges().map(userFromFirebase);
  }

  // Sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

}