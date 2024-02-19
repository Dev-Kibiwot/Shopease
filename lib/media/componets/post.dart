// ignore_for_file: prefer_const_constructors

import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopease/chatapp/pages/chat_screen.dart';
import 'package:shopease/chatapp/pages/home.dart';
import 'package:shopease/media/componets/comments.dart';
import 'package:shopease/media/componets/delete_button.dart';
import '../helper/time.dart';
import 'comment_button.dart';
import 'like_button.dart';

class Post extends StatefulWidget {
  final user;
  final imageUrl;
  final title;
  final postId;
  final List<String> likes;
  const Post({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.user,
    required this.postId,
    required this.likes,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  final commentcontrol = TextEditingController();
  void onClosing() {}
  final curentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;
  @override
  void initState() {
    isLiked = widget.likes.contains(curentUser.email);
    super.initState();
  }

  void toogleLike() {
    setState(() {
      isLiked = !isLiked;
    });
    DocumentReference postRef =FirebaseFirestore.instance.collection('User Post').doc(widget.postId);
    if (isLiked) {
      postRef.update({
        'Likes': FieldValue.arrayUnion([curentUser.email])
      });
    } else {
      postRef.update({
        'Likes': FieldValue.arrayRemove([curentUser.email])
      });
    }
  }

  void addComment(String comment) {
    FirebaseFirestore.instance
        .collection("User Post")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": comment,
      "CommentedBy": curentUser.email,
      "CommentTime": Timestamp.now()
    });
  }

  void deletePost() {
    //confirm
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Delete post"),
              content: Text("Are you sure you want to delete this post??"),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text("Cancel")),
                TextButton(
                    onPressed: () async {
                      final commentDocs = await FirebaseFirestore.instance
                          .collection("User Post")
                          .doc(widget.postId)
                          .collection('Comments')
                          .get();

                      for (var doc in commentDocs.docs) {
                        await FirebaseFirestore.instance
                            .collection("User Post")
                            .doc(widget.postId)
                            .collection("Comments")
                            .doc(doc.id)
                            .delete();
                      }
                      FirebaseFirestore.instance
                          .collection("User Post")
                          .doc(widget.postId)
                          .delete()
                          .then((value) => BottomSheet(
                              backgroundColor: Colors.grey,
                              onClosing: onClosing,
                              builder: (contex) => Text("Post Deleted")));
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    child: Text("Yes"))
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      margin: EdgeInsets.only(top: 10, left: 20, right: 20),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors
                        .primaries[Random().nextInt(Colors.primaries.length)]
                        .shade300,
                  ),
                  SizedBox(
                    width: 6,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => ChatApp()));
                    },
                    child: Text(
                      widget.user.toString(),
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
              widget.user == curentUser.email
                  ? Align(
                      alignment: Alignment.topRight,
                      child: DeleteButton(ontap: deletePost))
                  : Text(
                      "",
                      style: TextStyle(color: Colors.grey),
                    ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Text(widget.title),
          SizedBox(
            height: 10,
          ),
          widget.imageUrl == ""
              ? Container()
              : Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * .25,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    child:CachedNetworkImage(
                      imageUrl: widget.imageUrl,
                      progressIndicatorBuilder: (context, url, downloadProgress) => 
                      Text(
                        "Loading image...."     
                      ),
                  ),
                ),
              ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  LikeButton(
                    isLiked: isLiked,
                    onTap: toogleLike,
                  ),
                  Text(widget.likes.length.toString())
                ],
              ),
              Column(
                children: [
                  CommentButton(onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.height * .1),
                        child: AlertDialog(
                          title: Text("Commments"),
                          content: ListView(
                            children: [
                              StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection("User Post")
                                      .doc(widget.postId)
                                      .collection("Comments")
                                      .orderBy("CommentTime", descending: true)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Center(
                                        child: CircularProgressIndicator(),
                                      );
                                    } else {
                                      return ListView(
                                        shrinkWrap: true,
                                        physics: BouncingScrollPhysics(),
                                        children:
                                            snapshot.data!.docs.map((doc) {
                                          final commentData = doc.data();
                                          return Comments(
                                            text: commentData['CommentText'],
                                            user: commentData['CommentedBy'],
                                            time: formatDate(
                                                commentData["CommentTime"]),
                                          );
                                        }).toList(),
                                      );
                                    }
                                  }),
                            ],
                          ),
                          actions: [
                            TextField(
                              controller: commentcontrol,
                              decoration: InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  fillColor: Colors.grey.shade100,
                                  filled: true,
                                  hintText: "Add Comment",
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade900)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  TextButton(
                                      onPressed: () {
                                        commentcontrol.clear();
                                        Navigator.pop(context);
                                      },
                                      child: Text(
                                        "Cancel",
                                        style: TextStyle(
                                            color: const Color.fromARGB(
                                                255, 207, 28, 28)),
                                      )),
                                  TextButton(
                                      onPressed: () {
                                        if (commentcontrol.text.isNotEmpty) {
                                          addComment(commentcontrol.text);
                                          commentcontrol.clear();
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text(
                                        "Post",
                                        style: TextStyle(
                                            color: Colors.blue.shade900),
                                      ))
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
         widget.imageUrl != ""?  Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ChatDetails(email: widget.user, bio: '')));
                  },
                  child: Text(
                    "Contact",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  )
                  )
                  ):Text('')
        ]
      ),
    );
    
  }
}
