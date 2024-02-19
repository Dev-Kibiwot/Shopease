// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

class Comments extends StatelessWidget {
  final String text;
  final String user;
  final String time;
  const Comments({
    required this.text,
    required this.user,
    required this.time,
    super.key
    });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8)
      ),
      margin: EdgeInsets.only(bottom: 5),
      padding:EdgeInsets.all(15) ,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(            
            children: [
              Expanded(
                child: Text(
                  user,
                  style: TextStyle(
                    color: Colors.grey[400]
                  ),
                  overflow: TextOverflow.ellipsis,
                  ),
              ),
              Text(
                " . ",
                style: TextStyle(
                  color: Colors.grey[400]
                ),
                overflow: TextOverflow.ellipsis,
                ),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey[400]
                ),
                overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
          Text(
            text,
              overflow: TextOverflow.ellipsis,
            ),
          
        ],
      ),
    );
  }
}
