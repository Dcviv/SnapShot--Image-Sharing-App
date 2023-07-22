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
  String? description;
  String? updatedUserDescription = "";
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
          description = snapshot.data()!["userDescription"].toString();
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

  Future _updateUserDescription() async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'userDescription': updatedUserDescription,
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

  _displayTextUnitDialog(
      BuildContext context, String title, bool updateUser) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              onChanged: (value) {
                setState(() {
                  updateUser
                      ? updatedUserName = value
                      : updatedUserDescription = value;
                });
              },
              decoration: const InputDecoration(hintText: "Type Here..."),
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                        color: AppColor.mainColor, fontWeight: FontWeight.bold),
                  )),
              ElevatedButton(
                  onPressed: () {
                    if (updateUser == true) {
                      _updateUserName();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => ProfileScreen()));
                      updateNameOnUserPosts();
                    } else {
                      _updateUserDescription();
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => ProfileScreen()));
                      // updateDescriptionOnUserPosts();
                    }
                  },
                  child: const Text(
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
    super.initState;
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
        title: const Text(
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
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection("users")
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .snapshots(), //we take snapshot of a collection not document
          builder: (context, AsyncSnapshot snapshot) {
            //AsyncSnapshot snapshot
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColor.mainColor,
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.data != null) {
                return Container(
                  padding: const EdgeInsets.all(20),
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
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.person),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              name!,
                              style: const TextStyle(
                                fontSize: 28,
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _displayTextUnitDialog(
                                    context, "Update your user name!", true);
                              },
                              icon: const Icon(Icons.edit),
                              color: AppColor.mainColor,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.description),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                description!,
                                style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 3,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                _displayTextUnitDialog(
                                    context, "About Me!", false);
                              },
                              icon: const Icon(Icons.edit),
                              color: AppColor.mainColor,
                            ),
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.email),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                email!,
                                style: const TextStyle(
                                    fontSize: 24, color: Colors.black),
                              ),
                            ]),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.phone,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              phoneNo!,
                              style: const TextStyle(
                                fontSize: 24,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 15, right: 15),
                          child: Center(
                            child: LoginButton(
                                text: "Logout",
                                press: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const LoginPage()));
                                }),
                          ),
                        )
                      ]),
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
    ));
  }
}
