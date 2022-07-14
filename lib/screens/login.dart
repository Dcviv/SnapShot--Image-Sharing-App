import 'package:flutter/material.dart';
import 'package:snap_shot/components/heading_text.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              HeadText(),
            ],
          ),
        ),
      ),
    ));
  }
}
