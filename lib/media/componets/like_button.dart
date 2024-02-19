import 'package:flutter/material.dart';

// ignore: must_be_immutable
class LikeButton extends StatelessWidget {
  final bool isLiked;
  void Function()? onTap;
   LikeButton({
    required this.isLiked,
    required this.onTap,
    super.key
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        isLiked? Icons.favorite:Icons.favorite_border,
        color: isLiked?Colors.red:Colors.grey,
      ),
    );
  }
}
