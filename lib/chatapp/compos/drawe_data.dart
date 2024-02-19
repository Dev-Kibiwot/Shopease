import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopease/chatapp/pages/chat_screen.dart';

class MyDrawerData extends StatefulWidget {
  const MyDrawerData({super.key});

  @override
  _MyDrawerDataState createState() => _MyDrawerDataState();
}

class _MyDrawerDataState extends State<MyDrawerData> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _onSearchTextChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  final user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final usersList = snapshot.data!.docs;
            return Column(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: 150,
                    child: Image.asset("assets/Frank.png"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchTextChanged,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20),
                      suffix: GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          _onSearchTextChanged('');
                        },
                        child: Icon(Icons.search),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      hintText: "Search User...",
                      hintStyle: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: usersList.length,
                    itemBuilder: (context, index) {
                      final username =usersList[index]['email'].toString().toLowerCase();                          
                      if (_searchQuery.isEmpty ||
                          username.contains(_searchQuery.toLowerCase())) {
                        if (usersList[index]['email'] != user?.email) {
                          return Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                      return ChatDetails(
                                        email: '${usersList[index]['email']}',
                                        bio: '${usersList[index]['bio']}',
                                      );
                                    }));
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    usersList[index]['email'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black, fontSize: 20),
                                  ),
                                  Text(
                                    usersList[index]['bio'],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.black, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          // Return an empty container if it is the current user
                          return Container();
                        }

                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
