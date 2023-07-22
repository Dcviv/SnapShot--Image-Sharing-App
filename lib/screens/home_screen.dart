import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:snap_shot/app_res/colors.dart';
import 'package:snap_shot/screens/chat_tile_page.dart';
import 'package:snap_shot/screens/login.dart';
import 'package:snap_shot/screens/search.dart';
import 'package:snap_shot/screens/post_detail_page.dart';
import 'package:snap_shot/screens/user_profile.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? imageFile;
  String? imageUrl;
  String? myImage;
  String? myName;
  String? description = "";

  FirebaseAuth _auth = FirebaseAuth.instance;
  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Please choose an option"),
            content: Column(
              children: [
                InkWell(
                  onTap: () {
                    _getFromCamera(context);
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.camera,
                          color: AppColor.mainColor,
                        ),
                      ),
                      Text(
                        "Camera",
                        style: TextStyle(color: AppColor.mainColor),
                      )
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    //open gallery
                    _getFromGallery(context);
                  },
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.image,
                          color: AppColor.mainColor,
                        ),
                      ),
                      Text(
                        "Gallery",
                        style: TextStyle(color: AppColor.mainColor),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }

  void _getFromCamera(BuildContext context) async {
    XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    _cropImage(pickedImage!.path);
    Navigator.pop(context);
  }

  void _getFromGallery(BuildContext context) async {
    XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    _cropImage(pickedImage!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper()
        .cropImage(sourcePath: filePath, maxHeight: 1080, maxWidth: 1080);
    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void _uploadImage() async {
    if (imageFile == null) {
      Fluttertoast.showToast(msg: "Please select an image.");
      return;
    }
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child("userImages")
          .child(DateTime.now().toString() + 'jpg');
      await ref.putFile(imageFile!);
      imageUrl = await ref.getDownloadURL();
      FirebaseFirestore.instance
          .collection('wallpaper')
          .doc(DateTime.now().toString())
          .set({
        'id': _auth.currentUser!.uid,
        'email': _auth.currentUser!.email,
        'userPosts': imageUrl,
        'downloads': 0,
        'createdAt': DateTime.now(),
        'userImage': myImage,
        'name': myName,
      });
      Navigator.canPop(context) ? Navigator.pop(context) : null;
      imageFile = null;
    } catch (error) {
      Fluttertoast.showToast(msg: error.toString());
    }
  }

  void _readUserInfo() async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then<dynamic>((DocumentSnapshot snapshot) async {
      myImage = snapshot.get('userImage');
      myName = snapshot.get('name');
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
                SizedBox(
                  child: GestureDetector(
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
                                    description: description,
                                  )));
                    },
                    child: Image.network(
                      img,
                      fit: BoxFit.cover,
                    ),
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
            ),
          )),
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
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
          ),
          flexibleSpace: Container(
            color: AppColor.mainColor,
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchPage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () {
                //user profile page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(),
                  ),
                );
              },
              icon: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ],
          title: const Text(
            "SnapShot",
            style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                fontFamily: "Billabong"),
          ),
          centerTitle: true,
        ),
        floatingActionButton: Wrap(
          direction: Axis.vertical,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                heroTag: "1",
                backgroundColor: AppColor.mainColor,
                onPressed: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const ChatTilePage()));
                },
                child: const Icon(
                  Icons.message,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                heroTag: "2",
                backgroundColor: AppColor.mainColor,
                onPressed: () {
                  _showImageDialog();
                },
                child: const Icon(
                  Icons.camera,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: FloatingActionButton(
                heroTag: "3",
                backgroundColor: AppColor.mainColor,
                onPressed: () {
                  _uploadImage();
                },
                child: const Icon(
                  Icons.upload,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("wallpaper")
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
                        snapshot.data!.docs[index]["downloads"],
                      );
                    },
                  );
                }
              } else {
                return const Center(
                  child: Text("There are no posts."),
                );
              }
              return const Center(
                child: Text("Something went wrong"),
              );
            }),
      ),
    );
  }
}
