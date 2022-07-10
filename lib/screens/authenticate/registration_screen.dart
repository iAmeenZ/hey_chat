
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hey_chat/model/user_model.dart';
import 'package:hey_chat/services/auth.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
 

  // string for displaying the error Message
  String? errorMessage;

  // our form key
  final _formKey = GlobalKey<FormState>();
  // editing Controller
  final nameController = TextEditingController();
  final emailEditingController = TextEditingController();
  final passwordEditingController = TextEditingController();
  final confirmPasswordEditingController = TextEditingController();

  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    setState(() {
      pickedFile = result.files.first;
    });
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    //name field
    final nameField = TextFormField(
      autofocus: false,
      controller: nameController,
      keyboardType: TextInputType.name,
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        labelText: 'Name',
        prefixIcon: Icon(Icons.person, color: Colors.white),
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),  
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))
      ),
      validator: (value) {
        RegExp regex = RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("First Name cannot be Empty");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid name(Min. 3 Character)");
        }
        return null;
      },
      onSaved: (value) {
        nameController.text = value!;
      },
      textInputAction: TextInputAction.next,
    );

    //email field
    final emailField = TextFormField(
      autofocus: false,
      controller: emailEditingController,
      keyboardType: TextInputType.emailAddress,
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email, color: Colors.white),
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),  
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))
      ),
      validator: (value) {
        if (value!.isEmpty) {
          return ("Please Enter Your Email");
        }
        // reg expression for email validation
        if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
            .hasMatch(value)) {
          return ("Please Enter a valid email");
        }
        return null;
      },
      onSaved: (value) {
        nameController.text = value!;
      },
      textInputAction: TextInputAction.next,
    );

    //password field
    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordEditingController,
      obscureText: true,
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.key, color: Colors.white),
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),  
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))
      ),
      validator: (value) {
        RegExp regex = RegExp(r'^.{6,}$');
        if (value!.isEmpty) {
          return ("Password is required for login");
        }
        if (!regex.hasMatch(value)) {
          return ("Enter Valid Password(Min. 6 Character)");
        }
        return null;
      },
      onSaved: (value) {
        nameController.text = value!;
      },
      textInputAction: TextInputAction.next,
    );

    //confirm password field
    final confirmPasswordField = TextFormField(
      autofocus: false,
      controller: confirmPasswordEditingController,
      obscureText: true,
      style: TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: const InputDecoration(
        labelText: 'Confirm Password',
        prefixIcon: Icon(Icons.key, color: Colors.white),
        labelStyle: TextStyle(color: Colors.white),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),  
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))
      ),
      validator: (value) {
        if (confirmPasswordEditingController.text !=
            passwordEditingController.text) {
          return "Password don't match";
        }
        return null;
      },
      onSaved: (value) {
        confirmPasswordEditingController.text = value!;
      },
      textInputAction: TextInputAction.done,
    );

    return Scaffold(
      backgroundColor: Colors.redAccent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: loading ? null : () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(   
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.forum, color: Colors.white, size: 40),
                      SizedBox(width: 10),
                      Text('HeyChat', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 30))
                    ],
                  ),
                  SizedBox(height: 50),
                  if (pickedFile != null)...[
                    Container(
                      height: 150,
                      width: 150,
                      padding: EdgeInsets.all(10),
                      color: Colors.white,
                      child: Image.file(
                        File(pickedFile!.path!),
                        width: double.infinity,
                        fit: BoxFit.cover
                      ),
                    )
                  ],
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(primary: Colors.white),
                    onPressed: selectFile,
                    child: Text("Select Image", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 20)),
                  ),
                  SizedBox(height: 20),
                  emailField,
                  SizedBox(height: 20),
                  nameField,
                  SizedBox(height: 20),
                  passwordField,
                  SizedBox(height: 20),
                  confirmPasswordField,
                  SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: loading ? SpinKitSpinningLines(color: Colors.white) : ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.black),
                      onPressed: () async {
                        setState(() {
                          loading = true;
                        });
                        await signUp(emailEditingController.text,passwordEditingController.text, context);
                      },
                      child: Text(
                        "Register",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                      )
                    ),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signUp(String email, String password, BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        
        await _auth
            .createUserWithEmailAndPassword(email: email, password: password)
            .then((value) async {
          await postDetailsToFirestore();
          User? user = value.user;
          AuthService().userFromFirebase(user);
          if (mounted) Navigator.pop(context);
        }).catchError((e) {
          Fluttertoast.showToast(msg: e!.message);
        });
      } on FirebaseAuthException catch (error) {
        switch (error.code) {
          case "invalid-email":
            errorMessage = "Your email address appears to be malformed.";
            break;
          case "wrong-password":
            errorMessage = "Your password is wrong.";
            break;
          case "user-not-found":
            errorMessage = "User with this email doesn't exist.";
            break;
          case "user-disabled":
            errorMessage = "User with this email has been disabled.";
            break;
          case "too-many-requests":
            errorMessage = "Too many requests";
            break;
          case "operation-not-allowed":
            errorMessage = "Signing in with Email and Password is not enabled.";
            break;
          default:
            errorMessage = "An undefined Error happened.";
        }
        Fluttertoast.showToast(msg: errorMessage!);
        print(error.code);
      }
    }
  }

  Future postDetailsToFirestore() async {
    // calling our firestore
    // calling our user model
    // sedning these values

    try {

      FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
      User? user = _auth.currentUser;

      final path = 'user/${pickedFile!.name}';
      final file = File(pickedFile!.path!);

      final ref = FirebaseStorage.instance.ref().child(path);
      uploadTask = ref.putFile(file);
      final snapshot = await uploadTask!.whenComplete(() {});

      final urlDownload = await snapshot.ref.getDownloadURL();

      UserModel userModel = UserModel(
        email: user!.email!,
        uid: user.uid,
        name: nameController.text,
        fcm: await FirebaseMessaging.instance.getToken(),
        pic: urlDownload,
        roomIds: []
      );

      await firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .set(userModel.toMap());
      Fluttertoast.showToast(msg: "Account created successfully!");
    } catch (e) {
      debugPrint('ROSAK $e');
    }

    // Navigator.pushAndRemoveUntil(
    //     (context),
    //     MaterialPageRoute(builder: (context) => BotNav()),
    //     (route) => false);
  }
}
