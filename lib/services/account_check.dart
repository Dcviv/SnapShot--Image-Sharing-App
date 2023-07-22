import 'package:flutter/material.dart';

class AccountCheck extends StatelessWidget {
  final bool login;
  final VoidCallback press;

  const AccountCheck({required this.login, required this.press});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(login ? "Don't have an account?" : "Already have an account?",
            style: TextStyle(
                fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w400)),
        GestureDetector(
          onTap: press,
          child: Text(
            login ? "Create Account" : "Log In",
            style: TextStyle(
                fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }
}
