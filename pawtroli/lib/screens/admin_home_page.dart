import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawtroli/widgets/bottom_navbar.dart';

import '../design_constant.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _layoutMode = 0; // 0: grid, 1: list
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            color: DesignConstant.pawBlue, // Use your design constant for the color
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/profile');
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.grey[300],
                      radius: 28,
                      child: Icon(Icons.person, color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Hello, Good Morning!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Staff',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FloatingActionButton.extended(
                    onPressed: () {
                      Navigator.pushNamed(context, '/pet_activation');
                    },
                    backgroundColor: Colors.white,
                    foregroundColor: DesignConstant.pawBlue,
                    label: Text('Activate', style: TextStyle(fontSize: 12)),
                    icon: Icon(Icons.pets),
                  )
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
                  hintText: 'Search..',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 18),
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
                stream: FirebaseFirestore.instance.collection('pets').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("No pets registered yet."));
                  }

                  // only show active pets
                  final activePets = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['active'] == true;
                  }).toList();

                  if (activePets.isEmpty) {
                    return const Center(child: Text("No active pets."));
                  }

                  if (_layoutMode == 0) {
                    return GridView.builder(
                      itemCount: activePets.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) {
                        final petDoc = activePets[index];
                        final pet = petDoc.data() as Map<String, dynamic>;
                        final name = pet['name'] ?? pet['Name'] ?? '-';
                        final isActive = pet['active'] as bool? ?? false;

                        return GestureDetector(
                          onTap: () {
                            if(isActive) {
                              Navigator.pushNamed(context, '/admin_pet_profile', arguments: petDoc.id);
                            } else {
                              Navigator.pushNamed(context, '/pet_activation', arguments: petDoc.id);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              // add blue border when active
                              border: isActive
                                  ? Border.all(color: DesignConstant.pawBlue, width: 2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
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
                                  name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // Active / Not Active badge
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: isActive ? Colors.green : Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  child: Text(
                                    isActive ? 'Active' : 'Not Active',
                                    style: TextStyle(
                                      color: isActive ? Colors.green : Colors.black54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
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
                      itemCount: activePets.length,
                      itemBuilder: (context, index) {
                        final petDoc = activePets[index];
                        final pet = petDoc.data() as Map<String, dynamic>;
                        final name = pet['name'] ?? pet['Name'] ?? '-';
                        final isActive = pet['active'] as bool? ?? false;

                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/admin_pet_profile', arguments: petDoc.id);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              // add blue border when active
                              border: isActive
                                  ? Border.all(color: DesignConstant.pawBlue, width: 2)
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.18),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Row(
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
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      // Active / Not Active badge
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: isActive ? Colors.green : Colors.grey),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                        child: Text(
                                          isActive ? 'Active' : 'Not Active',
                                          style: TextStyle(
                                            color: isActive ? Colors.green : Colors.black54,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
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
            Navigator.pushReplacementNamed(context, '/admin_home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/admin_chat');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/admin_cctv');
          }
        },
      ),
    );
  }
}
