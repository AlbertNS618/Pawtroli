import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pawtroli/screens/admin/admin_cctv_page.dart';
import 'package:pawtroli/screens/admin/pet_update_upload.dart';
import 'package:pawtroli/screens/chat/chat_page.dart';
import 'package:pawtroli/screens/pet/pet_updates_screen.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/pet/pet_registration_screen.dart';
import 'screens/home_page.dart';
import 'screens/cctv/cctv_page.dart';
import 'screens/profile/user_profile_page.dart';
import 'screens/pet/pet_profile_page.dart';
import 'screens/admin/admin_pet_profile_page.dart';
import 'firebase_options.dart';
import 'screens/admin_home_page.dart';
import 'screens/admin/admin_chat_list_page.dart';
import 'screens/admin/pet_activation_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

Future<bool> _isUserAdmin(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user?.uid)
      .get();
  final role = (doc.data()?['role'] as String?) ?? 'user';
  return role == 'admin' ? true : false;
}

/// Main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pawtroli',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.comicNeueTextTheme(),
      ),
      initialRoute: '/signin',
      routes: {
        '/home': (context) => const HomePage(),
        '/register': (context) => RegisterScreen(
              onRegister: (userId) {
                // After registration, navigate to home
                Navigator.of(context).pushReplacementNamed('/home', arguments: userId);
              },
              onSigninTap: () {
                // when user taps “Sign in here”
                Navigator.of(context).pushNamed('/signin');
              },
            ),
        '/cctv': (context) => const CCTVPage(),
        '/pet_registration': (context) =>
            PetRegistrationScreen(userId: FirebaseAuth.instance.currentUser?.uid ?? ''),
        '/pet_profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return PetProfilePage(petId: args);
        },
        '/pet_updates': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return PetUpdatesScreen(petId: args);
        },
        '/profile': (context) => const UserProfilePage(),
        '/signin': (context) => SignInScreen(
              onSignInSuccess: () async {
                if (await _isUserAdmin(context)) {
                  Navigator.of(context).pushReplacementNamed('/admin_home');
                } else {
                  Navigator.of(context).pushReplacementNamed('/home');
                }
              },
              onRegisterTap: () {
                // when user taps “Register here”
                Navigator.of(context).pushNamed('/register');
              },
            ),
        '/admin_home': (context) => const AdminHomePage(),
        '/admin_cctv': (context) => AdminCCTVPage(),
        '/admin_pet_profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return AdminPetProfilePage(petId: args);
        },
        '/admin_chat': (context) {
          final adminId = FirebaseAuth.instance.currentUser?.uid ?? '';
          return AdminChatListPage(adminId: adminId);
        },
        '/pet_activation': (context) {
          return PetActivationScreen();
        },
        '/pet_update_upload': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>?; 
          final petId = args?['petId'] as String?;
          return PetUpdateUploadScreen(petId: petId);
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/chat') {
          final args = settings.arguments as Map<String, dynamic>;
          final chatId = args['chatId'] as String;
          final adminId = args['adminId'] as String;
          final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

          return MaterialPageRoute(
            builder: (context) => ChatPage(
              chatId: chatId,
              currentUserId: currentUserId,
              otherUserName: 'Staff', // Always use "Staff"
              adminId: adminId,
            ),
          );
        }
        return null; // fallback if route not recognized
      },
    );
  }
}

/// Initial screen that decides where the user goes: sign in, register, or home/admin screens.
class Entry extends StatefulWidget {
  const Entry({super.key});

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  String? userId;
  bool showLogin = true;
  bool isSignedIn = false;

  void handleSignIn() {
    setState(() => isSignedIn = true);
  }

  void handleRegister(String id) {
    setState(() {
      userId = id;
      showLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // If user is signed in, decide if user is admin or normal user
    if (isSignedIn) {
      // Use a FutureBuilder to load the role from Firestore
      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // If doc doesn't exist or no data, default to user role
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const HomePage();
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final role = data['role'] ?? 'user';
          if (role == 'admin') {
            return const AdminHomePage();
          } else {
            return const HomePage();
          }
        },
      );
    }

    // If user just registered, proceed to pet registration
    if (userId != null) {
      return PetRegistrationScreen(userId: userId!);
    }

    // Decide between Sign In and Register
    if (!showLogin) {
      return RegisterScreen(
        onRegister: handleRegister,
        onSigninTap: () => setState(() => showLogin = true),
      );
    }
    return SignInScreen(
      onRegisterTap: () => setState(() => showLogin = false),
      onSignInSuccess: handleSignIn,
    );
  }
}

