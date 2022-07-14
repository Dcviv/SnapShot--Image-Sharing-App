import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:snap_shot/screens/login.dart';
import 'package:snap_shot/screens/sign_up.dart';
import 'package:snap_shot/widgets/button.dart';
import 'package:snap_shot/widgets/input_field.dart';

import '../services/account_check.dart';

class ForgotPassCredentials extends StatefulWidget {
  @override
  State<ForgotPassCredentials> createState() => _ForgotPassCredentialsState();
}

class _ForgotPassCredentialsState extends State<ForgotPassCredentials> {
  TextEditingController _emailTextEditingController =
      TextEditingController(text: "");
  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              "assets/images/forgot_pass.jpg",
              width: 300,
              height: 300,
            ),
          ),
          SizedBox(
            height: 15,
          ),
          InputField(
              hintText: "Enter email",
              icon: Icons.email_rounded,
              obsecureText: false,
              textEditingController: _emailTextEditingController),
          SizedBox(
            height: 15,
          ),
          LoginButton(
            text: "Reset Password",
            press: () async {
              try {
                await _auth.sendPasswordResetEmail(
                    email: _emailTextEditingController.text);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                  "Reset password link has been sent to your registered email address.",
                  style: TextStyle(
                    fontSize: 18,
                  ),
                )));
              } on FirebaseAuthException catch (error) {
                Fluttertoast.showToast(msg: error.toString());
              }
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => LoginPage()));
            },
          ),
          SizedBox(
            height: 5,
          ),
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => SignUp()));
            },
            child: Center(
              child: Text(
                "Create Account",
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          AccountCheck(
              login: false,
              press: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => LoginPage()));
              })
        ],
      ),
    );
  }
}
