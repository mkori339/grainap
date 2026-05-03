import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/authentificatin.dart';
import 'package:grainapp/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? bootstrapMessage;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on UnsupportedError catch (error) {
    bootstrapMessage =
        '$error\n\nThis desktop build can still open, but Firebase-backed features are only configured for Chrome and Android in this project.';
  } catch (error) {
    bootstrapMessage =
        'Firebase initialization failed.\n\n$error\n\nOpen the app on Chrome or Android after confirming your Firebase setup.';
  }

  runApp(MyApp(bootstrapMessage: bootstrapMessage));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.bootstrapMessage});

  final String? bootstrapMessage;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppThemeController _themeController = AppThemeController();

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppThemeScope(
      controller: _themeController,
      child: AnimatedBuilder(
        animation: _themeController,
        builder: (BuildContext context, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: buildAppTheme(brightness: Brightness.light),
            darkTheme: buildAppTheme(brightness: Brightness.dark),
            themeMode: _themeController.themeMode,
            home: widget.bootstrapMessage == null
                ? const LoginScreen()
                : BootstrapMessageScreen(message: widget.bootstrapMessage!),
          );
        },
      ),
    );
  }
}

class BootstrapMessageScreen extends StatelessWidget {
  const BootstrapMessageScreen({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.info_outline_rounded, size: 36),
                    const SizedBox(height: 16),
                    const Text(
                      'Platform setup required',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(message),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
