import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pet_model.dart';
import 'api_constants.dart';

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

  Future<PetModel> getPetProfile(String petId) async {
    try {
      developer.log('getting pet with ID: $petId');
      final doc = await FirebaseFirestore.instance.collection('pets').doc(petId).get();
      
      if (!doc.exists) {
        developer.log('Pet not found with ID: $petId');
        throw Exception('Pet not found');
      }
      
      final data = doc.data()!;
      developer.log('Pet data from Firestore: $data');
      
      // Debug the model parsing
      try {
        final pet = PetModel.fromJson(data);
        developer.log('Successfully parsed pet: ${pet.toString()}');
        return pet;
      } catch (e) {
        developer.log('Error parsing pet data: $e');
        throw e;  // Let the FutureBuilder handle the error
      }
    } catch (e) {
      developer.log('Error fetching pet: $e');
      throw Exception('Failed to load pet: $e');
    }
  }
}