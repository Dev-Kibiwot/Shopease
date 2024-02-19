import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {

  void _onSearchTextChanged(String value) {
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 20),
          suffix: GestureDetector(onTap: () {}, child: Icon(Icons.search)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          hintText: "Search User...",
          hintStyle: TextStyle(color: Colors.grey.shade500)),
    );
  }
}
