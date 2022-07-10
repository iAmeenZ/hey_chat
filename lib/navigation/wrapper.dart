import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hey_chat/model/user_model.dart';
import 'package:hey_chat/navigation/bottom.dart';
import 'package:hey_chat/screens/authenticate/login_screen.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({ Key? key}) : super(key: key);

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {

  Future<UserModel> getUserModel() async {
    User? user = FirebaseAuth.instance.currentUser;
    UserModel usermodel;

    await Future.delayed(Duration(seconds: 3));

    final data = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();
    usermodel = UserModel.fromMap(data.data()!);

    return usermodel;
  }

  @override
  Widget build(BuildContext context) {
    final UserModelStream? user = Provider.of<UserModelStream?>(context); // Receive from main.dart StreamProvider

    // return either Home or Authenticate widget
    if (user == null) {
      return LoginScreen();
    } else {
      return Material(
        child: FutureBuilder<UserModel>(
          future: getUserModel(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return SpinKitSpinningLines(color: Colors.redAccent);
            if (snapshot.data == null) return Text('No data');
            return ChangeNotifierProvider<UserModel>.value(
              value: snapshot.data!,
              child: BotNav()
            );
          }
        ),
      );
    }
  }

}