import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as logger;
import 'package:passwordfield/passwordfield.dart';

import 'package:http/http.dart' as http;

Future<void> signInWithEmail(String email, String password) async {
  try {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final token = await credential.user?.getIdToken();

    final response = await http.post(
      Uri.parse('http://192.168.0.164:8080/secure-endpoint'),
      headers: {
        'Content-Type': 'application/json',                
        'Authorization': 'Bearer $token',
      },
    );

    logger.log("Token: $token"); // Send this to Go backend

  } on FirebaseAuthException catch (e) {
    logger.log("Login error: ${e.message}");
  }
}

class SignInScreen extends StatefulWidget {
  final VoidCallback onSignInSuccess;
  final VoidCallback onRegisterTap;
  const SignInScreen({super.key, required this.onSignInSuccess, required this.onRegisterTap});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;
  String? _error;

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await signInWithEmail(_email, _password);
      widget.onSignInSuccess(); // Navigate to home page
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                onChanged: (val) => _email = val,
                validator: (val) => val == null || val.isEmpty ? 'Enter email' : null,
              ),
              PasswordField(
                color: Colors.blue,
                passwordConstraint: r'.*[@$#.*].*',
                passwordDecoration: PasswordDecoration(),
                hintText: 'must have special characters',
                onChanged: (val) => _password = val,
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
              const SizedBox(height: 20),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                onPressed: _loading ? null : _handleSignIn,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Sign In'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: widget.onRegisterTap,
                child: const Text("Don't have an account? Register here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}