import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:pawtroli/design_constant.dart';
import 'package:pawtroli/models/pet_update_model.dart';
import 'package:pawtroli/services/pet_update_service.dart';
import 'package:uuid/uuid.dart';

class PetUpdateUploadScreen extends StatefulWidget {
  final String? petId; // Optional: if you want to pass a pet ID
  const PetUpdateUploadScreen({super.key, this.petId});

  @override
  _PetUpdateUploadScreenState createState() => _PetUpdateUploadScreenState();
}

class _PetUpdateUploadScreenState extends State<PetUpdateUploadScreen> {
  String? selectedCategory;
  String? selectedActivity;
  final List<String> categories = ['Morning', 'Afternoon', 'Night'];
  final List<String> activities = ['Eat', 'Drink', 'Play', 'Sleep', 'Pee', 'Poo', 'Walking'];
  final TextEditingController descriptionController = TextEditingController();
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: DesignConstant.pawBlue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        underline: SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
        hint: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(hint, style: TextStyle(color: Colors.white)),
        ),
        value: value,
        dropdownColor: DesignConstant.pawBlue,
        style: TextStyle(color: Colors.white),
        onChanged: onChanged,
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(value),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: DesignConstant.pawBlue, 
          elevation: 0,
          toolbarHeight: 85,
          leading: IconButton(
            color: Colors.white,
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Upload',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 20),
          ),
          centerTitle: true,
        ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              // Image upload area
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: InkWell(
                  onTap: _getImage,
                  child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover, width: double.infinity)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/images/add_image.png', width: 80, height: 80),
                          const SizedBox(height: 16),
                          Text('Upload Image', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                        ],
                      ),
                ),
              ),

              const SizedBox(height: 20),

              // Dropdowns row
              Row(
                children: [
                  Expanded(
                    child: _buildDropdown(
                      hint: 'Category',
                      value: selectedCategory,
                      items: categories,
                      onChanged: (v) => setState(() => selectedCategory = v),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDropdown(
                      hint: 'Activity',
                      value: selectedActivity,
                      items: activities,
                      onChanged: (v) => setState(() => selectedActivity = v),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Description text field
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Add a description...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 40),

              // Post button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    await PetUpdateService().addPetUpdate(
                      PetUpdateModel(
                        id: Uuid().v4(),
                        caption: selectedActivity ?? '',
                        timestamp: DateTime.now().toUtc(),
                        description: descriptionController.text,
                        imageUrl: "placeholder_for_image_url", // Replace with actual image upload logic
                      ),
                      petId: widget.petId ?? '',
                  ).then((value) {
                    if (value) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Update posted successfully!')),
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to post update.')),
                      );
                    }
                  });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignConstant.pawBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: const Text(
                    'POST', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.white
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}