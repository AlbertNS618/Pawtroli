import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer' as developer;

import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../models/pet_update_model.dart';
import '../api_constants.dart';

class PetUpdateService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  Future<String> uploadPetUpdateImage(File imageFile, String petId) async {
    try {
      final fileName = '${petId}_${DateTime.now().millisecondsSinceEpoch}';
      final storageRef = _storage.ref().child('pet_updates/$fileName');
      
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      
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

  Future<void> shareUpdate(PetUpdateModel update, {BuildContext? context}) async {
    if (update.imageUrl.isEmpty) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image to share')),
        );
      }
      return;
    }
    
    try {
      // Show loading indicator
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preparing image...')),
        );
      }
      
      // Create a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/pawtroli_pet_update.jpg';
      final tempFile = File(tempPath);
      
      // Download the image
      final response = await http.get(Uri.parse(update.imageUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download image');
      }
      
      // Save to temp file
      await tempFile.writeAsBytes(response.bodyBytes);
      
      // Share the file
      await Share.shareXFiles(
        [XFile(tempPath)],
        text: 'Pet update: ${update.caption}',
        subject: 'Pawtroli Pet Update',
      );
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
      rethrow;
    }
  }
}
