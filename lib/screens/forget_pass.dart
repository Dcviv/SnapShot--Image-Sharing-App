import 'package:flutter/material.dart';
import 'package:snap_shot/components/forget_pass_heading_text.dart';

class ForgetPassPage extends StatelessWidget {
  const ForgetPassPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              ForgotPassHeadingText(),
            ],
          ),
        ),
      ),
    ));
  }
}
