import 'dart:io'; // for SocketException
import 'package:flutter/material.dart';
import 'package:pawtroli/widgets/auth_form_container.dart';
import '../../services/auth_service.dart';
import '../../widgets/logo_header.dart';
import '../../widgets/_background.dart';

class RegisterScreen extends StatefulWidget {
  final Function(String userId) onRegister;
  final VoidCallback onSigninTap;
  const RegisterScreen({super.key, required this.onRegister, required this.onSigninTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;

  final AuthService _authService = AuthService();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await _authService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      widget.onRegister(user.id);
      Navigator.pushReplacementNamed(context, '/signin');
    }
    on SocketException {
      // network‐level error
      const networkMsg = 'Network error. Please check your connection.';
      setState(() => _error = networkMsg);
      _showError(networkMsg);
    }
    catch (e) {
      // strip any “Exception:” prefix
      final cleaned = e.toString().replaceFirst(RegExp(r'^[^:]+:\s*'), '');
      setState(() => _error = cleaned);
      _showError(cleaned);
    }
    finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    // remove "Exception: " or any "Whatever: " prefix
    final displayMsg = message.replaceFirst(RegExp(r'^[^:]+:\s*'), '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(displayMsg)),
    );
  }

  Widget _buildError() {
    if (_error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(_error!, style: const TextStyle(color: Colors.red)),
    );
  }

  Widget _buildFormContainer() {
    return AuthFormContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade800,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Enter email';
                }
                final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
                if (!emailRegex.hasMatch(val.trim())) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name (First character uppercase)',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade800,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Enter name';
                }
                final nameRegex = RegExp(r'^[A-Z][a-zA-Z ]*$');
                if (!nameRegex.hasMatch(val.trim())) {
                  return 'Name must start with uppercase and contain only letters';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone (12 digits)',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade800,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (val) {
                if (val == null || val.isEmpty) {
                  return 'Enter phone';
                }
                final phoneRegex = RegExp(r'^\d{12}$');
                if (!phoneRegex.hasMatch(val.trim())) {
                  return 'Phone must be 12 digits';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey.shade800,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              validator: (val) {
                if (val == null || val.isEmpty) return 'Enter password';
                if (!RegExp(r'.*[@$#.*].*').hasMatch(val)) {
                  return 'must contain special character either . * @ # \$';
                }
                return null;
              },
            ),
          ),
          _buildError(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = insets > 0 ? insets + 16 : 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Background(),
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: kToolbarHeight + MediaQuery.of(context).padding.top + 60,
                left: 16,
                right: 16,
                bottom: bottomPadding.toDouble(),      // <-- now zero when keyboard is hidden
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    LogoHeader(),
                    _buildFormContainer(),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 150,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide.none,
                          ),
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const CircularProgressIndicator()
                            : const Text(
                                'Register',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                      ),
                    ),
                    TextButton(
                      onPressed: widget.onSigninTap,
                      child: Padding(
                        padding: EdgeInsets.only(top: 30),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Already have an account? ",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(
                                text: "Sign In",
                                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}