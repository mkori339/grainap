import 'package:flutter/material.dart';
class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade800.withOpacity(0.4),
      appBar: AppBar(
         iconTheme: IconThemeData(color:Colors.white),
        backgroundColor: Colors.blueGrey.shade900,
        title: Text(
          'About this App',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo or Icon
            Center(
              child: Icon(
                Icons.chat_bubble_outline,
                size: 80,
                color: Colors.blue.shade100,
              ),
            ),
            SizedBox(height: 20),
            // App Name
            Center(
              child: Text(
                'Chatify',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            // App Description
            Text(
              'Welcome to Chatify!',
              style: TextStyle(
                color: Colors.blue.shade100,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Chatify is a modern and user-friendly messaging app designed to help you stay connected with your friends and family. With a sleek and intuitive interface, Chatify makes communication simple and enjoyable.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 20),
            // Key Features
            Text(
              'Key Features:',
              style: TextStyle(
                color: Colors.blue.shade100,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            FeatureItem(icon: Icons.chat, text: 'Real-time messaging'),
            FeatureItem(icon: Icons.thumb_up, text: 'Like and comment on messages'),
            FeatureItem(icon: Icons.notifications, text: 'Push notifications'),
            FeatureItem(icon: Icons.security, text: 'End-to-end encryption'),
            SizedBox(height: 20),
            // Developer Info
            Center(
              child: Text(
                'Developed by Your Company',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
        bottomNavigationBar: BottomAppBar(
        color: Colors.blueGrey.shade900,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            '© 2025 Hafidhi Mkori - All Rights Reserved',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({super.key, 
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.blue.shade100,
            size: 24,
          ),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}