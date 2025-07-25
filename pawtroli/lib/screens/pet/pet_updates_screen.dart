import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pawtroli/design_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/pet_update_model.dart';
import '../../services/pet_update_service.dart';

class PetUpdatesScreen extends StatefulWidget {
  final String petId;
  const PetUpdatesScreen({super.key, required this.petId});

  @override
  State<PetUpdatesScreen> createState() => _PetUpdatesScreenState();
}

class _PetUpdatesScreenState extends State<PetUpdatesScreen> {
  late Future<List<PetUpdateModel>> _updatesFuture;
  
  @override
  void initState() {
    super.initState();
    _loadUpdates();
  }
  
  void _loadUpdates() {
    _updatesFuture = PetUpdateService().getPetUpdates(widget.petId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: DesignConstant.pawBlue,
        elevation: 0,
        toolbarHeight: 85, // Set exact height of AppBar
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Activity',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .snapshots(),
            builder: (ctx, userSnap) {
              if (userSnap.hasData &&
                  (userSnap.data!.data() as Map<String, dynamic>)['role'] ==
                      'admin') {
                return IconButton(
                  icon: Image.asset(
                    'assets/images/upload.png',
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/pet_update_upload',
                      arguments: {'petId': widget.petId},
                    ).then((_) {
                      // Refresh after returning from upload screen
                      setState(() {
                        _loadUpdates();
                      });
                    });
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<PetUpdateModel>>(
        future: _updatesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No updates yet.'));
          }
          final updates = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: updates.length,
            itemBuilder: (context, index) {
              final update = updates[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12, top: 12),
                          child: Text(
                            'Staff',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12, top: 12),
                          child: Text(
                            DateFormat('dd MMM yyyy, h:mm a')
                                .format(update.timestamp.toLocal()),
                            style: const TextStyle(
                                color: Colors.black54, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: (update.imageUrl.isEmpty || update.imageUrl == 'placeholder_for_image_url')
                              ? const AssetImage('assets/images/pet_activity.png')
                              : NetworkImage(update.imageUrl) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () {
                            PetUpdateService().deletePetUpdate(widget.petId, update.id).then((success) {
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Update deleted successfully')),
                                );
                                setState(() {
                                  _loadUpdates(); // Refresh the updates list
                                });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to delete update')),
                                );
                              }
                            });
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6.0, horizontal: 6.0),
                              child: Text(
                                update.caption,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ), 
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.download_outlined, color: Colors.grey),
                          onPressed: () {
                            // Download functionality would go here
                            PetUpdateService().downloadUpdate(update).then((_) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Image downloaded successfully')),
                              );
                            }).catchError((error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to download image: $error')),
                              );
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Description:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          Text(update.description, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
