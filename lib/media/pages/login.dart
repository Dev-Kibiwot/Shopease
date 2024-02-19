import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shopease/media/componets/button.dart';
import 'package:shopease/media/componets/text_filed.dart';
import 'package:shopease/media/pages/regest.dart';
import 'package:shopease/nav.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  bool _isSigningIn = false;

  void displayMessage(String message) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(message),
            ));
  }

  final TextEditingController email = TextEditingController();
  final TextEditingController password = TextEditingController();

  //sign in

  void signIn() async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email.text, password: password.text);
      if (context.mounted) {
        Navigator.pop(context);
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NavBar()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      displayMessage(e.code);
    }
  }

  void _reset() async {
    showDialog(
        context: context,
        builder: (context) => Center(
              child: CircularProgressIndicator(),
            ));
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text);
      Navigator.pop(context);
      showDialog(
        barrierColor: Colors.white54,
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Email sent successfully..Check your G-mail account"),
          );
        },
      );

      setState(() {});
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the "Please wait" dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(e.message.toString()),
        ),
      );

      setState(() {});
    }
  }

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
          });

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
    } on FirebaseAuthException catch (e) {
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
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.09,
                ),

                //logo
                Container(
                    height: MediaQuery.of(context).size.height * 0.15,
                    child: Image.asset("assets/Frank.png")),
                //welcome
                Text(
                  "Hi there...",
                  style: TextStyle(
                    color: Colors.grey.shade900,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                MyTextField(control: email, hinttext: "Email", obsecure: false),
                SizedBox(
                  height: 10,
                ),
                MyTextField(
                    control: password, hinttext: "Password", obsecure: true),
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: MaterialButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                content: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 15),
                                  child: TextField(
                                    controller: email,
                                    decoration: InputDecoration(
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        focusedBorder: const OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.white),
                                        ),
                                        fillColor: Colors.grey.shade100,
                                        filled: true,
                                        hintText: "Enter Your email E-mail",
                                        hintStyle: TextStyle(
                                            color: Colors.grey.shade500)),
                                  ),
                                ),
                                actions: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _reset();
                                      },
                                      child: Text('Send Reset Email'),
                                    ),
                                  )
                                ],
                              ));
                    },
                    child: Text(
                      "Forgot password?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                MyButton(
                    onTap: () {
                      signIn();
                    },
                    text: "Sign In"),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Not a member?",
                      style: TextStyle(
                        color: Colors.grey.shade900,
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
                                builder: (contex) => RegestPage()));
                      },
                      child: Text(
                        "Regest now",
                        style: TextStyle(
                            color: Colors.blue, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                SignInButton(
                  Buttons.google,
                  onPressed: signInWithGoogle,
                  text:
                      _isSigningIn ? "Please wait...." : 'Sign In with Google',
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
