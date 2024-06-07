import 'package:BaatCheet/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    return Expanded(
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('chat')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (ctx, chatSnapshot) {
            if (chatSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No Message found.'));
            }
            if (chatSnapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }
            final loadedMessage = chatSnapshot.data!.docs;
            return ListView.builder(
                padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
                reverse: true,
                itemCount: loadedMessage.length,
                itemBuilder: (context, index) {
                  final chatMessage = loadedMessage[index].data() as Map<String, dynamic>;
                  final nextChatMessage = index + 1 < loadedMessage.length
                      ? loadedMessage[index + 1].data() as Map<String, dynamic>?
                      : null;
                  final currentUserId = chatMessage['userId'];
                  final nextMessgeUserId =
                      nextChatMessage != null ? nextChatMessage['userId'] : null;
                  final nextUserIsSame = nextMessgeUserId == currentUserId;
                  if (nextUserIsSame) {
                    return MessageBubble.next(
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentUserId,
                    );
                  } else {
                    return MessageBubble.first(
                      userImage: chatMessage['userImage'],
                      username: chatMessage['userName'],
                      message: chatMessage['text'],
                      isMe: authenticatedUser.uid == currentUserId,
                    );
                  }
                });
          }),
    );
  }
}
