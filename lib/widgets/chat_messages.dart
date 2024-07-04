import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("Chat")
          .orderBy("createdAT", descending: true)
          .snapshots(),
      builder: (context, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(
            child: Text("Nothing here"),
          );
        }
        if (chatSnapshots.hasError) {
          return const Center(
            child: Text("Something went wrong..."),
          );
        }

        final loadedMessages = chatSnapshots.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(left: 13, right: 13, bottom: 10),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final chatMessages = loadedMessages[index].data();
            final nextChatMessages = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;
            final currentUserID = chatMessages["userID"];
            final nextMessageUserID =
                nextChatMessages != null ? nextChatMessages["userID"] : null;
            final nextUserIsSame = nextMessageUserID == currentUserID;
            if (nextUserIsSame) {
              return MessageBubble.next(
                  message: chatMessages["text"],
                  
                  isMe: authenticatedUser.uid == nextMessageUserID);
            } else {
              return MessageBubble.first(
                  username: chatMessages["userName"],
                  userImage: chatMessages["userImage"],
                  message: chatMessages["text"],
                  isMe: authenticatedUser.uid == nextMessageUserID);
            }
          },
        );
      },
    );
  }
}
