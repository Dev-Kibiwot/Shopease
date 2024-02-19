import 'package:flutter/material.dart';

class DeleteButton extends StatelessWidget {
  final void Function()? ontap;

  const DeleteButton({
    required this.ontap,
    super.key
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ontap,
      child: Icon(
        Icons.delete,
        color: Colors.red,
        ),
    );
  }
}
