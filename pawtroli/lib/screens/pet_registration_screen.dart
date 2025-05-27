import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/pet_model.dart';
import '../services/pet_service.dart';
import 'home_page.dart';

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
  String age = '';
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
          age: age,
          ownerId: widget.userId,
          imageUrl: '', // Not used, always placeholder elsewhere
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Register Pet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
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
              top: kToolbarHeight + MediaQuery.of(context).padding.top + 20,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
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
                            decoration: const InputDecoration(labelText: 'Pet Name'),
                            onChanged: (val) => name = val,
                            validator: (val) => val == null || val.isEmpty ? 'Enter pet name' : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Type (e.g., Dog, Cat)'),
                            onChanged: (val) => type = val,
                            validator: (val) => val == null || val.isEmpty ? 'Enter pet type' : null,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            decoration: const InputDecoration(labelText: 'Age'),
                            onChanged: (val) => age = val,
                            validator: (val) => val == null || val.isEmpty ? 'Enter pet age' : null,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _image != null
                            ? Image.file(_image!, height: 150)
                            : Image.asset(
                                'assets/images/pet_placeholder.png',
                                height: 150,
                              ),
                        TextButton(
                          onPressed: _pickImage,
                          child: const Text('Pick Image'),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Pet photo will use a default placeholder in other screens.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const CircularProgressIndicator()
                        : const Text('Register Pet'),
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