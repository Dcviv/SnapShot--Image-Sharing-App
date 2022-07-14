import 'package:flutter/material.dart';
import 'package:snap_shot/components/sign_up_headText.dart';

import '../components/heading_text.dart';

class SignUp extends StatelessWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SignUpHeadText(),
            ],
          ),
        ),
      ),
    ));
  }
}
