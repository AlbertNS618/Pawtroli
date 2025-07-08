import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:pawtroli/design_constant.dart';
import 'package:pawtroli/widgets/bottom_navbar.dart';

class CCTVPage extends StatefulWidget {
  const CCTVPage({super.key});

  @override
  State<CCTVPage> createState() => _CCTVPageState();
}

class _CCTVPageState extends State<CCTVPage> {
  late VlcPlayerController _bedroomController;
  // late VlcPlayerController _playgroundController;

  @override
  void initState() {
    super.initState();
    _bedroomController = VlcPlayerController.network(
      'rtsp://192.168.0.113:554/profile0',
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
    // Example: Use a different RTSP or placeholder for playground
    // _playgroundController = VlcPlayerController.network(
    //   'rtsp://192.168.0.113:554/profile0', // Replace with actual playground RTSP if available
    //   hwAcc: HwAcc.full,
    //   autoPlay: true,
    //   options: VlcPlayerOptions(),
    // );
  }

  @override
  void dispose() {
    _bedroomController.dispose();
    // _playgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: DesignConstant.pawBlue,
        elevation: 0,
        toolbarHeight: 85, // <-- set exact height of AppBar
        title: const Text('CCTV', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false, // This prevents the automatic back button
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCameraCard('Bedroom', _bedroomController),
          const SizedBox(height: 16),
          // _buildCameraCard('Playground', _playgroundController),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 1) {
            goToChat(context); // Now imported from bottom_navbar.dart
          } else if (index == 2) {
            // Already on CCTV
          }
        },
      ),
    );
  }

  Widget _buildCameraCard(String label, VlcPlayerController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: VlcPlayer(
                controller: controller,
                aspectRatio: 16 / 9,
                placeholder: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
