import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hey_chat/navigation/bottom.dart';
import 'package:hey_chat/screens/authenticate/registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // form key
  final _formKey = GlobalKey<FormState>();

  // editing controller
  final TextEditingController emailController = new TextEditingController();
  final TextEditingController passwordController = new TextEditingController();

  // firebase
  final _auth = FirebaseAuth.instance;

  // string for displaying the error Message
  String? errorMessage;

  bool loading = false;

  @override
  Widget build(BuildContext context) {

    final emailField = TextFormField(
      autofocus: false,
      controller: emailController,
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
        emailController.text = value!;
      },
      textInputAction: TextInputAction.next,
    );

    //password field
    final passwordField = TextFormField(
      autofocus: false,
      controller: passwordController,
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
      },
      onSaved: (value) {
        passwordController.text = value!;
      },
      textInputAction: TextInputAction.done,
    );

    final loginButton = SizedBox(
      width: 200,
      height: 50,
      child: loading ? SpinKitSpinningLines(color: Colors.white) : ElevatedButton(
        style: ElevatedButton.styleFrom(primary: Colors.black),
        onPressed: () async {
          setState(() {
            loading = true;
          });
          await signIn(emailController.text, passwordController.text);
        },
        child: Text(
          "Login",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
        )
      )
    );

    return Scaffold(
      backgroundColor: Colors.redAccent,
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
                  SizedBox(height: 45),
                  emailField,
                  SizedBox(height: 25),
                  passwordField,
                  SizedBox(height: 35),
                  loginButton,
                  SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,MaterialPageRoute(builder: (context) => RegistrationScreen()));
                    },
                    child: Text('Register', style: TextStyle(color: Colors.white, decoration: TextDecoration.underline))
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // login function
  Future<void> signIn(String email, String password) async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth
            .signInWithEmailAndPassword(email: email, password: password)
            .then((uid) async {
                  Fluttertoast.showToast(msg: "Login Successful");
                  await FirebaseFirestore.instance.collection("users").doc(uid.user!.uid).update({'fcm': await FirebaseMessaging.instance.getToken()});
                  if (mounted) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => BotNav()));
                  }
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
}
