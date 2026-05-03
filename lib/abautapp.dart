import 'package:flutter/material.dart';
import 'package:grainapp/contact_actions.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/post_widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

  static const String _developerPhone = '0785226584';

  Future<void> _launch(BuildContext context, Uri uri) async {
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!context.mounted || launched) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Imeshindikana kufungua linki.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Scaffold(
      appBar: AppBar(
        title: const MarketPageTitle(
          title: 'Kuhusu App / About App',
          subtitle:
              'Soko hili linafanya nini na nani amelijenga / What this marketplace does and who built it.',
        ),
        actions: const <Widget>[ThemeModeButton()],
      ),
      body: MarketBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              const MarketPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SectionHeader(
                      icon: Icons.grass_rounded,
                      title: 'Soko la nafaka / Local grain marketplace',
                      subtitle:
                          'Limejengwa kwa wanunuzi na wauzaji wanaotaka mawasiliano ya haraka / Built for buyers and sellers who want fast contact.',
                    ),
                    SizedBox(height: 18),
                    Text(
                      'App hii huwasaidia wafanyabiashara kutuma maombi ya kununua au matangazo ya kuuza, kisha kuwasiliana moja kwa moja kwa WhatsApp au simu.',
                      style: TextStyle(height: 1.6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const MarketPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SectionHeader(
                      icon: Icons.flash_on_rounded,
                      title: 'Kilichobadilika / What changed',
                      subtitle:
                          'App sasa inalenga kasi na mawasiliano rahisi / The app now focuses on speed and simpler contact.',
                    ),
                    SizedBox(height: 18),
                    InfoPill(
                      icon: Icons.login_rounded,
                      label:
                          'Login inafanya kazi kabla ya uthibitisho wa email',
                    ),
                    SizedBox(height: 10),
                    InfoPill(
                      icon: Icons.sell_outlined,
                      label: 'Matangazo yanaunga mkono kuuza na kununua',
                    ),
                    SizedBox(height: 10),
                    InfoPill(
                      icon: Icons.image_not_supported_outlined,
                      label: 'Kupakia picha kumeondolewa kwenye kutuma tangazo',
                    ),
                    SizedBox(height: 10),
                    InfoPill(
                      icon: Icons.call_rounded,
                      label: 'Chat ya ndani imebadilishwa na WhatsApp na simu',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              MarketPanel(
                child: Column(
                  children: <Widget>[
                    const SectionHeader(
                      icon: Icons.person_outline_rounded,
                      title: 'Msanidi / Developer',
                      subtitle:
                          'Wasiliana na mtu aliyejenga app / Contact the person behind the app experience.',
                    ),
                    const SizedBox(height: 22),
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: onSurface.withValues(alpha: 0.08),
                      child: Icon(
                        Icons.person_outline_rounded,
                        size: 42,
                        color: onSurface,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Hafidhi Mkori',
                      style:
                          TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Msanidi wa app',
                      style:
                          TextStyle(color: onSurface.withValues(alpha: 0.68)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Analenga app za soko zenye mtiririko rahisi, muonekano bora na mawasiliano ya moja kwa moja.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.82),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const InfoPill(
                      icon: Icons.call_outlined,
                      label: _developerPhone,
                    ),
                    const SizedBox(height: 18),
                    const ContactActionRow(
                      phone: _developerPhone,
                      message:
                          'Habari Hafidhi, ningependa kuzungumza kuhusu app.',
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
                              Uri.parse(
                                'https://www.facebook.com/profile.php?id=61557046421220',
                              ),
                            );
                          },
                          icon: const Icon(Icons.facebook),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {
                            _launch(
                              context,
                              Uri.parse(
                                'https://portifolio-psi-fawn-94.vercel.app/#pigraHome',
                              ),
                            );
                          },
                          icon: const Icon(Icons.link_rounded),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {
                            _launch(
                              context,
                              Uri.parse('mailto:mkorihafidhi@gmail.com'),
                            );
                          },
                          icon: const Icon(Icons.mail_outline_rounded),
                        ),
                        IconButton.filledTonal(
                          onPressed: () {
                            _launch(
                              context,
                              Uri.parse(
                                'https://wa.me/${normalizePhoneNumber(_developerPhone)}?text=${Uri.encodeComponent('Hello Hafidhi')}',
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
