import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pawtroli/screens/chat/chat_page.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/pet/pet_registration_screen.dart';
import 'screens/home_page.dart';
import 'screens/cctv/cctv_page.dart';
import 'screens/pet/pet_profile_page.dart';
import 'screens/profile/user_profile_page.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      home: const Entry(),
      routes: {
        '/home': (context) => const HomePage(),
        '/cctv': (context) => const CCTVPage(),
        '/pet_registration': (context) => PetRegistrationScreen(userId: FirebaseAuth.instance.currentUser?.uid ?? ''),
        '/pet_profile': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String;
          return PetProfilePage(petId: args);
        },
        '/profile': (context) => const UserProfilePage(),
        '/signin': (context) => SignInScreen(
          onRegisterTap: () {},
          onSignInSuccess: () {},
        ),
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
              otherUserName: 'Staff', // Always use "staff"
              adminId: adminId,
            ),
          );
        }
        return null; // fallback to default
      },
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
  bool showLogin = true;
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
      return const HomePage(); // Show main app with bottom nav
    }
    if (userId != null) {
      return PetRegistrationScreen(userId: userId!);
    }
    if (showLogin == false) {
      return RegisterScreen(onRegister: handleRegister, onSigninTap: () => setState(() => showLogin = true));
    }
    return SignInScreen(
      onRegisterTap: () => setState(() => showLogin = false),
      onSignInSuccess: handleSignIn,
    );
  }
}
/*
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const HomePage(),
    const JourneysPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Journeys',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}*/