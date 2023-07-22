import "dart:io";

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  TextEditingController _descriptionTextEditingController =
      TextEditingController(text: "");

  File? imageFile;
  String? imageUrl = "https://cdn-icons-png.flaticon.com/512/6915/6915987.png";
  bool errorOccured = false;
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
    // if (pickedImage != null) {
    //   setState(() {
    //     imageFile = File(pickedImage.path);
    //   });
    // }
    Navigator.pop(context);
  }

  void _getFromGallery(BuildContext context) async {
    XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    // if (pickedImage != null) {
    //   setState(() {
    //     imageFile = File(pickedImage.path);
    //   });
    // }
    _cropImage(pickedImage!.path);
    Navigator.pop(context);
  }

  void _cropImage(filePath) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: filePath,
      maxHeight: 1080,
      maxWidth: 1080,
      // uiSettings: [
      //   AndroidUiSettings(
      //       toolbarTitle: 'Cropper',
      //       toolbarColor: Colors.deepOrange,
      //       toolbarWidgetColor: Colors.white,
      //       initAspectRatio: CropAspectRatioPreset.original,
      //       lockAspectRatio: false),
      //   IOSUiSettings(
      //     title: 'Cropper',
      //   ),
      //   WebUiSettings(
      //     context: context,
      //     presentStyle: CropperPresentStyle.dialog,
      //     boundary:  Boundary(
      //       width: 520,
      //       height: 520,
      //     ),
      //     viewPort:
      //         const CroppieViewPort(width: 480, height: 480, type: 'circle'),
      //     enableExif: true,
      //     enableZoom: true,
      //     showZoomer: true,
      //   ),
      // ],
    );
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
                      ? const AssetImage("assets/images/avatar.png")
                      : kIsWeb
                          ? Image.network(imageFile!.path).image
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
              hintText: "About Me...",
              icon: Icons.description,
              obsecureText: false,
              textEditingController: _descriptionTextEditingController),
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
          const SizedBox(
            height: 15,
          ),
          LoginButton(
            text: "SIGNUP",
            press: () async {
              if (imageFile == null) {
                Fluttertoast.showToast(msg: "Please upload an image.");
                return;
              }
              if (_emailTextEditingController.text.isEmpty) {
                Fluttertoast.showToast(msg: "Please enter an email.");
                return;
              }
              if (_passTextEditingController.text.isEmpty) {
                Fluttertoast.showToast(msg: "Please enter a password.");
                return;
              }
              if (_nameTextEditingController.text.isEmpty) {
                Fluttertoast.showToast(msg: "Please enter a user name.");
                return;
              }
              if (_phoneNoTextEditingController.text.isEmpty) {
                Fluttertoast.showToast(msg: "Please enter a mobile number.");
                return;
              }
              if (_descriptionTextEditingController.text.isEmpty) {
                Fluttertoast.showToast(msg: "Please enter a description.");
                return;
              }

              try {
                //sign up user with credentials and storing user image in storage
                String? imageUrl;
                // final ref = FirebaseStorage.instance
                //     .ref()
                //     .child("userImages")
                //     .child(DateTime.now().toString() + ".jpg");
                // print("here1");

                // fb.UploadTaskSnapshot uploadTaskSnapshot =
                //     await storageRef.put(image).future;
//
                if (kIsWeb) {
                  File image = imageFile!;
                  print("here1");
                  //Create a reference to the location you want to upload to in firebase
                  Reference reference =
                      FirebaseStorage.instance.ref().child("userImages");
                  print("here2");
                  //Upload the file to firebase
                  UploadTask uploadTask = reference.putFile(image);
                  print("here3");
                  imageUrl = await reference.getDownloadURL();
                  print("here4");
                  // Waits till the file is uploaded then stores the download url
                  //Uri location = (await uploadTask.future).downloadUrl;
                } else {
                  final ref = FirebaseStorage.instance
                      .ref()
                      .child("userImages")
                      .child(DateTime.now().toString() + ".jpg");
                  await ref.putFile(imageFile!);

                  imageUrl = await ref.getDownloadURL();
                }

                //  Uri imageUri = Uri.parse(imageUrl);

                // await ref.putFile(imageFile!);
                // print("here2");
                // imageUrl = await ref.getDownloadURL();
                // print("here4");
                print("here1");
                await _auth.createUserWithEmailAndPassword(
                    email:
                        _emailTextEditingController.text.trim().toLowerCase(),
                    password: _passTextEditingController.text.trim());
                print("here3");

                //Adding user info to firestore
                final User? user =
                    _auth.currentUser; //User is from firebase user
                final _uid = user!.uid;
                print("here5");
                FirebaseFirestore.instance.collection("users").doc(_uid).set({
                  'id': _uid,
                  'userImage': imageUrl,
                  'name': _nameTextEditingController.text.trim(),
                  'email': _emailTextEditingController.text.trim(),
                  'password': _passTextEditingController.text,
                  'phoneNo.': _phoneNoTextEditingController.text,
                  'createdAt': Timestamp.now(),
                  'userDescription': _descriptionTextEditingController.text,
                });
                print("here6");

                Navigator.canPop(context) ? Navigator.pop(context) : null;
                print("here7");
              } catch (error) {
                errorOccured = true;
                print(error.toString());
                Fluttertoast.showToast(
                    msg:
                        "Email is badly formatted. Please enter in correct format.eg- example@gmail.com");
              }
              //move to home page
              if (!errorOccured) {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (_) => HomeScreen()));
              }
            },
          ),
          const SizedBox(
            height: 5,
          ),
          AccountCheck(
              login: false,
              press: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const LoginPage()));
              })
        ],
      ),
    );
  }
}
//   WebUiSettings(
//       {required BuildContext context,
//       required presentStyle,
//       required boundary,
//       required viewPort,
//       required bool enableExif,
//       required bool enableZoom,
//       required bool showZoomer}) {}
// }

//   WebUiSettings(BuildContext context) {
//     customDialogBuilder:
//     (cropper, crop, rotate) {
//       return Dialog(
//         child: Builder(
//           builder: (context) {
//             return Column(children: [
//               cropper,
//               TextButton(
//                 onPressed: () async {
//                   /// it is important to call crop() function and return
//                   /// result data to plugin, for example:
//                   final result = await crop();
//                   Navigator.of(context).pop(result);
//                 },
//                 child: Text('Crop'),
//               )
//             ]);
//           },
//         ),
//       );
//     };
//   }
// }
// // WebUiSettings(

//    customDialogBuilder: (cropper, crop, rotate) {
//       return Dialog(
//        child: Builder(
//          builder: (context) {
//           return Column(
//             children: [
//               ...
//               cropper,
//               ...
//               TextButton(
//                 onPressed: () async {
//                   /// it is important to call crop() function and return
//                   /// result data to plugin, for example:
//                   final result = await crop();
//                   Navigator.of(context).pop(result);
//                 },
//                 child: Text('Crop'),
//               )
//             ]
//           );
//         },
//        ),
//      );
//    },

//  )
