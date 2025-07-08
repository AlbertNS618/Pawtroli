import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/pet_model.dart';
import '../../services/pet_service.dart';
import '../../design_constant.dart';

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
  int age = 0;
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
        // 1. Fetch only this user’s pets
        final snap = await FirebaseFirestore.instance
            .collection('pets')
            .get();
        final currentCount = snap.docs.length;

        // 2. Build petId as "PW" + (currentCount + 1)
        final petId = 'PW_${currentCount + 1}';

        final pet = PetModel(
          petId: petId,
          name: name,
          type: type,
          age: age,
          ownerId: widget.userId,
          imageUrl: '',
          gender: gender,
          color: color,
          allergy: allergy,
          other: other,
          status: '-',
          active: false,
        );

        final petService = PetService();
        final success = await petService.registerPet(pet);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet registered successfully!')),
          );
          Navigator.pushReplacementNamed(context, '/home');
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Register Pet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Pet image with add icon
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.grey[300],
                        backgroundImage: _image != null ? FileImage(_image!) : null,
                        child: _image == null
                            ? Image.asset(
                                'assets/images/pet_placeholder.png',
                                width: 60,
                                height: 60,
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: DesignConstant.pawBlue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(Icons.add, color: Colors.white, size: 24),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  
                  // Form fields
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
                    keyboardType: TextInputType.number,
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
                    label: 'Other Information',
                    onChanged: (val) => other = val,
                    maxLines: 3,
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Register button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignConstant.pawBlue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Register Pet',
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
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade400),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: DesignConstant.pawBlue, width: 2),
          ),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}