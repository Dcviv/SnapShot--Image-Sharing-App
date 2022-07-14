import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:snap_shot/screens/home_screen.dart';
import 'package:snap_shot/screens/login.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialisation = Firebase.initializeApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialisation,
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
    );
  }
}
