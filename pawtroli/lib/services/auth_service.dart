import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:pawtroli/models/user_model.dart';
import 'package:pawtroli/api_constants.dart';
import 'dart:developer' as developer;

class AuthService {
   final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel> signInWithEmail(String email, String password) async {
    try {
      developer.log('Starting Firebase sign in', name: 'AuthService');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      developer.log('Firebase sign in done', name: 'AuthService');
      final token = await credential.user?.getIdToken();
      developer.log('Got token $token', name: 'AuthService');
      developer.log('Making HTTP request to backend', name: 'AuthService');
      final response = await http
          .post(
            Uri.parse(ApiConstants.login),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
        .timeout(const Duration(seconds: 10));

      developer.log('HTTP response received', name: 'AuthService');
      developer.log('Response status: ${response.statusCode}', name: 'AuthService');
      developer.log('Response body: ${response.body}', name: 'AuthService');

      if (response.statusCode != 200) {
        throw Exception('Backend error: ${response.body}');
      }

      // Parse user data from backend response if available
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } on TimeoutException {
      throw Exception('Sign in request timed out. Please try again.');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw AuthException('The email address is not valid.');
        case 'user-disabled':
          throw AuthException('This user account has been disabled.');
        case 'user-not-found':
          throw AuthException('No account found for that email.');
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-password':
          developer.log('${e.message}', name: 'AuthService', error: e);
          throw AuthException('Incorrect email or password. Please try again.');
        default:
          throw AuthException('Sign in failed: ${e.message ?? e.code}');
      }
    } catch (e) {
      throw AuthException('An error occurred. Please try again.');
      // throw e;
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
          "role": "user", // Default role
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('Register failed: ${response.body}');
      }

      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);

    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // In AuthService
  Future<void> sendPasswordResetEmail(String email) async {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}