import 'package:flutter/material.dart';
import 'package:grainapp/post_widgets.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About App')),
      body: MarketBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: const <Widget>[
              MarketPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SectionHeader(
                      icon: Icons.grass_rounded,
                      title: 'Local grain marketplace',
                      subtitle: 'Built for buyers and sellers who want fast contact.',
                    ),
                    SizedBox(height: 18),
                    Text(
                      'This app helps traders post buy requests and sell offers, then connect directly through WhatsApp or a normal phone call.',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              MarketPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SectionHeader(
                      icon: Icons.flash_on_rounded,
                      title: 'What changed',
                      subtitle: 'The app now focuses on speed and simpler contact.',
                    ),
                    SizedBox(height: 18),
                    InfoPill(icon: Icons.login_rounded, label: 'Login works even before email verification'),
                    SizedBox(height: 10),
                    InfoPill(icon: Icons.sell_outlined, label: 'Posts support sell and buy types'),
                    SizedBox(height: 10),
                    InfoPill(icon: Icons.image_not_supported_outlined, label: 'Image upload logic removed from posting'),
                    SizedBox(height: 10),
                    InfoPill(icon: Icons.call_rounded, label: 'In-app chat replaced by WhatsApp and phone actions'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
