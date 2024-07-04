import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  var _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessages() async {
    final enteredMessages = _messageController.text;

    if (enteredMessages.trim().isEmpty) {
      return;
    }

    final userID = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(userID.uid)
        .get();

    FirebaseFirestore.instance.collection("Chat").add({
      "text": enteredMessages,
      "createdAT": Timestamp.now(),
      "userID": userID.uid,
      "userName": userData.data()!["username"],
      "userImage": userData.data()!["image-url"],
    });

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(
                  labelText: "Send a message...",
                  labelStyle: TextStyle(color: Colors.grey)),
            ),
          ),
          IconButton(
            onPressed: _submitMessages,
            icon: const Icon(Icons.send_rounded),
            color: Theme.of(context).colorScheme.primary,
          )
        ],
      ),
    );
  }
}
