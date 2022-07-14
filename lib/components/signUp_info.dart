import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:snap_shot/app_res/colors.dart';
import 'package:snap_shot/screens/home_screen.dart';
import 'package:snap_shot/screens/login.dart';
import 'package:snap_shot/services/account_check.dart';
import 'package:snap_shot/widgets/input_field.dart';

import '../widgets/button.dart';

class SignUpCredentials extends StatefulWidget {
  @override
  State<SignUpCredentials> createState() => _SignUpCredentialsState();
}

class _SignUpCredentialsState extends State<SignUpCredentials> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  TextEditingController _emailTextEditingController =
      TextEditingController(text: "");

  TextEditingController _passTextEditingController =
      TextEditingController(text: "");

  TextEditingController _nameTextEditingController =
      TextEditingController(text: "");

  TextEditingController _phoneNoTextEditingController =
      TextEditingController(text: "");

  File? imageFile;
  String? imageUrl;

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
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: GestureDetector(
              onTap: () {
                _showImageDialog();
              },
              child: CircleAvatar(
                  radius: 80,
                  backgroundImage: imageFile == null
                      ? AssetImage("assets/images/avatar.png")
                      : Image.file(imageFile!).image,
                  backgroundColor: Colors.white),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          InputField(
              hintText: "User Name",
              icon: Icons.person,
              obsecureText: false,
              textEditingController: _nameTextEditingController),
          InputField(
              hintText: "Email",
              icon: Icons.email_rounded,
              obsecureText: false,
              textEditingController: _emailTextEditingController),
          InputField(
              hintText: "Phone No.",
              icon: Icons.phone,
              obsecureText: false,
              textEditingController: _phoneNoTextEditingController),
          InputField(
            hintText: "Password",
            icon: Icons.lock,
            obsecureText: true,
            textEditingController: _passTextEditingController,
          ),
          SizedBox(
            height: 15,
          ),
          LoginButton(
            text: "SIGNUP",
            press: () async {
              if (imageFile == null) {
                Fluttertoast.showToast(msg: "Please upload an image.");
                return;
              }
              try {
                //sign up user with credentials and storing user image in storage
                final ref = FirebaseStorage.instance
                    .ref()
                    .child("userImages")
                    .child(DateTime.now().toString() + ".jpg");
                await ref.putFile(imageFile!);
                imageUrl = await ref.getDownloadURL();
                await _auth.createUserWithEmailAndPassword(
                    email:
                        _emailTextEditingController.text.trim().toLowerCase(),
                    password: _passTextEditingController.text.trim());

                //Adding user info to firestore
                final User? user =
                    _auth.currentUser; //User is from firebase user
                final _uid = user!.uid;
                FirebaseFirestore.instance.collection("users").doc(_uid).set({
                  'id': _uid,
                  'userImage': imageUrl,
                  'name': _nameTextEditingController.text,
                  'email': _emailTextEditingController.text.trim(),
                  'password': _passTextEditingController.text,
                  'phoneNo.': _phoneNoTextEditingController.text,
                  'createdAt': Timestamp.now(),
                });

                Navigator.canPop(context) ? Navigator.pop(context) : null;
              } catch (error) {
                Fluttertoast.showToast(msg: error.toString());
              }
              //move to home page
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => HomeScreen()));
            },
          ),
          SizedBox(
            height: 5,
          ),
          AccountCheck(
              login: false,
              press: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => LoginPage()));
              })
        ],
      ),
    );
  }
}
