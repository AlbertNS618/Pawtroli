import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:pawtroli/design_constant.dart';
import 'package:pawtroli/widgets/bottom_navbar.dart';

class AdminCCTVPage extends StatefulWidget {
  const AdminCCTVPage({super.key});

  
  @override
  State<AdminCCTVPage> createState() => _AdminCCTVPageState();
}

class _AdminCCTVPageState extends State<AdminCCTVPage> {
  late VlcPlayerController _bedroomController;

  @override
  void initState() {
    super.initState();
    try {
      _bedroomController = VlcPlayerController.network(
        'rtsp://192.168.0.113:554/profile0',
        hwAcc: HwAcc.full,
        autoPlay: true,
        options: VlcPlayerOptions(),
      );
    } catch (e) {
      developer.log('VLC error: $e');
    }
  }

  @override
  void dispose() {
    _bedroomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: DesignConstant.pawBlue,
        elevation: 0,
        toolbarHeight: 85, 
        title: const Text(
          'CCTV',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCameraCard('Bedroom', _bedroomController),
          const SizedBox(height: 16),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/admin_home');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/admin_chat');
          } else if (index == 2) {
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
