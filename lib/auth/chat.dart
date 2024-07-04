import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void setupPushNotifications() async {
    final messaging = FirebaseMessaging.instance;
    final notification = await messaging.requestPermission();
    notification.alert;
    notification.announcement;

    messaging.subscribeToTopic("chat");
  }

  @override
  void initState() {
    super.initState();

    setupPushNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat Room",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
        ],
      ),
      body: const Column(
        children: [Expanded(child: ChatMessages()), NewMessages()],
      ),
    );
  }
}
