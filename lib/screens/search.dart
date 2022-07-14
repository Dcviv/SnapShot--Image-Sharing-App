import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:snap_shot/app_res/colors.dart';
import 'package:snap_shot/model/user_model.dart';
import 'package:snap_shot/widgets/user_results_design.dart';

import 'home_screen.dart';

class SearchPage extends StatefulWidget {
  SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  Future<QuerySnapshot>? postDocumentList;
  String userNameText = "";
  initSearchingPosts(String enteredText) {
    postDocumentList = FirebaseFirestore.instance
        .collection('users')
        .where('name', isGreaterThanOrEqualTo: enteredText)
        .get();
    setState(() {
      postDocumentList;
    });
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
        title: TextField(
          onChanged: (textEntered) {
            setState(() {
              userNameText = textEntered;
            });
            initSearchingPosts(textEntered);
          },
          decoration: InputDecoration(
            hintText: Text(
              "Search...",
              style: TextStyle(color: Colors.white),
            ).data.toString(),
            hintStyle: TextStyle(color: Colors.white),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                initSearchingPosts(userNameText);
              },
            ),
            prefixIcon: IconButton(
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
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: postDocumentList,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    Users userModel = Users.from_JSON(snapshot.data!.docs[index]
                        .data()! as Map<String, dynamic>);
                    return UserDesignWidget(
                        context: context, userModel: userModel);
                  },
                )
              : const Center(
                  child: Text("No such user found"),
                );
        },
      ),
    ));
  }
}
