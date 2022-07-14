import 'package:flutter/material.dart';
import 'package:snap_shot/app_res/colors.dart';
import 'package:snap_shot/components/info.dart';

class HeadText extends StatelessWidget {
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
              "Login",
              style: TextStyle(
                  fontSize: 30,
                  color: AppColor.textColor,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Credentials(),
          )
        ],
      ),
    );
  }
}
