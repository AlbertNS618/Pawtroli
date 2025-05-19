import 'package:flutter/material.dart';

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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final userId = email.replaceAll('@', '_').replaceAll('.', '_');
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
            SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: Text('Continue'))
          ]),
        ),
      ),
    );
  }
}