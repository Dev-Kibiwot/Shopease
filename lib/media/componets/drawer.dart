// ignore_for_file: prefer_const_constructors
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopease/media/componets/my_Listtike.dart';
import 'package:shopease/media/pages/profile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({
    super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.grey[900],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                DrawerHeader(
                child: Icon(
              Icons.person,
              color: Colors.white,
              size: 65,
            )),
            MyListTile(
              onTap: () => Navigator.pop(context),
              icon: Icons.home,
              text: "HOME",
            ),
            MyListTile(
              onTap: () => Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage())),
              icon: Icons.person,
              text: "PROFILE",
            ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom:25.0),
              child: MyListTile(
                onTap: () => FirebaseAuth.instance.signOut(),
                icon: Icons.logout,
                text: "Log out",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
