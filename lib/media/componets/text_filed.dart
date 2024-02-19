// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController control;
  final String hinttext;
  final bool obsecure;
  const MyTextField({
    required this.control,
    required this.hinttext,
    required this.obsecure,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25
      ),
      child: TextField(
        controller: control,
        obscureText: obsecure,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          fillColor: Colors.grey.shade100,
          filled: true,
          hintText: hinttext,
          hintStyle: TextStyle(
            color: Colors.grey.shade500
          )
        ),
        
      ),
    );
  }
}
