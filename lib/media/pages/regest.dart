// ignore_for_file: prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopease/media/componets/button.dart';
import 'package:shopease/media/componets/text_filed.dart';
import 'package:shopease/media/pages/login.dart';
import 'package:shopease/nav.dart';
import 'package:sign_in_button/sign_in_button.dart';

class RegestPage extends StatefulWidget {
  const RegestPage({super.key});

  @override
  State<RegestPage> createState() => _RegestPageState();
}

class _RegestPageState extends State<RegestPage> {
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmpassword = TextEditingController();
  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(message),
            ));
  }

  void signUp() async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));

    if (password.text != confirmpassword.text) {
      Navigator.pop(context);
      displayMessage("Password don't match");
      return;
    }
    try {
      //create new user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.text, password: password.text);

      //add users to firebase

      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'username': email.text.split('@')[0],
        'email': email.text,
        'bio': "Empty bio...",
        'userId': userCredential.user?.uid,
      });
      if (context.mounted) {
        Center(
          child: CircularProgressIndicator(),
        );
        Navigator.pop(context);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavBar()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Text(e.message.toString()),
              ));
    }
  }

  bool _isSigningIn = false;

  void signInWithGoogle() async {
    try {
    showDialog(
      barrierColor: Colors.white54,
      barrierLabel: 'Loading please wait..',
      context: context,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );    
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser != null) {
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
         
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final User? user = userCredential.user;
        
      if (user != null) {
        Navigator.of(context).pop();

        // Save user information to Firestore
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.email)
            .set({
          'username': user.email!.split('@')[0],
          'email': user.email,
          'bio': "Empty bio...",
          'userId': user.uid,

        }        
        );

        // Navigate to NavBar page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NavBar(), 
            // Replace with your actual NavBar widget
          ),
        );
      }
    }
  }on FirebaseAuthException catch (e) {
    // Dismiss the loading indicator
    Navigator.of(context).pop();
    // Show error dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(e.message.toString()),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade300,
        body: SafeArea(
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                  height: MediaQuery.of(context).size.height*0.09,
                ),
                //logo
                Container(
                  height: MediaQuery.of(context).size.height*0.15,
                  child: Image.asset("assets/Frank.png")),
                  //welcome
                  Text(
                    "Create Account",
                    style: TextStyle(
                      color: Colors.grey.shade800,
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  MyTextField(
                      control: email, hinttext: "Email", obsecure: false),
                  SizedBox(
                    height: 10,
                  ),
                  MyTextField(
                      control: password, hinttext: "Password", obsecure: true),
                  SizedBox(
                    height: 10,
                  ),
                  MyTextField(
                      control: confirmpassword,
                      hinttext: "Confirm Password",
                      obsecure: true),
                  SizedBox(
                    height: 10,
                  ),
                  MyButton(
                      onTap: () {
                        signUp();
                      },
                      text: "Sign Up"),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already a member?",
                        style: TextStyle(
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (contex) => LogInPage()));
                        },
                        child: Text(
                          "Log In",
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Align(
                  alignment: Alignment.center,
                  child: SignInButton(
                    Buttons.google,
                    onPressed: signInWithGoogle,
                    text: _isSigningIn
                        ? "Please wait...."
                        : 'Create account with Google',
                  ))
            ],
          ),
        ));
  }
}
