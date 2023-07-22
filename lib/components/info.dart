import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:snap_shot/screens/forget_pass.dart';
import 'package:snap_shot/screens/home_screen.dart';
import 'package:snap_shot/screens/sign_up.dart';
import 'package:snap_shot/services/account_check.dart';
import 'package:snap_shot/widgets/button.dart';
import 'package:snap_shot/widgets/input_field.dart';

class Credentials extends StatefulWidget {
  @override
  State<Credentials> createState() => _CredentialsState();
}

class _CredentialsState extends State<Credentials> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController _emailTextEditingController =
      TextEditingController(text: "");

  TextEditingController _passTextEditingController =
      TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
                radius: 80,
                backgroundImage: AssetImage("assets/images/app_logo.png"),
                backgroundColor: Colors.white),
          ),
          SizedBox(
            height: 15,
          ),
          InputField(
              hintText: "Enter email",
              icon: Icons.email_rounded,
              obsecureText: false,
              textEditingController: _emailTextEditingController),
          InputField(
            hintText: "Enter Password",
            icon: Icons.lock,
            obsecureText: true,
            textEditingController: _passTextEditingController,
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => ForgetPassPage()));
                },
                child: Text(
                  "Forgot Password ?",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 20),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          LoginButton(
            text: "LOGIN",
            press: () async {
              try {
                await _auth.signInWithEmailAndPassword(
                    email: _emailTextEditingController.text.trim(),
                    password: _passTextEditingController.text.trim());
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => HomeScreen()));
              } catch (e) {
                Fluttertoast.showToast(msg: e.toString());
              }
            },
          ),
          SizedBox(
            height: 5,
          ),
          AccountCheck(
              login: true,
              press: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => SignUp()));
              })
        ],
      ),
    );
  }
}
