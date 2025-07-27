import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:pawtroli/widgets/info_card.dart';
import '../../models/pet_model.dart';
import '../../services/pet_service.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';

class AdminPetProfilePage extends StatelessWidget {
  final String petId;
  const AdminPetProfilePage({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pet Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.pause_circle_outline, color: Colors.orangeAccent),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Deactivate Pet'),
                  content: const Text('Mark this pet as inactive?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Deactivate', style: TextStyle(color: Colors.orange)),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await PetService().updateField(petId, 'active', false);
                Navigator.pushReplacementNamed(context, '/admin_home');
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<PetModel>(
        future: PetService().getPetProfile(petId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final pet = snapshot.data!;
         
          DateTime? checkOutDate;
          if (pet.checkOut != null) {
            try {
              developer.log("Raw checkOut value: ${pet.checkOut}");
              
              // Handle ISO 8601 format
              if (pet.checkOut is String) {
                checkOutDate = DateTime.parse(pet.checkOut);
              }
              else if (pet.checkOut is Map) {
                final seconds = pet.checkOut['seconds'];
                if (seconds != null) {
                  checkOutDate = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
                }
              }
              
              developer.log("Parsed checkout date: $checkOutDate");
            } catch (e) {
              developer.log("Error parsing checkout date: $e");
            }
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                      childAspectRatio: 1.8,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    children: [
                      InfoCard(label: 'Gender', value: pet.gender),
                      InfoCard(label: 'Color', value: pet.color),
                      InfoCard(label: 'Age', value: '${pet.age.toString()} years old'),
                      InfoCard(label: 'Allergy', value: pet.allergy),
                      InfoCard(label: 'Checked-In', value: pet.checkIn != null ? formatDate(pet.checkIn!) : '-'),
                      InfoCard(label: 'Checked-Out', value: pet.checkOut != null ? formatDate(pet.checkOut!) : '-'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/pet_updates',
                        arguments: petId,
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
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 1.0),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(7.0)),
                          ),
                          child: const Text(
                            'Pawrents',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        FutureBuilder<UserModel?>(
                          future: UserService().getUserById(pet.ownerId),
                          builder: (context, ownerSnapshot) {
                            if (ownerSnapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            if (!ownerSnapshot.hasData || ownerSnapshot.data == null) {
                              return const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Text('Owner info not found'),
                              );
                            }
                            final owner = ownerSnapshot.data!;
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12.0),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(7.0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    owner.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    owner.phone.isNotEmpty ? owner.phone : '-',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black.withOpacity(0.7),
                                    ),
                                  ),
                                ],
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
          );
        },
      ),
    );
  }

  

  String formatDate(dynamic dateValue) {
    if (dateValue == null || dateValue == '' || dateValue == '-') return '-';
    
    try {
      DateTime date;
      
      developer.log("Formatting date value type: ${dateValue.runtimeType}, value: $dateValue");
      
      // Handle ISO 8601 string format 
      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      }
      else if (dateValue is Map) {
        final seconds = dateValue['seconds'];
        if (seconds != null) {
          date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        } else {
          return dateValue.toString();
        }
      }
      else if (dateValue is DateTime) {
        date = dateValue;
      }
      else {
        return dateValue.toString();
      }
      
      final localTime = date.toLocal();
      final hour = localTime.hour % 12 == 0 ? 12 : localTime.hour % 12;
      final ampm = localTime.hour >= 12 ? 'pm' : 'am';
      
      // Format the date string
      return "${hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')} $ampm, "
             "${localTime.day} ${_getMonthName(localTime.month)}";
    } catch (e) {
      developer.log('Error formatting date: $e for value $dateValue');
      return dateValue.toString();
    }
  }

  // function to get month name
  String _getMonthName(int month) {
    return [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ][month];
  }
}