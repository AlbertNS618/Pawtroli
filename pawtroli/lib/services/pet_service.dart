import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/pet_model.dart';
import 'api_constants.dart';

class PetService {
  Future<bool> registerPet(PetModel pet, {String? imageBase64}) async {
    final body = pet.toJson();
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
}