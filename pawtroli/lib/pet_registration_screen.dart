import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

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
  File? _image;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<String> uploadImage(File image) async {
    return 'https://via.placeholder.com/300.png?text=Pet';
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      String imageUrl = _image != null ? await uploadImage(_image!) : '';
      final petId = Uuid().v4();

      final response = await http.post(
        Uri.parse('http://192.168.0.164:8080/pets'),
        headers: {'Content-Type': 'application/json'},
        body: '''
        {
          "name": "$name",
          "type": "$type",
          "ownerId": "${widget.userId}",
          "imageUrl": "$imageUrl"
        }
        ''',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pet registered!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register pet')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register Pet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Pet Name'),
              onChanged: (val) => name = val,
              validator: (val) => val!.isEmpty ? 'Enter pet name' : null,
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Type (e.g., Dog, Cat)'),
              onChanged: (val) => type = val,
              validator: (val) => val!.isEmpty ? 'Enter pet type' : null,
            ),
            SizedBox(height: 10),
            _image != null
                ? Image.file(_image!, height: 150)
                : Placeholder(fallbackHeight: 150),
            TextButton(onPressed: _pickImage, child: Text('Pick Image')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _submit, child: Text('Register Pet')),
          ]),
        ),
      ),
    );
  }
}