import 'package:BaatCheet/widgets/chat_messages.dart';
import 'package:BaatCheet/widgets/new_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  void fcm() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token = await fcm.getToken();
    print("App Token${token}");
    fcm.subscribeToTopic('chat');
  }

  @override
  void initState() {
    super.initState();
    fcm();
  }

  @override
  Widget build(BuildContext context) {
    var message = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Baat Cheet'),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              icon: Icon(
                Icons.exit_to_app,
                color: Theme.of(context).colorScheme.primary,
              ))
        ],
      ),
      body: const Column(
        children: [
          ChatMessages(),
          NewMessages(),
        ],
      ),
    );
  }
}
