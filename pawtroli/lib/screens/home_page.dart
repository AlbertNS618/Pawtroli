import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawtroli/screens/chat_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'admin_chat_list_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Function chatSystem() {
    // This function is not used in the current implementation
    return () {};
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final adminId = '0Vpi1y6wuCOxj10BZc6CGPMngkI2'; // Replace with your real admin UID
    final isAdmin = user != null && user.uid == adminId;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: 60,
        backgroundColor: Colors.grey[300],
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Logo', style: TextStyle(color: Colors.black)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dashboard
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text("Dashboard", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),

            // 3 circular quick buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (_) {
                return CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                );
              }),
            ),
            const SizedBox(height: 24),

            // Chat Button
            if (isAdmin)
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AdminChatListPage(adminId: adminId),
                    ),
                  );
                },
                child: const Text('Admin: View User Chats'),
              )
            else
              buildHomeButton(context, "Chat Button"),
            const SizedBox(height: 12),

            // Feeds Button
            buildHomeButton(context, "Feeds Button"),
            const SizedBox(height: 12),

            // CCTV Button
            buildHomeButton(context, "CCTV Button"),
          ],
        ),
      ),
    );
  }

  Widget buildHomeButton(BuildContext context, String title) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () async {
          if (title == "Chat Button") {
            print('Chat Button pressed');
            final user = FirebaseAuth.instance.currentUser;
            print(user);
            if (user == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('You must be signed in!')),
              );
              return;
            }
            final currentUserId = user.uid;
            // Hardcoded admin ID and name
            final adminId = '0Vpi1y6wuCOxj10BZc6CGPMngkI2'; // Replace with your real admin UID
            final otherUserName = 'Admin';

            // Generate a unique chatId (sorted to ensure uniqueness for both user-admin and admin-user)
            List<String> ids = [currentUserId, adminId];
            ids.sort();
            final chatId = ids.join('_');

            // Check if chat exists, if not, create it
            final chatDoc = FirebaseFirestore.instance.collection('chats').doc(chatId);
            final chatSnapshot = await chatDoc.get();
            if (!chatSnapshot.exists) {
              await chatDoc.set({
                'users': [currentUserId, adminId],
                'createdAt': FieldValue.serverTimestamp(),
              });
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  chatId: chatId,
                  currentUserId: currentUserId,
                  otherUserName: otherUserName,
                  adminId: adminId,
                ),
              ),
            );
          } else if (title == "Feeds Button") {
            // Navigate to feeds page
          } else if (title == "CCTV Button") {
            // Navigate to CCTV page
          }
        },
        child: Text(title, style: TextStyle(color: Colors.black, fontSize: 16)),
      ),
    );
  }
}