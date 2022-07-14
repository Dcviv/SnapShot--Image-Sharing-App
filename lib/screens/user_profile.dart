import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebaseStorage;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snap_shot/screens/home_screen.dart';
import 'package:snap_shot/screens/login.dart';
import 'package:snap_shot/widgets/button.dart';

import '../app_res/colors.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? name;
  String? email;
  String? phoneNo;
  String? img;
  File? imageFile;
  String? updatedUserName = "";
  String? updatedImageUrl;
  Future _getDataFromDatabase() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) async {
      if (snapshot.exists) {
        setState(() {
          name = snapshot.data()!['name'].toString();
          email = snapshot.data()!['email'].toString();
          phoneNo = snapshot.data()!['phoneNo.'].toString();
          img = snapshot.data()!["userImage"].toString();
        });
      }
    });
  }

  Future _updateUserName() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'name': updatedUserName,
    });
  }

  Future _updateUserImage() async {
    String fileName = DateTime.now().microsecondsSinceEpoch.toString();
    firebaseStorage.Reference reference = firebaseStorage
        .FirebaseStorage.instance
        .ref()
        .child("userImages")
        .child(fileName);
    firebaseStorage.UploadTask uploadTask =
        reference.putFile(File(imageFile!.path));
    firebaseStorage.TaskSnapshot takeSnapshot =
        await uploadTask.whenComplete(() {});
    await takeSnapshot.ref.getDownloadURL().then((url) async {
      updatedImageUrl = url;
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'userImage': updatedImageUrl,
    }).whenComplete(() {
      updateImageOnUserPosts();
    });
  }

  updateImageOnUserPosts() async {
    await FirebaseFirestore.instance
        .collection('wallpaper')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      for (int i = 0; i < snapshot.docs.length; i++) {
        String userImageInPost = snapshot.docs[i]['userImage'];
        if (userImageInPost != updatedImageUrl) {
          FirebaseFirestore.instance
              .collection('wallpaper')
              .doc(snapshot.docs[i].id)
              .update({
            'userImage': updatedImageUrl,
          });
        }
      }
    });
  }

  updateNameOnUserPosts() async {
    await FirebaseFirestore.instance
        .collection('wallpaper')
        .where('id', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((snapshot) {
      for (int i = 0; i < snapshot.docs.length; i++) {
        String userNameInPost = snapshot.docs[i]['name'];
        if (userNameInPost != updatedUserName) {
          FirebaseFirestore.instance
              .collection('wallpaper')
              .doc(snapshot.docs[i].id)
              .update({
            'name': updatedUserName,
          });
        }
      }
    });
  }

  _displayTextUnitDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Update  your namr here"),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  updatedUserName = value;
                });
              },
              decoration: InputDecoration(hintText: "Type Here..."),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color: AppColor.mainColor, fontWeight: FontWeight.bold),
                  )),
              ElevatedButton(
                  onPressed: () {
                    _updateUserName();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => ProfileScreen()));
                    updateNameOnUserPosts();
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(
                        color: AppColor.mainColor, fontWeight: FontWeight.bold),
                  )),
            ],
          );
        });
  }

  @override
  void initState() {
    _getDataFromDatabase();
  }

  void _showImageDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Please choose an option"),
            content: Column(
              children: [
                InkWell(
                  onTap: () {
                    _getFromCamera(context);
                  },
                  child: Row(
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
                  child: Row(
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
        _updateUserImage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          color: AppColor.mainColor,
        ),
        centerTitle: true,
        title: Text(
          "SnapShot",
          style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontFamily: "Billabong"),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(),
              ),
            );
          },
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  _showImageDialog();
                },
                child: CircleAvatar(
                  radius: 80,
                  backgroundImage: imageFile == null
                      ? NetworkImage(img!)
                      : Image.file(imageFile!).image,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.person),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    name!,
                    style: TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _displayTextUnitDialog(context);
                    },
                    icon: Icon(Icons.edit),
                    color: AppColor.mainColor,
                  ),
                ],
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.email),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      email!,
                      style: TextStyle(fontSize: 24, color: Colors.black),
                    ),
                  ]),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    phoneNo!,
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.only(left: 15, right: 15),
                child: Center(
                  child: LoginButton(
                      text: "Logout",
                      press: () {
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => LoginPage()));
                      }),
                ),
              )
            ]),
      ),
    ));
  }
}
