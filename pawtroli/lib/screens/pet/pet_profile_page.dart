import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:pawtroli/design_constant.dart';
import 'package:pawtroli/widgets/info_card.dart';
import '../../models/pet_model.dart';
import '../../services/pet_service.dart'; 

class PetProfilePage extends StatelessWidget {
  final String petId;
  const PetProfilePage({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PetModel>(
      future: PetService().getPetProfile(petId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final pet = snapshot.data!;

        // Improved checkout date parsing and reminder logic
        DateTime? checkOutDate;
        if (pet.checkOut != null) {
          try {
            developer.log("Raw checkOut value: ${pet.checkOut}");
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

        bool showReminder = false;
        if (checkOutDate != null && pet.active == true) {
          final now = DateTime.now().toUtc();
          final today = DateTime(now.year, now.month, now.day).toUtc();
          final checkoutDay = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);
          final difference = checkoutDay.difference(today).inDays;

          developer.log("Days until checkout: $difference");
          showReminder = difference == 1; // Show reminder if checkout is tomorrow
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Pet Profile', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            actions: [
              if (pet.active == false)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Pet'),
                        content: const Text('Are you sure you want to delete this pet?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await PetService().deletePet(petId);
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 120,
                        width: 120,
                        child: ClipOval(
                          child: Image.network(
                            pet.imageUrl,
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
                      crossAxisCount: 2, childAspectRatio: 1.8, crossAxisSpacing: 12, mainAxisSpacing: 12
                    ),
                    children: [
                      InfoCard(
                        label: 'Gender',
                        value: pet.gender,
                        onConfirm: pet.active == true
                          ? null
                          : (v) => PetService().updateField(petId, 'gender', v),
                      ),
                      InfoCard(
                        label: 'Color',
                        value: pet.color,
                        onConfirm: pet.active == true
                          ? null
                          : (v) => PetService().updateField(petId, 'color', v),
                      ),
                      InfoCard(
                        label: 'Age',
                        value: '${pet.age} years old',
                        onConfirm: pet.active == true
                          ? null
                          : (v) => PetService().updateField(petId, 'age', int.tryParse(v) ?? pet.age),
                      ),
                      InfoCard(
                        label: 'Allergy',
                        value: pet.allergy,
                        onConfirm: pet.active == true
                          ? null
                          : (v) => PetService().updateField(petId, 'allergy', v),
                      ),
                      InfoCard(
                        label: 'Checked-In',
                        value: pet.checkIn != null ? formatDate(pet.checkIn!) : '-',
                      ),
                      InfoCard(
                        label: 'Checked-Out',
                        value: pet.checkOut != null ? formatDate(pet.checkOut!) : '-',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/pet_updates', arguments: petId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignConstant.pawBlue,
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
                  if (showReminder)
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Reminder: Your pet ${pet.name} is scheduled to check out tomorrow at ${formatDate(pet.checkOut!).substring(0,8)}. Please confirm or contact the staff if needed.',
                        style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text(
                      'Pet ID: $petId',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        );
    },
  );
}

  String formatDate(dynamic dateValue) {
    if (dateValue == null || dateValue == '' || dateValue == '-') {
      return '-';
    }
    if (dateValue is String && dateValue.startsWith('0001-01-01')) {
      return '-';
    }
    if (dateValue is DateTime && dateValue.year == 1) {
      return '-';
    }
    if (dateValue is Map) {
      final seconds = dateValue['seconds'];
      if (seconds != null) {
        final dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        if (dt.year == 1) return '-';
      }
    }

    try {
      DateTime date;
      developer.log("Formatting date value type: ${dateValue.runtimeType}, value: $dateValue");

      if (dateValue is String) {
        date = DateTime.parse(dateValue);
      } else if (dateValue is Map) {
        final seconds = dateValue['seconds'];
        if (seconds != null) {
          date = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
        } else {
          return dateValue.toString();
        }
      } else if (dateValue is DateTime) {
        date = dateValue;
      } else {
        return dateValue.toString();
      }

      final localTime = date.toLocal();
      final hour = localTime.hour % 12 == 0 ? 12 : localTime.hour % 12;
      final ampm = localTime.hour >= 12 ? 'pm' : 'am';
      return "${hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')} $ampm, "
          "${localTime.day} ${_getMonthName(localTime.month)}";
    } catch (e) {
      developer.log('Error formatting date: $e for value $dateValue');
      return dateValue.toString();
    }
  }

  // Helper function to get month name
  String _getMonthName(int month) {
    return [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ][month];
  }
}