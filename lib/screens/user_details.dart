import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:intl/intl.dart';
import 'package:snap_shot/app_res/colors.dart';
import 'package:snap_shot/screens/home_screen.dart';
import 'package:snap_shot/widgets/button.dart';

class UserDetailsPage extends StatefulWidget {
  String? img;
  String? userImage;
  String? name;
  DateTime? date;
  String? docId;
  String? userId;
  int? downloads;

  UserDetailsPage({
    required this.img,
    required this.userImage,
    required this.name,
    required this.date,
    required this.docId,
    required this.userId,
    required this.downloads,
  });
  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  int? total;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomeScreen()));
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          color: AppColor.mainColor,
        ),
        title: Text(
          widget.name!.toString(),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        child: ListView(
          children: [
            Column(
              children: [
                Container(
                  child: Image.network(
                    widget.img!,
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Text(
                  "Owner's Information",
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: NetworkImage(widget.userImage!),
                          fit: BoxFit.cover)),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Uploaded by :- ${widget.name.toString()}",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  DateFormat("dd MMMM yyyy - hh:mm a")
                      .format(widget.date!)
                      .toString(),
                  style: TextStyle(
                      color: AppColor.textColor, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 30,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download,
                      color: AppColor.mainColor,
                      size: 30,
                    ),
                    Text(
                      " " + widget.downloads.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 26),
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: LoginButton(
                    press: () async {
                      try {
                        var imageid =
                            await ImageDownloader.downloadImage(widget.img!);
                        if (imageid == null) {
                          return;
                        }

                        Fluttertoast.showToast(
                            msg: "Image downloaded successfully.");
                        total = widget.downloads! + 1;
                        FirebaseFirestore.instance
                            .collection('wallpaper')
                            .doc(widget.docId)
                            .update({
                          'downloads': total,
                        }).then((value) {
                          Navigator.pushReplacement(context,
                              MaterialPageRoute(builder: (_) => HomeScreen()));
                        });
                      } on PlatformException catch (error) {
                        Fluttertoast.showToast(msg: error.toString());
                      }
                    },
                    text: "Download",
                  ),
                ),
                SizedBox(height: 10),
                FirebaseAuth.instance.currentUser!.uid == widget.userId
                    ? Padding(
                        padding: EdgeInsets.only(left: 8, right: 8),
                        child: LoginButton(
                          press: () async {
                            try {
                              FirebaseFirestore.instance
                                  .collection('wallpaper')
                                  .doc(widget.docId)
                                  .delete()
                                  .then((value) => Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => HomeScreen())));
                            } on PlatformException catch (error) {
                              print(error);
                            }
                          },
                          text: "Delete",
                        ),
                      )
                    : Container(),
                Padding(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: LoginButton(
                    press: () async {
                      try {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => HomeScreen()));
                      } on PlatformException catch (error) {
                        print(error);
                      }
                    },
                    text: "Back",
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
