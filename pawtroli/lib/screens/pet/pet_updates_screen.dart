import 'package:flutter/material.dart';
import '../../models/pet_update_model.dart';
import '../../services/pet_update_service.dart';

class PetUpdatesScreen extends StatelessWidget {
  final String petId;
  const PetUpdatesScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B2341),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Activity', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<PetUpdateModel>>(
        future: PetUpdateService().getPetUpdates(petId),
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
                            'staff',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 12, top: 12),
                          child: Text(
                            update.time,
                            style: const TextStyle(color: Colors.black54, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: update.imageUrl.isNotEmpty
                          ? Image.network(update.imageUrl, height: 180, width: double.infinity, fit: BoxFit.cover)
                          : Container(height: 180, color: Colors.grey[200]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Center(
                                child: Text(
                                  update.caption,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.download, color: Colors.black54),
                            onPressed: () {
                              PetUpdateService().downloadUpdate(update);
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(update.description, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
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
