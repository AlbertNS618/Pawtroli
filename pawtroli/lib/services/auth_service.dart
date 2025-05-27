import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pawtroli/models/user_model.dart';
import 'package:pawtroli/services/api_constants.dart';

class AuthService {
  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      print('Starting Firebase sign in');
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('Firebase sign in done');
      final token = await credential.user?.getIdToken();
      print('Got token');

      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('HTTP response received');
      print('Response status: ${response.statusCode}');

      if (response.statusCode != 200) {
        throw Exception('Backend error: ${response.body}');
      }

      // Parse user data from backend response if available
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id": uid,
          "email": email,
          "name": name,
          "phone": phone,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Register failed: ${response.body}');
      }

      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }
}