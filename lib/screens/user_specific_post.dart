import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:snap_shot/app_res/colors.dart';
import 'package:snap_shot/model/user_model.dart';
import 'package:snap_shot/screens/chat_screen.dart';
import 'package:snap_shot/screens/home_screen.dart';
import 'package:snap_shot/screens/search.dart';
import 'package:snap_shot/screens/post_detail_page.dart';

class UserSpecificPostPage extends StatefulWidget {
  final Users? userModel;
  const UserSpecificPostPage({
    required this.userModel,
  });
  @override
  State<UserSpecificPostPage> createState() => _UserSpecificPostPage();
}

class _UserSpecificPostPage extends State<UserSpecificPostPage> {
  // String? senderImage;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // void _readUserInfo() async {
  //   FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(widget.userId.toString())
  //       .get()
  //       .then<dynamic>((DocumentSnapshot snapshot) async {
  //     userImage = snapshot.get('userImage').toString();
  //     userName = snapshot.get('name').toString();
  //     description = snapshot.get('userDescription').toString();
  //   });
  // }

  @override
  void initState() {
    super.initState();
    //_readUserInfo();
  }

  Widget listViewWidget(String docId, String img, String userImg, String name,
      String userID, DateTime date, int downloads) {
    // final User? user = _auth.currentUser; //User is from firebase user
    // senderImage = user!;

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        elevation: 16,
        shadowColor: AppColor.textColor,
        child: Container(
            padding: const EdgeInsets.all(5),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PostDetailsPage(
                                  img: img,
                                  userImage: userImg,
                                  name: name,
                                  date: date,
                                  docId: docId,
                                  userId: userID,
                                  downloads: downloads,
                                  description: widget.userModel!.userDescription
                                      .toString(),
                                )));
                  },
                  child: Image.network(
                    img,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: const EdgeInsets.only(
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
                      const SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy - hh:mm a')
                                .format(date)
                                .toString(),
                            style: const TextStyle(
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
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => ChatPage(
                      peermodel: widget.userModel!,
                    )));
          },
          backgroundColor: AppColor.mainColor,
          child: const Icon(Icons.message_rounded),
        ),
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
              .where('id', isEqualTo: widget.userModel!.id)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot snapshot) {
            //AsyncSnapshot snapshot
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
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
                return const Center(
                  child: Text("There are no posts."),
                );
              }
            } else {
              return const Center(
                child: Text("There are no posts."),
              );
            }
            return const Center(
              child: const Text("Something went wrong"),
            );
          },
        ),
      ),
    );
  }
}
