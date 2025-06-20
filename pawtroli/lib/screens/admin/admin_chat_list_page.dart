import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../chat/chat_page.dart';
import 'dart:developer' as developer;

class AdminChatListPage extends StatelessWidget {
  final String adminId;
  const AdminChatListPage({super.key, required this.adminId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Chats')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('users', arrayContains: adminId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final chats = snapshot.data!.docs;
          if (chats.isEmpty) {
            return const Center(child: Text('No user chats yet.'));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final users = List<String>.from(chat['users']);
              final otherUserId = users.firstWhere((id) => id != adminId);
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                builder: (context, userSnapshot) {
                  String userName = otherUserId;
                  developer.log("userSnapshot.hasData: ${userSnapshot.hasData}");
                  if (userSnapshot.hasData) {
                    developer.log("userSnapshot.data: ${userSnapshot.data}");
                    if (userSnapshot.data!.exists) {
                      final data = userSnapshot.data!.data() as Map<String, dynamic>;
                      developer.log("User data: $data");
                      userName = data['name'] ?? "Unknown User";
                    } else {
                      developer.log("User document does not exist for $otherUserId");
                    }
                  } else {
                    developer.log("No data for $otherUserId");
                  }
                  return StreamBuilder<QuerySnapshot>(
                    stream: chat.reference
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, msgSnapshot) {
                      String lastMsg = '';
                      if (msgSnapshot.hasData && msgSnapshot.data!.docs.isNotEmpty) {
                        final userDocs = msgSnapshot.data!.docs
                            .where((doc) => doc['senderId'] == otherUserId)
                            .toList();
                        final userMsg = userDocs.isNotEmpty
                            ? userDocs.first
                            : msgSnapshot.data!.docs.first;
                        lastMsg = userMsg['content'] ?? '';
                      }
                      return ListTile(
                        title: Text(userName),
                        subtitle: Text(lastMsg, maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                chatId: chat.id,
                                currentUserId: adminId,
                                otherUserName: userName,
                                adminId: adminId,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
