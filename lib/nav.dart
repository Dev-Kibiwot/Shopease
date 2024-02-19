import 'package:flutter/material.dart';
import 'package:shopease/chatapp/pages/home.dart';
import 'package:shopease/media/pages/homePage.dart';
import 'package:shopease/media/pages/profile.dart';
import 'package:shopease/media/pages/upload.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    ChatApp(),
    UploadScreen(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        onTap: (value) {
          setState(() {
            currentIndex = value;                

          });
        },
        currentIndex: currentIndex,
        backgroundColor: Colors.grey,        
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.black,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
          BottomNavigationBarItem(
              icon: CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  )), label: "Post"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}