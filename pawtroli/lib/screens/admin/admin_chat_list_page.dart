import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawtroli/design_constant.dart';
import 'package:pawtroli/widgets/bottom_navbar.dart';
import '../chat/chat_page.dart';
import 'dart:developer' as developer;
import '../../services/chat_service.dart';

class AdminChatListPage extends StatelessWidget {
  final String adminId;
  const AdminChatListPage({super.key, required this.adminId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 90, // Set exact height of AppBar
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: DesignConstant.pawBlue,
        title: const Text(
          'Pawrent Chats', 
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body:  StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('chats').snapshots(),
        builder: (context, snapshot) {
          // Debug what's happening
          developer.log('Chat snapshot state: ${snapshot.connectionState}');
          if (snapshot.hasError) {
            developer.log('Chat error: ${snapshot.error}');
            return Center(child: Text('Error loading chats: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No user chats yet."));
          }

          // Log how many chat documents were returned
          developer.log('Found ${snapshot.data!.docs.length} chat documents');

          // If first document exists, log its structure
          if (snapshot.data!.docs.isNotEmpty) {
            developer.log('First chat data: ${snapshot.data!.docs[0].data()}');
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chatDoc = chats[index];
              final data = chatDoc.data() as Map<String, dynamic>;

              // Determine the other user’s ID (as you already have)
              String otherUserId = '';
              if (data.containsKey('users')) {
                final parts = List<String>.from(data['users']);
                otherUserId = parts.firstWhere((id) => id != adminId, orElse: () => '');
              } else {
                otherUserId = data['userId'] as String? ?? '';
              }

              // Pull out last message
              final lastMessage = data['lastMessage'] as String? ?? '';

              if (otherUserId.isEmpty) {
                // Fallback if we couldn’t find a userId
                return ListTile(
                  title: const Text('Unknown User'),
                  subtitle: Text(lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                );
              }

              // Otherwise we have a non‐empty ID—safe to call .doc(...)
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUserId)
                    .get(),
                builder: (ctx, snap) {
                  final displayName = snap.hasData && snap.data!.exists
                      ? (snap.data!.data()! as Map)['name'] ?? otherUserId
                      : otherUserId;

                  return FutureBuilder<Map<String, String>>(
                    future: ChatService().getLatestMessageInfo(chatDoc.id),
                    builder: (ctx2, msgSnap) {
                      String shown = 'No messages yet';
                      if (msgSnap.connectionState != ConnectionState.done) {
                        shown = 'Loading…';
                      } else if (msgSnap.hasData && msgSnap.data!.isNotEmpty) {
                        final info = msgSnap.data!;
                        var text = info['content']!;
                        if (text.length > 25) text = '${text.substring(0,25)}…';
                        final who = info['senderId'] == adminId ? 'You' : displayName;
                        shown = '$who: $text';
                      }
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.grey,
                          radius: 28,
                          child: Icon(Icons.person, color: Colors.white, size: 20),
                        ),
                        minVerticalPadding: 12,
                        title: Text(displayName, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text(
                          shown,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatPage(
                                chatId: chatDoc.id,
                                currentUserId: adminId,
                                otherUserName: displayName,
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
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/admin_home');
          } else if (index == 1) {
            //Already in Chat List Page
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/admin_cctv');
          }
        },
      ),
    );
  }
}
