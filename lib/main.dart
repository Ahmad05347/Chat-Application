import 'package:chat_app/auth/auth.dart';
import 'package:chat_app/auth/chat.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData()
          .copyWith(useMaterial3: true, colorScheme: const ColorScheme.dark()),
      debugShowCheckedModeBanner: false,
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshots) {
          if (snapshots.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(
              backgroundColor: Theme.of(context).colorScheme.primary,
              color: Theme.of(context).colorScheme.primaryContainer,
            );
          }

          if (snapshots.hasData) {
            return const ChatScreen();
          }
          return const AuthScreens();
        },
      ),
    );
  }
}
