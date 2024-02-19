import 'package:flutter/material.dart';

class MyListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;
  const MyListTile({
    required this.icon,
    required this.text,
    required this.onTap,
    super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 10
      ),
      child: ListTile(
        onTap:onTap ,
        leading: Icon(
          icon,
          color: Colors.white,
          ),
       title: Text(
        text,
        style: TextStyle(
          color: Colors.white
        ),
        ),
    
      ),
    );
  }
}
