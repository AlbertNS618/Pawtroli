import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:page_transition/page_transition.dart';
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

/// Main app
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
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
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
                // when user taps "Sign in here"
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
                // when user taps "Register here"
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

          return PageTransition(
            child: ChatPage(
              chatId: chatId,
              currentUserId: currentUserId,
              otherUserName: 'Staff',
              adminId: adminId,
            ),
            type: PageTransitionType.fade, 
            duration: const Duration(milliseconds: 300),
            settings: settings,
          );
        }

        return null; // fallback if route not recognized
      },
    );
  }
}