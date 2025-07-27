import 'package:flutter/material.dart';
import 'package:pawtroli/design_constant.dart';
import 'package:pawtroli/services/pet_service.dart';
import 'package:intl/intl.dart';

class PetActivationScreen extends StatefulWidget {
  const PetActivationScreen({super.key});

  @override
  _PetActivationScreenState createState() => _PetActivationScreenState();
}

class _PetActivationScreenState extends State<PetActivationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _petIdController = TextEditingController ();
  String petId = '';
  DateTime? _checkInDate;
  DateTime? _checkOutDate;

  @override
  void dispose() {
    _petIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isCheckIn) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isCheckIn) {
          _checkInDate = picked;
        } else {
          _checkOutDate = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: DesignConstant.pawBlue,
          toolbarHeight: 85,
          leading: IconButton(
            color: Colors.white,
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Pet Activation',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 20,
              fontFamily: 'Comic Neue',
            ),
          ),
          centerTitle: true,
        ),
      body:
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 50),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              TextFormField(
                controller: _petIdController,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: 'Pet ID',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                  (val == null || val.trim().isEmpty)
                    ? 'Pet ID is required'
                    : null,
              ),

              const SizedBox(height: 40),
              // Checked-In picker
              const Text('Checked-In', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context, true),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: _checkInDate == null
                        ? 'MM/DD/YYYY'
                        : DateFormat.yMd().format(_checkInDate!),
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (_) =>
                      _checkInDate == null
                        ? 'Select check-in date'
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 30),
              const Text('Checked-Out', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context, false),
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: _checkOutDate == null
                        ? 'MM/DD/YYYY'
                        : DateFormat.yMd().format(_checkOutDate!),
                      suffixIcon: const Icon(Icons.calendar_today),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (_) =>
                      _checkOutDate == null
                        ? 'Select check-out date'
                        : null,
                  ),
                ),
              ),

              const SizedBox(height: 50),
              Center(
                child: SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) return;

                      final id = _petIdController.text.trim();
                      await PetService().activatePet(
                        id,
                        _checkInDate!,
                        _checkOutDate!,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pet activated successfully!')),
                      );
                      Navigator.of(context).pushNamedAndRemoveUntil('/admin_home', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: DesignConstant.pawBlue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    child: const Text("Activate", style: TextStyle(color: Colors.white)),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}