// import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawtroli/design_constant.dart';
import '../widgets/bottom_navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _layoutMode = 0; // 0: grid, 1: list
  int _currentIndex = 0;
  String chatId = 'defaultChatId';
  String adminId = 'staff';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String getGreeting() {
      final hour = DateTime.now().hour;
      if (hour >= 5 && hour < 12) {
        return 'Good Morning!';
      } else if (hour >= 12 && hour < 17) {
        return 'Good Afternoon!';
      } else if (hour >= 17 && hour < 21) {
        return 'Good Evening!';
      } else {
        return 'Good Night!';
      }
    }

    if (_currentIndex != 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _currentIndex = 0;
        });
      });
    }
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            color: DesignConstant.pawBlue,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/profile'),
                    child: CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 28,
                      child: Icon(Icons.person, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Hello, ${getGreeting()}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance.collection('users').doc(user?.uid).snapshots(),
                          builder: (context, snapshot) {
                            String name = user?.displayName ?? 'User';
                            if (snapshot.hasData && snapshot.data!.exists) {
                              final data = snapshot.data!.data() as Map<String, dynamic>;
                              name = data['name'] ?? name;
                            }
                            return Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search Your Pet..',
                  hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.bold),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Your Pet:',
              style: TextStyle(
                color: Colors.grey[800],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(_layoutMode == 0 ? Icons.grid_view : Icons.list, color: DesignConstant.pawBlue),
                  onPressed: () {
                    setState(() {
                      _layoutMode = _layoutMode == 0 ? 1 : 0;
                    });
                  },
                  tooltip: _layoutMode == 0 ? 'Switch to List' : 'Switch to Grid',
                ),
              ],
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('pets')
                    .where('ownerId', isEqualTo: user?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Center(
                          child: Column(
                            children: [
                              Image.asset('assets/images/pet_add.png', height: 150, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              const Text(
                                "You haven't added any pets yet.",
                                style: TextStyle(fontSize: 16, color: Colors.black54),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                "Let's introduce us to your funny friend!",
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    );
                  }
                  final pets = snapshot.data!.docs;
                  if (_layoutMode == 0) {
                    // Grid layout
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: pets.length == 1 ? 1 : 2,
                        childAspectRatio: 0.85, // Decrease aspect ratio to give more vertical space
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index].data() as Map<String, dynamic>;
                        final isActive = pet['active'] == true;
                        final statusText = isActive ? pet['status'] : 'Not currently in our care';
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/pet_profile', arguments: pets[index].id);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  spreadRadius: 0.5
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  height: 64,
                                  width: 64,
                                  child: ClipOval(
                                    child: Image.network(
                                      pet['imageUrl'] ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/pet_placeholder.png',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  pet['name'] ?? '-',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive ? DesignConstant.pawBlue : const Color(0xFFE6F0FA),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isActive ? Colors.transparent : DesignConstant.pawBlue,
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center, // Center content horizontally
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if (!isActive)
                                        Icon(Icons.info, color: DesignConstant.pawBlue, size: 20),
                                      if (!isActive)
                                        const SizedBox(width: 8),
                                      Flexible(
                                        child: Text(
                                          statusText.toString(),
                                          style: TextStyle(
                                            color: isActive ? Colors.white : DesignConstant.pawBlue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 2,
                                          softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center, // Center text inside the box
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    // List layout
                    return ListView.builder(
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index].data() as Map<String, dynamic>;
                        final isActive = pet['active'] == true;
                        final statusText = isActive ? pet['status'] : 'Not currently in our care';
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(context, '/pet_profile', arguments: pets[index].id);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Always use pet_placeholder and fix oval shape
                                SizedBox(
                                  height: 64,
                                  width: 64,
                                  child: ClipOval(
                                    child: Image.network(
                                      pet['imageUrl'] ?? '',
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Image.asset(
                                          'assets/images/pet_placeholder.png',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        pet['name'] ?? '-',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                      ),
                                      const SizedBox(height: 6),
                                      isActive
                                          ? Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: DesignConstant.pawBlue,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                statusText.toString(),
                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                              ),
                                            )
                                          : Container(
                                              width: double.infinity,
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFE6F0FA),
                                                borderRadius: BorderRadius.circular(10),
                                                border: Border.all(color: DesignConstant.pawBlue, width: 0.5),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.info, color: DesignConstant.pawBlue, size: 20),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      statusText.toString(),
                                                      style: const TextStyle(
                                                        color: DesignConstant.pawBlue,
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 15,
                                                      ),
                                                      maxLines: 2,
                                                      softWrap: true,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: () {
                Navigator.pushNamed(context, '/pet_registration');
                },
                icon: const Icon(Icons.add, size: 25),
                label: const Text('Add Pet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
                style: ElevatedButton.styleFrom(
                backgroundColor: DesignConstant.pawBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                ),
              ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            goToChat(context); // Only call here!
          } else if (index == 2) {
            Navigator.pushNamed(context, '/cctv');
          }
        },
      ),  
    );
  }
}