import 'package:flutter/material.dart';
import 'package:snap_shot/widgets/text_field.dart';

class InputField extends StatelessWidget {
  final String hintText;
  final IconData icon;
  final bool obsecureText;
  final TextEditingController textEditingController;

  const InputField(
      {required this.hintText,
      required this.icon,
      required this.obsecureText,
      required this.textEditingController});

  @override
  Widget build(BuildContext context) {
    return TextFieldContainer(
        child: TextField(
      cursorColor: Colors.white,
      obscureText: obsecureText,
      controller: textEditingController,
      decoration: InputDecoration(
          hintText: hintText,
          helperStyle: TextStyle(color: Colors.white, fontSize: 24),
          prefixIcon: Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
          border: InputBorder.none),
    ));
  }
}
