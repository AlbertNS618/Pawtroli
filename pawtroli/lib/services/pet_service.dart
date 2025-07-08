import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pet_model.dart';
import '../api_constants.dart';

class PetService {

  Future<bool> registerPet(PetModel pet, {String? imageBase64}) async {
    final body = pet.toJson();
    developer.log('Registering pet with body: $body');
    if (imageBase64 != null) {
      body['imageBase64'] = imageBase64;
    }
    final response = await http.post(
      Uri.parse(ApiConstants.pets),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> activatePet(String petId, DateTime checkIn, DateTime checkOut) async {
    final response = await http.patch(
      Uri.parse('${ApiConstants.pets}/$petId/activate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'checkIn': checkIn.toUtc().toIso8601String(), 'checkOut': checkOut.toUtc().toIso8601String()}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      developer.log('Failed to activate pet: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to activate pet');
    }
    developer.log('Pet activation status updated successfully');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> deactivatePet(String petId) async {
    final response = await http.patch(
      Uri.parse('${ApiConstants.pets}/$petId/activate'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'checkIn': null, 'checkOut': null}),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      developer.log('Failed to activate pet: ${response.statusCode}, ${response.body}');
      throw Exception('Failed to activate pet');
    }
    developer.log('Pet activation status updated successfully');
    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<PetModel> getPetProfile(String petId) async {
    try {
      developer.log('Fetching pet with ID: $petId from API');
      final response = await http.get(
        Uri.parse('${ApiConstants.pets}/$petId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      developer.log('API response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        developer.log('Pet data received: $data');
        // data['checkIn'] = data['checkIn'] != null
        //     ? DateTime.parse(data['checkIn']).toIso8601String()
        //     : null;
        
        try {
          final pet = PetModel.fromJson(data);
          developer.log('Successfully parsed pet: ${pet.toString()}');
          return pet;
        } catch (e) {
          developer.log('Error parsing pet data: $e');
          throw Exception('Failed to parse pet data: $e');
        }
      } else {
        developer.log('API error: ${response.statusCode}, ${response.body}');
        throw Exception('Failed to load pet: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error fetching pet: $e');
      throw Exception('Failed to load pet: $e');
    }
  }

  /// Returns the latest 'caption' from pet_updates for the given petId.
  Future<String> getPetStatus(String? petId) async {
    if (petId == null || petId.isEmpty) {
      return 'No pet registered';
    }
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('pet_updates')
          .where('petId', isEqualTo: petId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        return (data['caption'] as String?) ?? 'Unknown status';
      } else {
        return 'No status updates';
      }
    } catch (e) {
      developer.log('Error fetching pet status: $e');
      return 'Error fetching status';
    }
  }

  /// Updates a single field on the pet document.
  Future<bool> updateField(
      String petId, String fieldName, dynamic value) async {
    try {
      await FirebaseFirestore.instance
          .collection('pets')
          .doc(petId)
          .update({fieldName: value});
      return true;
    } catch (e) {
      debugPrint('Update failed: $e');
      return false;
    }
  }

  Future<bool> deletePet(String petId, {BuildContext? context}) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConstants.pets}/$petId/delete'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200 || response.statusCode == 204) {
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet deleted successfully')),
          );
        }
        return true;
      } else {
        developer.log('Failed to delete pet: ${response.statusCode}, ${response.body}');
        return false;
      }
    } catch (e) {
      developer.log('Delete failed: $e');
      return false;
    }
  }
}