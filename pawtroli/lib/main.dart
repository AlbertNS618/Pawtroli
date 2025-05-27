import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'screens/signin_screen.dart';
import 'screens/register_screen.dart';
import 'screens/pet_registration_screen.dart';
import 'screens/home_page.dart'; // Create this if not present
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pawtroli',
      home: const Entry(),
    );
  }
}

class Entry extends StatefulWidget {
  const Entry({super.key});

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  String? userId;
  bool showLogin = false;
  bool isSignedIn = false;

  void handleSignIn() {
    setState(() {
      isSignedIn = true;
    });
  }

  void handleRegister(String id) {
    setState(() {
      userId = id;
      showLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isSignedIn) {
      return const HomePage(); // Show home page after sign in
    }
    if (userId != null) {
      return PetRegistrationScreen(userId: userId!);
    }
    if (showLogin) {
      return RegisterScreen(onRegister: handleRegister);
    }
    return SignInScreen(
      onRegisterTap: () => setState(() => showLogin = true),
      onSignInSuccess: handleSignIn,
    );
  }
}