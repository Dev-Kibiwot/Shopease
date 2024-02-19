import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatDetails extends StatefulWidget {
  final String email;
  final String bio;

  ChatDetails({
    Key? key,
    required this.email,
    required this.bio,
  }) : super(key: key);

  @override
  State<ChatDetails> createState() => _ChatDetailsState();
}

class _ChatDetailsState extends State<ChatDetails> {
  final text = TextEditingController();
  final currentuser = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;
  late CollectionReference<Map<String, dynamic>> _privateMessagesCollection;

  @override
  void initState() {
    super.initState();
    _privateMessagesCollection = firestore.collection(
        'private_messages'
        ); 
  }

  // Function to send a message from the current user to the recipient user
  Future<void> _sendMessage(String message) async {
    try {
      await _privateMessagesCollection.add({
        'sender': currentuser?.email,
        'receiver': widget.email,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      showBottomSheet(
          context: context,
          builder: (context) => Text('Error sending message: $e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.email),
            Text(widget.bio),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('private_messages')
                    .where('sender', isEqualTo: currentuser?.email)
                    .where('receiver', isEqualTo: widget.email)
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, senderSnapshot) {
                  if (senderSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child:Text("Please wait..."));
                  }
                  
                  final senderMessages = senderSnapshot.data?.docs;
                  
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: FirebaseFirestore.instance
                        .collection('private_messages')
                        .where('sender', isEqualTo: widget.email)
                        .where('receiver', isEqualTo: currentuser?.email)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, receiverSnapshot) {
                      if (receiverSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: const CircularProgressIndicator());
                      }
                  
                      final receiverMessages = receiverSnapshot.data?.docs;
                  
                      final allMessages =
                          (senderMessages ?? []) + (receiverMessages ?? []);
                  
                      allMessages.sort((a, b) {
                        final aTimestamp = a['timestamp'];
                        final bTimestamp = b['timestamp'];
                        return bTimestamp.compareTo(aTimestamp);
                      });                  
                      return ListView.builder(
                        reverse: true,
                        itemCount: allMessages.length,
                        itemBuilder: (context, index) {
                          final message = allMessages[index].data();
                          final sender = message['sender'];
                          final messageText = message['message'];
                          final isCurrentUser = sender == currentuser?.email;
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Wrap(
                              alignment: isCurrentUser
                                  ? WrapAlignment.end
                                  : WrapAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, 
                                      vertical: 8
                                      ),
                                  decoration: BoxDecoration(
                                    color:isCurrentUser ? Colors.blue : Colors.green,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    messageText,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
            TextField(
              controller: text,
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  suffix: GestureDetector(
                      onTap: () {
                        if (text.text.trim().isNotEmpty) {
                          _sendMessage(text.text);
                          text.clear();
                        }
                      },
                      child: const Icon(Icons.send)),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  hintText: "Write message...",
                  hintStyle: TextStyle(color: Colors.grey.shade500)),
            ),
          ],
        ),
      ),
    );
  }
}
