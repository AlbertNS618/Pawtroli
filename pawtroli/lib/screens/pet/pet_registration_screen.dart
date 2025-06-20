import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../models/pet_model.dart';
import '../../services/pet_service.dart';
import '../home_page.dart';

class PetRegistrationScreen extends StatefulWidget {
  final String userId;
  const PetRegistrationScreen({super.key, required this.userId});

  @override
  State<PetRegistrationScreen> createState() => _PetRegistrationScreenState();
}

class _PetRegistrationScreenState extends State<PetRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String type = '';
  String gender = '';
  int age =  0;
  String color = '';
  String allergy = '';
  String other = '';
  File? _image;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _loading = true);
      try {
        final petId = Uuid().v4();

        final pet = PetModel(
          petId: petId,
          name: name,
          type: type,
          age:  age,
          ownerId: widget.userId,
          imageUrl: '',
          gender: gender,
          color: color,
          allergy: allergy,
          other: other,
          status: '',
          active: false,
        );

        final petService = PetService();
        final success = await petService.registerPet(pet);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet registered!')),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          _showError('Failed to register pet');
        }
      } catch (e) {
        _showError('Error: $e');
      } finally {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF232323),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 350,
              margin: const EdgeInsets.symmetric(vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top bar with back button and title
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.black),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'Register Pet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Pet image with add icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _image != null
                            ? FileImage(_image!)
                            : null,
                        child: _image == null
                            ? Image.asset(
                                'assets/images/pet_placeholder.png',
                                width: 48,
                                height: 48,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A2342),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Form fields
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          label: 'Pet Name',
                          onChanged: (val) => name = val,
                          validator: (val) => val == null || val.isEmpty ? 'Enter pet name' : null,
                        ),
                        _buildTextField(
                          label: 'Type',
                          onChanged: (val) => type = val,
                          validator: (val) => val == null || val.isEmpty ? 'Enter pet type' : null,
                        ),
                        _buildTextField(
                          label: 'Gender',
                          onChanged: (val) => gender = val,
                          validator: (val) => val == null || val.isEmpty ? 'Enter gender' : null,
                        ),
                        _buildTextField(
                          label: 'Age',
                          onChanged: (val) => age = int.tryParse(val) ?? 0,
                          validator: (val) => val == null || val.isEmpty ? 'Enter age' : null,
                        ),
                        _buildTextField(
                          label: 'Color',
                          onChanged: (val) => color = val,
                        ),
                        _buildTextField(
                          label: 'Allergy',
                          onChanged: (val) => allergy = val,
                        ),
                        _buildTextField(
                          label: 'Other',
                          onChanged: (val) => other = val,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0A2342),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}