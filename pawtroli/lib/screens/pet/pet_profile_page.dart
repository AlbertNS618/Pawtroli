import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/pet_model.dart';
import '../../services/pet_service.dart'; // Import the PetService
import 'pet_updates_screen.dart';

class PetProfilePage extends StatelessWidget {
  final String petId;
  const PetProfilePage({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pet Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
      ),
      body: FutureBuilder<PetModel>(
        future: PetService().getPetProfile(petId), // Use PetService here
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final pet = snapshot.data!;
          // final isActive = pet.active == true;

          // Improved checkout date parsing and reminder logic
          DateTime? checkOutDate;
          if (pet.checkOut != null) {
            try {
              if (pet.checkOut != null && pet.checkOut.runtimeType.toString() == 'Timestamp') {
                // Handle Firestore Timestamp object
                final seconds = pet.checkOut?.seconds;
                checkOutDate = DateTime.fromMillisecondsSinceEpoch(seconds! * 1000);
              } else if (pet.checkOut is Map && (pet.checkOut as Map?)?.containsKey('seconds') == true) {
                // Handle timestamp as an object with seconds field
                final seconds = pet.checkOut?.seconds;
                checkOutDate = DateTime.fromMillisecondsSinceEpoch(seconds! * 1000);
              } else if (pet.checkOut is String && pet.checkOut != '-') {
                // Try parsing as a date string
                checkOutDate = DateTime.tryParse(formatDate(pet.checkOut!));
              }
              developer.log("Parsed checkout date: $checkOutDate");
            } catch (e) {
              developer.log("Error parsing checkout date: $e");
            }
          }

          bool showReminder = false;
          if (checkOutDate != null && pet.active == true) {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final checkoutDay = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);
            final difference = checkoutDay.difference(today).inDays;
            
            developer.log("Days until checkout: $difference");
            showReminder = difference == 1; // Show reminder if checkout is tomorrow
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background "cut out" effect
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white, // match your Scaffold background
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                      // Always use pet_placeholder image
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: const AssetImage('assets/images/pet_placeholder.png'),
                        backgroundColor: Colors.orange[100],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    pet.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text('Type: ${pet.type}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.8, // Decreased from 2.0 to give more height
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    children: [
                      _infoCard('Gender', pet.gender),
                      _infoCard('Color', pet.color),
                      _infoCard('Age', '${pet.age.toString()} years old'),
                      _infoCard('Allergy', pet.allergy),
                      _infoCard('Checked-In', pet.checkIn != null ? formatDate(pet.checkIn!) : '-'),
                      _infoCard('Checked-Out', pet.checkOut != null ? formatDate(pet.checkOut!) : '-'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetUpdatesScreen(petId: petId),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Image(
                          image: AssetImage('assets/images/activity_icon.png'),
                          width: 24,
                          height: 24,
                        ),
                        const SizedBox(width: 5),
                        const Text('ACTIVITY', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Remove the always-visible reminder container
                  // Only show the reminder if showReminder is true
                  if (showReminder)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Reminder: Your pet will be checked out tomorrow!',
                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          // Add Flexible to allow text to wrap if needed
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
              maxLines: 2, // Allow up to 2 lines for longer content
            ),
          ),
        ],
      ),
    );
  }

  String formatDate(dynamic dateValue) {
    if (dateValue == null || dateValue == '' || dateValue == '-') return '-';
    try {
      DateTime date;
      if (dateValue is Map && dateValue.containsKey('seconds')) {
        // Handle Firestore Timestamp format from JSON 
        final seconds = dateValue['seconds'];
        date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue.toString().contains('Timestamp')) {
        // Parse the string representation of Timestamp
        final regex = RegExp(r'Timestamp\(seconds=(\d+),');
        final match = regex.firstMatch(dateValue.toString());
        if (match != null && match.groupCount >= 1) {
          final seconds = int.parse(match.group(1)!);
          date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        } else {
          return dateValue.toString();
        }
      } else {
        return dateValue.toString();
      }
      
      final localTime = date.toLocal();
      final hour = localTime.hour > 12 ? localTime.hour - 12 : (localTime.hour == 0 ? 12 : localTime.hour);
      final ampm = localTime.hour >= 12 ? 'pm' : 'am';
      return "${hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')} $ampm, "
             "${DateFormat('dd MMM yyyy').format(localTime)}";
    } catch (e) {
      developer.log('Error formatting date: $e for value $dateValue');
      return dateValue.toString();
    }
  }
}