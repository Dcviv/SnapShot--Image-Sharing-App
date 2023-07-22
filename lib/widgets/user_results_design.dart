import 'package:flutter/material.dart';
import 'package:snap_shot/app_res/colors.dart';
import 'package:snap_shot/model/user_model.dart';
import 'package:snap_shot/screens/user_specific_post.dart';

class UserDesignWidget extends StatefulWidget {
  final Users? userModel;
  final BuildContext? context;
  const UserDesignWidget({
    required this.context,
    required this.userModel,
  });
  @override
  State<UserDesignWidget> createState() => _UserDesignWidgetState();
}

class _UserDesignWidgetState extends State<UserDesignWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) => UserSpecificPostPage(
                      userModel: widget.userModel!,
                    )));
      },
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Container(
            height: 240,
            width: MediaQuery.of(context).size.width,
            child: Column(children: [
              CircleAvatar(
                radius: 70,
                backgroundColor: AppColor.mainColor,
                backgroundImage: NetworkImage(widget.userModel!.userImage!),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.userModel!.name!,
                style: const TextStyle(color: Colors.black, fontSize: 20),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                widget.userModel!.email!,
                style: TextStyle(color: AppColor.textColor, fontSize: 20),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
