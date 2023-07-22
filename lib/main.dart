import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:snap_shot/provider/chat_provider.dart';
import 'package:snap_shot/provider/chat_tile_provider.dart';
import 'package:snap_shot/screens/home_screen.dart';
import 'package:snap_shot/screens/login.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // _initialisation = Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // final Future<FirebaseApp> _initialisation = Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  // final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  //   final FirebaseStorage firebaseStorage = FirebaseStorage.instance;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider<ChatProvider>(create: (_) => ChatProvider()
              // prefs: prefs,
              // firebaseStorage: firebaseStorage,
              // firebaseFirestore: firebaseFirestore),
              ),
          Provider<ChatTileProvider>(
            create: (_) => ChatTileProvider(),
          ),
        ],
        child: FutureBuilder(
          future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                  body: Center(
                      child: Center(
                    child: Text("Welcome to SnapShot"),
                  )),
                ),
              );
            } else if (snapshot.hasError) {
              return const MaterialApp(
                debugShowCheckedModeBanner: false,
                home: Scaffold(
                    body: Center(
                  child: Center(child: Text("Some error occured!!!")),
                )),
              );
            }
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: "SnapShot",
              home: FirebaseAuth.instance.currentUser == null
                  ? const LoginPage()
                  : HomeScreen(),
            );
          },
        ));
  }
}

//late Future<FirebaseApp> _initialisation;
