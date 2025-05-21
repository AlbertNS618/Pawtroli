import 'dart:developer' as Logger;

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class LoginScreen extends StatefulWidget {
  final Function(String userId) onLogin;
  const LoginScreen({super.key, required this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String name = '';
  String phone = '';

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final userId = email.replaceAll('@', '_').replaceAll('.', '_');
      
      final response = await http.post(
        Uri.parse('http://192.168.0.164:8080/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "id": userId,
          "email": email,
          "name": name,
          "phone": phone,
        }),
      ); Logger.log('Login response: ${response.statusCode}');
      if (response.statusCode != 200) {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${response.body}')),
        );
        return;
      }
      widget.onLogin(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login / Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Email'),
              onChanged: (val) => email = val,
              validator: (val) => val!.isEmpty ? 'Enter email' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (val) => name = val,
              validator: (val) => val!.isEmpty ? 'Enter name' : null,
            ),
            TextFormField(
                decoration: InputDecoration(labelText: 'Phone'),
                onChanged: (val) => phone = val,
                validator: (val) => val!.isEmpty ? 'Enter phone' : null,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: Text('Continue'))
          ]),
        ),
      ),
    );
  }
}