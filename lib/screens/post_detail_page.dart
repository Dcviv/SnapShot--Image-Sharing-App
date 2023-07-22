import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:snap_shot/app_res/colors.dart';
import 'package:snap_shot/model/user_model.dart';
import 'package:snap_shot/screens/home_screen.dart';
import 'package:snap_shot/widgets/button.dart';

import 'chat_screen.dart';

class PostDetailsPage extends StatefulWidget {
  String? img;
  String? userImage;
  String? name;
  DateTime? date;
  String? docId;
  String? userId;
  int? downloads;
  String? description;

  PostDetailsPage({
    required this.img,
    required this.userImage,
    required this.name,
    required this.date,
    required this.docId,
    required this.userId,
    required this.downloads,
    required this.description,
  });
  @override
  State<PostDetailsPage> createState() => _PostDetailsPage();
}

class _PostDetailsPage extends State<PostDetailsPage> {
  int? total;
  Users? peerModel;

  void _readUserInfo() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId.toString())
        .get()
        .then<dynamic>((DocumentSnapshot snapshot) async {
      setState(() {
        widget.description = snapshot.get('userDescription').toString();
      });
    });
  }

  void _createPeerModel() {
    peerModel = Users(
        name: widget.name.toString(),
        createdAt: "",
        email: "",
        id: widget.userId,
        userImage: widget.userImage,
        userDescription: "");
  }

  @override
  void initState() {
    super.initState();
    _readUserInfo();
    _createPeerModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => ChatPage(
                    peermodel: peerModel,
                  )));
        },
        backgroundColor: AppColor.mainColor,
        child: const Icon(Icons.message_rounded),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomeScreen()));
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          color: AppColor.mainColor,
        ),
        title: Text(
          widget.name!.toString(),
          style: const TextStyle(
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
                const SizedBox(
                  height: 30,
                ),
                const Text(
                  "Owner's Information",
                  style: TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
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
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Uploaded by :- ${widget.name.toString()}",
                  style: const TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  DateFormat("dd MMMM yyyy - hh:mm a")
                      .format(widget.date!)
                      .toString(),
                  style: TextStyle(
                      color: AppColor.textColor, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  "About Me :-",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  widget.description.toString(),
                  style: const TextStyle(
                      color: AppColor.spaceLight, fontWeight: FontWeight.w600),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
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
                      style: const TextStyle(
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
                    press: () {
                      // try {
                      //   var imageid =
                      //       await ImageDownloader.downloadImage(widget.img!);
                      //   if (imageid == null) {
                      //     return;
                      //   }

                      //   Fluttertoast.showToast(
                      //       msg: "Image downloaded successfully.");
                      //   total = widget.downloads! + 1;
                      //   FirebaseFirestore.instance
                      //       .collection('wallpaper')
                      //       .doc(widget.docId)
                      //       .update({
                      //     'downloads': total,
                      //   }).then((value) {
                      //     Navigator.pushReplacement(context,
                      //         MaterialPageRoute(builder: (_) => HomeScreen()));
                      //   });
                      // } on PlatformException catch (error) {
                      //   Fluttertoast.showToast(msg: error.toString());
                      // }
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
