// Core imports for network operations and UI
import 'dart:io'; // for SocketException (network error handling)
import 'package:flutter/material.dart';

// Custom widgets and services
import 'package:pawtroli/widgets/auth_form_container.dart';
import '../../services/auth_service.dart'; // Service handling authentication logic
import '../../widgets/logo_header.dart';
import '../../widgets/_background.dart'; // Background design for auth screens

/// RegisterScreen handles new user registration functionality
/// Takes callbacks for successful registration and navigation to sign-in
class RegisterScreen extends StatefulWidget {
  final Function(String userId) onRegister; // Callback when registration succeeds
  final VoidCallback onSigninTap; // Callback for navigating to sign-in screen
  
  const RegisterScreen({super.key, required this.onRegister, required this.onSigninTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Form key for validation management
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // UI state variables
  bool _loading = false; // Controls loading indicator
  String? _error; // Stores error message
  bool _obscurePassword = true; // Controls password visibility
  
  // Authentication service for API calls
  final AuthService _authService = AuthService();

  /// Handles form submission and user registration
  /// Validates input, calls API, and handles success/errors
  Future<void> _submit() async {
    // Validate form fields first
    if (!_formKey.currentState!.validate()) return;
    
    // Update UI to loading state
    setState(() {
      _loading = true;
      _error = null;
    });
    
    try {
      // Call authentication service to register user
      final user = await _authService.registerWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      
      // If successful, trigger onRegister callback and navigate to sign-in
      widget.onRegister(user.id);
      Navigator.pushReplacementNamed(context, '/signin');
    }
    on SocketException {
      // Specific error handling for network issues
      const networkMsg = 'Network error. Please check your connection.';
      setState(() => _error = networkMsg);
      _showError(networkMsg);
    }
    catch (e) {
      // General error handling - clean error message for display
      final cleaned = e.toString().replaceFirst(RegExp(r'^[^:]+:\s*'), '');
      setState(() => _error = cleaned);
      _showError(cleaned);
    }
    finally {
      // Reset loading state whether success or failure
      setState(() => _loading = false);
    }
  }

  /// Helper method to display error messages in a SnackBar
  /// Removes exception prefix for cleaner display
  void _showError(String message) {
    final displayMsg = message.replaceFirst(RegExp(r'^[^:]+:\s*'), '');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(displayMsg)),
    );
  }

  /// Conditionally renders error message if present
  Widget _buildError() {
    if (_error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(_error!, style: const TextStyle(color: Colors.red)),
    );
  }

  /// Builds the main form container with input fields
  /// Each field has specific validation rules
  Widget _buildFormContainer() {
    return AuthFormContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Email field with email format validation
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
          
          // Name field with capitalization validation
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
                // Validates that name starts with uppercase and contains only letters
                final nameRegex = RegExp(r'^[A-Z][a-zA-Z ]*$');
                if (!nameRegex.hasMatch(val.trim())) {
                  return 'Name must start with uppercase and contain only letters';
                }
                return null;
              },
            ),
          ),
          
          // Phone field with digit count validation
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
                // Requires exactly 12 digits
                final phoneRegex = RegExp(r'^\d{12}$');
                if (!phoneRegex.hasMatch(val.trim())) {
                  return 'Phone must be 12 digits';
                }
                return null;
              },
            ),
          ),
          
          // Password field with visibility toggle and special char validation
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
                // Requires at least one special character
                if (!RegExp(r'.*[@$#.*].*').hasMatch(val)) {
                  return 'must contain special character either . * @ # \$';
                }
                return null;
              },
            ),
          ),
          _buildError(), // Shows error message if present
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate padding based on keyboard visibility
    final insets = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = insets > 0 ? insets + 16 : 0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const Background(), // Decorative background
          Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                // Adjust padding based on device and keyboard
                top: kToolbarHeight + MediaQuery.of(context).padding.top + 60,
                left: 16,
                right: 16,
                bottom: bottomPadding.toDouble(),
              ),
              child: Form(
                key: _formKey, // Connect form to form key for validation
                child: Column(
                  children: [
                    LogoHeader(), // App logo
                    _buildFormContainer(), // Registration form fields
                    const SizedBox(height: 20),
                    
                    // Register button with loading state
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
                        onPressed: _loading ? null : _submit, // Disabled during loading
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
                    
                    // Sign In link for existing users
                    TextButton(
                      onPressed: widget.onSigninTap, // Navigate to sign-in
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