import 'dart:developer' as Logger;

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:passwordfield/passwordfield.dart';
import 'package:firebase_auth/firebase_auth.dart';



class RegisterScreen extends StatefulWidget {
  final Function(String userId) onRegister;
  const RegisterScreen({super.key, required this.onRegister});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = ''; String name = '';
  String phone = ''; String password = '';

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        // 1. Register user with Firebase Auth
        final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final uid = credential.user!.uid;

        // 2. Send user data (including UID) to Go backend
        final response = await http.post(
          Uri.parse('http://192.168.0.164:8080/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            "id": uid, // Pass UID from Firebase Auth
            "email": email,
            "name": name,
            "phone": phone,
          }),
        );
        Logger.log('Register response: ${response.statusCode}');
        if (response.statusCode != 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Register failed: ${response.body}')),
          );
          return;
        }

        widget.onRegister(uid); // Pass UID to next screen
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Firebase Auth error: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        title: Text('Register'),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.transparent, // <-- Transparent background
        // elevation: 0, // <-- No shadow
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png', // <-- Replace with your image path
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: kToolbarHeight + MediaQuery.of(context).padding.top+30,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(labelText: 'Email'),
                            onChanged: (val) => email = val,
                            validator: (val) => val!.isEmpty ? 'Enter email' : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Name'),
                            onChanged: (val) => name = val,
                            validator: (val) => val!.isEmpty ? 'Enter name' : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: InputDecoration(labelText: 'Phone'),
                            onChanged: (val) => phone = val,
                            validator: (val) => val!.isEmpty ? 'Enter phone' : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: PasswordField(
                            color: Colors.blue,
                            passwordConstraint: r'.*[@$#.*].*',
                            passwordDecoration: PasswordDecoration(),
                            hintText: 'must have special characters',
                            onChanged: (val) => password = val,
                            border: PasswordBorder(
                              border: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue.shade100,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.blue.shade100,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(width: 2, color: Colors.red.shade200),
                              ),
                            ),
                            errorMessage:
                                'must contain special character either . * @ # \$',
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(onPressed: _submit, child: Text('Continue'))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}