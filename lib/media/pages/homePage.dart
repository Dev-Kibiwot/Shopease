import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopease/media/componets/post.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  final currentUser = FirebaseAuth.instance.currentUser;
  bool isSearching = false;
  bool _isSearching = false;
  late AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot;
  List<String> titles = [];
  List<String> filteredTitles = [];
  Future<void> fetchTitles() async {
    final CollectionReference userPosts =
        FirebaseFirestore.instance.collection('User Post');
    final querySnapshot = await userPosts.get();
    querySnapshot.docs.forEach((doc) {
      if (doc.exists && doc.data() != null) {
        final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey('title')) {
          titles.add(data['title']);
        }
      }
    });
  }

  void _onSearchTextChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        isSearching = false; 
      });
    } else {
      setState(() {
        isSearching = true; 
        filteredTitles = titles
            .where((title) => title.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  Map<String, dynamic>? findPostByDescription(String description) {
    // Iterate through the posts to find the post with the matching description
    for (final post in snapshot.data!.docs) {
      if (post['title'] == description) {
        return post.data();
      }
    }
    return null;
  }
search(){
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextFormField(
      controller: _searchController,
      onChanged: (keyword) {
        _onSearchTextChanged();
      },
      decoration: InputDecoration(
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey
          )
        ),
        hintText: "Search item ...",
        hintStyle: TextStyle(color: Colors.green.shade900),
        suffixIcon: Icon(Icons.search),
        suffixIconColor: Colors.green.shade700,
      ),
    ),
  );
 }
 _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
    });
  }
  @override
  void initState() {
    super.initState();
    fetchTitles();
    // isSearching = !isSearching;
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade500,
        toolbarHeight: 65,
        elevation: 0,
        title: Text(
          'Fchat',
          style: TextStyle(
            fontSize: 30,
            color: Colors.white
           ),          
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: _toggleSearch,
                child: _isSearching ?Icon(
                  Icons.close,
                  size: 25,
                  color: Colors.white,
                ):Icon(
                  Icons.search,
                  color: Colors.white,
                  size: 25,
                )
                ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: (){
                  FirebaseAuth.instance.signOut();
                },
                child: Icon(
                  Icons.logout,
                  size: 25,
                  color: Colors.white,
                )),
            )
          ],
      ),
      body: Column(
        children: [  
          if (_isSearching)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _searchController,
                onChanged: (keyword) {
                  _onSearchTextChanged();
                },
                decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintText: "Search item ...",
                  hintStyle: TextStyle(color: Colors.green.shade900),
                  suffixIcon: Icon(Icons.search),
                  suffixIconColor: Colors.green.shade700,
                ),
              ),
            ), 
          isSearching
              ? Expanded(
                  child: filteredTitles.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.face_3_sharp,
                                size: 25,
                              ),
                              Text(
                                "No matches !!",
                                style: TextStyle(
                                  fontSize: 25
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredTitles.length,
                          itemBuilder: (context, index) {
                            final searchResult = filteredTitles[index];
                            final post = findPostByDescription(searchResult);
                            if (post != null) {
                              return Post(
                              title: post['title'],
                              imageUrl: post['Image'],
                              user: post['UserEmail'],
                              postId: '',
                              likes: List<String>.from(
                                  post['Likes'] ?? [])
                            );
                            }

                            return Container();
                          },
                        ),
                )
              : Expanded(
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection("User Post")
                        .orderBy('TimeStamp', descending: true)
                        .snapshots(),
                    builder: (context, asyncSnapshot) {
                      snapshot = asyncSnapshot; 
                      if (asyncSnapshot.hasData) {
                        return ListView.builder(
                          itemCount: asyncSnapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final post = asyncSnapshot.data!.docs[index];
                            return Post(
                              title: post['title'],
                              imageUrl: post['Image'],
                              user: post['UserEmail'],
                              postId: post.id,
                              likes: List<String>.from(
                                  post['Likes'] ?? [])
                            );
                          },
                        );
                      } else if (asyncSnapshot.hasError) {
                        return Center(
                          child: Text('Error: ${asyncSnapshot.error}'),
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

