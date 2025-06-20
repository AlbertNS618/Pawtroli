import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../widgets/logo_header.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onSignInSuccess;
  final VoidCallback onRegisterTap;
  const SignInScreen({super.key, required this.onSignInSuccess, required this.onRegisterTap});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  // String? _error;
  bool _obscurePassword = true;

  final AuthService _authService = AuthService();

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
    });
    try {
      await _authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
      widget.onSignInSuccess();
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('An error occurred. Please try again.');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final emailController = TextEditingController();
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: emailController,
          decoration: InputDecoration(
            hintText: 'Email',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30), // Makes the box rounded
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              if (email.isNotEmpty) {
                try {
                  await _authService.sendPasswordResetEmail(email);
                  Navigator.of(context).pop();
                  _showError('Password reset email sent!');
                } catch (e) {
                  _showError('Failed to send reset email: $e');
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/background.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildFormContainer() {
    return Container(
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
            padding: const EdgeInsets.fromLTRB(10, 16, 10, 12),
            child: TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Colors.grey.shade800,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Enter email' : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
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
          TextButton(
            onPressed: _resetPassword,
            child: const Text('Forgot Password?', style: TextStyle(color: Colors.grey),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          _buildBackground(),
          Padding(
            padding: EdgeInsets.only(
              top: kToolbarHeight + MediaQuery.of(context).padding.top,
              left: 16,
              right: 16,
              bottom: 30,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LogoHeader(),
                  _buildFormContainer(),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: 150, // changed width to make button shorter
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color.fromARGB(255, 95, 95, 95),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide.none,
                        ),
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: _loading ? null : _handleSignIn,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onRegisterTap,
                    child: Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                              text: "Register here",
                              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}