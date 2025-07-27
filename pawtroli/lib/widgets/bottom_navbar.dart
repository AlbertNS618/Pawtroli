import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawtroli/design_constant.dart';
import 'dart:developer' as developer;

Future<void> goToChat(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final adminQuery = await FirebaseFirestore.instance
        .collection("users")
        .where("role", isEqualTo: "admin")
        .limit(1)
        .get();

    final adminIdValue = adminQuery.docs.isNotEmpty ? adminQuery.docs.first.id : 'defaultAdminId';
    final chatQuery = await FirebaseFirestore.instance
        .collection('chats')
        .where('users', arrayContains: user.uid)
        .get();

    QueryDocumentSnapshot<Map<String, dynamic>>? chatDoc;
    try {
      chatDoc = chatQuery.docs.firstWhere(
        (doc) {
          final users = List<String>.from(doc['users']);
          return users.contains(adminIdValue);
        },
      );
    } catch (e) {
      chatDoc = null;
    }

    final chatIdValue = chatDoc != null ? chatDoc.id : 'defaultChatId';
    developer.log("Chat ID: $chatIdValue");
    developer.log("Admin ID: $adminIdValue");

    Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'chatId': chatIdValue,
        'adminId': adminIdValue,
      },
    );
  }
}

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  const BottomNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavImageItem(context, 0, 'assets/images/home_icon.png', 'Home'),
              _buildNavImageItem(context, 1, 'assets/images/chat_icon.png', 'Chat'),
              _buildNavImageItem(context, 2, 'assets/images/cctv_icon.png', 'CCTV'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavImageItem(BuildContext context, int index, String assetPath, String label) {
    final isActive = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(),
            padding: const EdgeInsets.all(8),
            child: Image.asset(
              assetPath,
              width: 28,
              height: 28,
              color: isActive ? DesignConstant.pawBlue : Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: isActive ? DesignConstant.pawBlue : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
