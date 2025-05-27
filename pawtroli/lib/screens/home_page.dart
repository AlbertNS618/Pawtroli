import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: 60,
        backgroundColor: Colors.grey[300],
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text('Logo', style: TextStyle(color: Colors.black)),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dashboard
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text("Dashboard", style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 16),

            // 3 circular quick buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (_) {
                return CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                );
              }),
            ),
            const SizedBox(height: 24),

            // Chat Button
            buildHomeButton("Chat Button"),
            const SizedBox(height: 12),

            // Feeds Button
            buildHomeButton("Feeds Button"),
            const SizedBox(height: 12),

            // CCTV Button
            buildHomeButton("CCTV Button"),
          ],
        ),
      ),
    );
  }

  Widget buildHomeButton(String title) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          // TODO: Implement navigation
        },
        child: Text(title, style: TextStyle(color: Colors.black, fontSize: 16)),
      ),
    );
  }
}