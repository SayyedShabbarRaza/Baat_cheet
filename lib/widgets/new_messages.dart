import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});
  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  var messageController = TextEditingController();
  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sending() async {
    final message = messageController.text;
    if (message.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    messageController.clear();
    // Sending to Firebase
    final user=FirebaseAuth.instance.currentUser!;
    final userData=await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    FirebaseFirestore.instance.collection('chat').add({
      'text':message,
      'createdAt':Timestamp.now(),
      'userId':user.uid,
      'userName':userData.data()!['username'],
      'userImage':userData.data()!['image_url'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            autocorrect: true,
            controller: messageController,
            enableSuggestions: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(labelText: 'Send a message'),
          )),
          IconButton(onPressed: sending, icon: const Icon(Icons.send))
        ],
      ),
    );
  }
}
