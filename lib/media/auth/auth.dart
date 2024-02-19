import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopease/media/pages/login.dart';
import 'package:shopease/nav.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {          
          return Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasData) {
          return NavBar();
        } else {
          return LogInPage();
        }
      },
    );
  }
}
