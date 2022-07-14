import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:snap_shot/app_res/colors.dart';
import 'package:snap_shot/screens/home_screen.dart';
import 'package:snap_shot/screens/login.dart';
import 'package:snap_shot/screens/search.dart';
import 'package:snap_shot/screens/user_details.dart';
import 'package:snap_shot/screens/user_profile.dart';

class UserSpecificPostPage extends StatefulWidget {
  String? userId;
  UserSpecificPostPage({
    required this.userId,
  });
  @override
  State<UserSpecificPostPage> createState() => _UserSpecificPostPage();
}

class _UserSpecificPostPage extends State<UserSpecificPostPage> {
  String? myImage;
  String? myName;

  void _readUserInfo() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userId.toString())
        .get()
        .then<dynamic>((DocumentSnapshot snapshot) async {
      myImage = snapshot.get('userImage').toString();
      myName = snapshot.get('name').toString();
    });
  }

  @override
  void initState() {
    super.initState();
    _readUserInfo();
  }

  Widget listViewWidget(String docId, String img, String userImg, String name,
      String userID, DateTime date, int downloads) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Card(
        elevation: 16,
        shadowColor: AppColor.textColor,
        child: Container(
            padding: EdgeInsets.all(5),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => UserDetailsPage(
                                img: img,
                                userImage: userImg,
                                name: name,
                                date: date,
                                docId: docId,
                                userId: userID,
                                downloads: downloads)));
                  },
                  child: Image.network(
                    img,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(userImg),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy - hh:mm a')
                                .format(date)
                                .toString(),
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
          backgroundColor: Colors.white,
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
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SearchPage(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("wallpaper")
                  .where('id', isEqualTo: widget.userId)
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot snapshot) {
                //AsyncSnapshot snapshot
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColor.mainColor,
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.active) {
                  if (snapshot.data!.docs.isNotEmpty) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        return listViewWidget(
                            snapshot.data!.docs[index].id,
                            snapshot.data!.docs[index]["userPosts"],
                            snapshot.data!.docs[index]["userImage"],
                            snapshot.data!.docs[index]["name"],
                            snapshot.data!.docs[index]["id"],
                            snapshot.data!.docs[index]["createdAt"].toDate(),
                            snapshot.data!.docs[index]["downloads"]);
                      },
                    );
                  } else {
                    return Center(
                      child: Text("There are no posts."),
                    );
                  }
                } else {
                  return Center(
                    child: Text("There are no posts."),
                  );
                }
                return Center(
                  child: Text("Something went wrong"),
                );
              })),
    );
  }
}
