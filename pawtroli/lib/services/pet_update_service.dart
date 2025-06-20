import '../models/pet_update_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'api_constants.dart';

class PetUpdateService {

  Future<List<PetUpdateModel>> getPetUpdates(String petId) async {
    print('Fetching updates for pet ID: $petId');
    final response = await http.get(Uri.parse('${ApiConstants.pets}/$petId/updates'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PetUpdateModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load pet updates');
    }
  }

  Future<void> downloadUpdate(PetUpdateModel update) async {
    if (update.imageUrl.isEmpty) return;
    final response = await http.get(Uri.parse(update.imageUrl));
    if (response.statusCode == 200) {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/${update.id}.jpg');
      await file.writeAsBytes(response.bodyBytes);
      // Optionally, show a notification or snackbar
    } else {
      throw Exception('Failed to download image');
    }
  }
}
