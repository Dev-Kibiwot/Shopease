import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopease/media/pages/homePage.dart';
import 'package:shopease/nav.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  File? image;

  final textcontrol = TextEditingController();
  Future pickImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final imageTemp = File(image.path);
    setState(() => this.image = imageTemp);
  }

  void postMessage() async {
    if (textcontrol.text.isEmpty && image == null) {
      // Show a dialog indicating that text and image cannot be empty
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Cannot Post Empty Message"),
            content: Text("Please enter some text or select an image."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    }

    var data = {
      "UserEmail": currentUser!.email,
      "title": "",
      "TimeStamp": DateTime.now(),
      "Image": "",
      "Likes": [],
    };

    if (textcontrol.text.isNotEmpty) {
      data["title"] = textcontrol.text;
    }

    if (image != null) {
      // Show an "Uploading, please wait" dialog
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Uploading"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text("Please wait while the image is being uploaded."),
                ],
              ),
            ),
          );
        },
      );

      // Upload the image to Firebase Storage
      var imgRef = FirebaseStorage.instance.ref().child(image!.path);
      var uploadTask = imgRef.putFile(image!);
      var uploadSnapshot = await uploadTask.whenComplete(() {});

      // Retrieve the download URL
      var imgUrl = await uploadSnapshot.ref.getDownloadURL();
      data["Image"] = imgUrl;

      // Dismiss the "Uploading" dialog
      Navigator.pop(context);
    }

    // Store the message in Firestore
    await FirebaseFirestore.instance.collection("User Post").add(data);

    // Show a bottom sheet with a success message
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => NavBar()),
            );
          },
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 48,
                ),
                SizedBox(height: 16),
                Text(
                  "Message posted successfully!",
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Text("Connect"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: TextField(
                controller: textcontrol,
                decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    fillColor: Colors.grey.shade100,
                    filled: true,
                    hintText: 'Write something',
                    hintStyle: TextStyle(color: Colors.grey.shade700)),
                maxLines: null,
              ),
            ),
            if (image != null)
              Image.file(
                File(image!.path),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                pickImage();
              },
              child: Text('Pick Image'),
            ),
            ElevatedButton(
              onPressed: () {
                postMessage();
                textcontrol.clear();
                setState(() {
                  image = null;
                });
              },
              child: Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
