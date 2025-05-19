import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'pet_registration_screen.dart';

void main() {
  runApp(MaterialApp(home: Entry()));
}

class Entry extends StatefulWidget {
  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  String? userId;

  @override
  Widget build(BuildContext context) {
    return userId == null
        ? LoginScreen(onLogin: (id) => setState(() => userId = id))
        : PetRegistrationScreen(userId: userId!);
  }
}