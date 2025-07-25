import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/pet_update_model.dart';
import '../api_constants.dart';

class PetUpdateService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<String> uploadPetUpdateImage(File imageFile, String petId) async {
    try {
      // Create a reference with timestamp for unique filenames
      final fileName = '${petId}_${DateTime.now().millisecondsSinceEpoch}';
      final storageRef = _storage.ref().child('pet_updates/$fileName');
      
      // Upload file
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      developer.log('Image uploaded to Firebase Storage: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      developer.log('Error uploading image to Firebase Storage: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<List<PetUpdateModel>> getPetUpdates(String petId) async {
    try {
      final uri = Uri.parse('${ApiConstants.pets}/$petId/updates');
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print(data);
        return data.map((j) => PetUpdateModel.fromJson(j)).toList();
      } else {
        throw Exception(
            'Failed to load pet updates (Status ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Loading pet updates timed out');
    } on FormatException {
      throw Exception('Bad response format');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<bool> addPetUpdate(PetUpdateModel update, {required String petId}) async {
    try {
      final uri = Uri.parse('${ApiConstants.pets}/$petId/updates');
      final body = json.encode(update.toJson());
      final response = await http
          .post(uri, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 201) {
        throw Exception(
            'Failed to add update (Status ${response.statusCode}): ${response.body}');
      }
      developer.log('Pet update added successfully');
      return response.statusCode == 200 || response.statusCode == 201;
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Posting update timed out');
    } catch (e) {
      throw Exception('Failed to add pet update: $e');
    }
  }

  Future<bool> deletePetUpdate(String petId, String updateId) async {
    try {
      final uri = Uri.parse('${ApiConstants.pets}/$petId/updates/$updateId');
      final response = await http
          .delete(uri)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete update (Status ${response.statusCode}): ${response.body}');
      }
      developer.log('Pet update deleted successfully');
      return response.statusCode == 200;
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Deleting update timed out');
    } catch (e) {
      throw Exception('Failed to delete pet update: $e');
    }
  }

  Future<void> downloadUpdate(PetUpdateModel update) async {
    if (update.imageUrl.isEmpty) return;
    try {
      final uri = Uri.parse(update.imageUrl);
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/${update.id}.jpg');
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw Exception(
          'Failed to download image (Status ${response.statusCode})');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on TimeoutException {
      throw Exception('Image download timed out');
    } catch (e) {
      throw Exception('Failed to download image: $e');
    }
  }
}
