import 'package:flutter/material.dart';
import 'package:grainapp/contact_actions.dart';
import 'package:grainapp/post_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class DeveloperProfilePage extends StatelessWidget {
  const DeveloperProfilePage({super.key});

  static const String _phone = '0785226584';

  Future<void> _launch(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted || launched) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Unable to open ${uri.toString()}.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Developer')),
      body: MarketBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              MarketPanel(
                child: Column(
                  children: <Widget>[
                    const CircleAvatar(
                      radius: 52,
                      backgroundImage: AssetImage('images/image1.webp'),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Hafidhi Mkori',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mobile developer',
                      style: TextStyle(color: Colors.white.withOpacity(0.68)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Focused on practical marketplace apps with cleaner flows, stronger UI, and direct contact actions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.82), height: 1.6),
                    ),
                    const SizedBox(height: 20),
                    const InfoPill(icon: Icons.call_outlined, label: _phone),
                    const SizedBox(height: 18),
                    ContactActionRow(
                      phone: _phone,
                      message: 'Hello Hafidhi, I would like to talk about the app.',
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        IconButton.filledTonal(
                          onPressed: () {
                            _launch(
                              context,
                              Uri.parse('https://www.facebook.com/profile.php?id=61557046421220'),
                            );
                          },
                          icon: const Icon(Icons.facebook),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {
                            _launch(
                              context,
                              Uri.parse('https://portifolio-psi-fawn-94.vercel.app/#pigraHome'),
                            );
                          },
                          icon: const Icon(Icons.link_rounded),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {
                            _launch(context, Uri.parse('mailto:mkorihafidhi@gmail.com'));
                          },
                          icon: const Icon(Icons.mail_outline_rounded),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {
                            _launch(
                              context,
                              Uri.parse(
                                'https://wa.me/${normalizePhoneNumber(_phone)}?text=${Uri.encodeComponent('Hello Hafidhi')}',
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded),
                        ),
                      ],
                    ),
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
