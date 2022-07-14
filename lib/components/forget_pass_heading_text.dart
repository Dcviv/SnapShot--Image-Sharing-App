import 'package:flutter/material.dart';
import 'package:snap_shot/app_res/colors.dart';
import 'package:snap_shot/components/forgot_pass_info.dart';

class ForgotPassHeadingText extends StatelessWidget {
  const ForgotPassHeadingText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Column(
        children: [
          SizedBox(
            height: size.height * 0.05,
          ),
          Center(
            child: Text(
              "SnapShot",
              style: TextStyle(
                  fontSize: 70,
                  color: AppColor.mainColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: "Billabong"),
            ),
          ),
          Center(
            child: Text(
              "Reset Password",
              style: TextStyle(
                  fontSize: 30,
                  color: AppColor.textColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: ForgotPassCredentials(),
          )
        ],
      ),
    );
  }
}
