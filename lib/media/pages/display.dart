import 'package:flutter/material.dart';

class DetailsPage extends StatelessWidget {
  final String prize;
  final String disc;
   DetailsPage({
    required this.disc,
    required this.prize,
    super.key
    });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          "Details",
          style: TextStyle(
            fontSize: 30
          ),
          ),
        centerTitle: true,
        ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Image.asset("assets/logo.png")),
            SizedBox(height: 10,),
            Text("Price"),
            SizedBox(height: 10,),
            Text("Description"),
            SizedBox(height: 10,),
            Align(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: (){},
                child: Text("Contact"))),
          ],
        ),
      ),
    );
  }
}