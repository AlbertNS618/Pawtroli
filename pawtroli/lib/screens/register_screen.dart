import 'package:flutter/material.dart';
import 'package:passwordfield/passwordfield.dart';
import '../services/auth_service.dart';
// import '../models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  final Function(String userId) onRegister;
  const RegisterScreen({super.key, required this.onRegister});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '', name = '', phone = '', password = '';
  bool _loading = false;

  final AuthService _authService = AuthService();

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        final user = await _authService.registerWithEmail(
          email: email,
          password: password,
          name: name,
          phone: phone,
        );
        widget.onRegister(user.id);
      } catch (e) {
        _showError(e.toString());
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Register'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 50,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    color: const Color.fromRGBO(16, 48, 95, 1),
                    child: Image.asset('assets/images/logo.png',
                        height: 100, width: 240),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                            decoration: const InputDecoration(labelText: 'Email'),
                            onChanged: (val) => email = val,
                            validator: (val) => val!.isEmpty ? 'Enter email' : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Name'),
                            onChanged: (val) => name = val,
                            validator: (val) => val!.isEmpty ? 'Enter name' : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Phone'),
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
                            hintText: 'Password',
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
                                borderSide: BorderSide(width: 2, color: Colors.red.shade200),
                              ),
                            ),
                            errorMessage: 'must contain special character either . * @ # \$',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}