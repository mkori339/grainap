import 'package:animated_login/animated_login.dart';
import 'package:async/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/dialog_builders.dart';
import 'package:grainapp/login_functions.dart';
import 'package:grainapp/regionscreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CancelableOperation<String?>? _operation;
  Key _loginKey = UniqueKey();
  AuthMode _currentMode = AuthMode.login;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                AppColors.background,
                AppColors.backgroundSoft,
                AppColors.panel,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: AnimatedLogin(
              key: _loginKey,
              logo: _buildLogo(),
              initialMode: _currentMode,
              signUpMode: SignUpModes.both,
              loginMobileTheme: _mobileTheme,
              onLogin: (LoginData data) async {
                return _authOperation(LoginFunctions(context).onLogin(data));
              },
              onSignup: (SignUpData data) async {
                return _authOperation(LoginFunctions(context).onSignup(data));
              },
              onForgotPassword: _onForgotPassword,
              onAuthModeChange: (AuthMode newMode) async {
                _currentMode = newMode;
                await _operation?.cancel();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 124,
      height: 124,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.22)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.accent.withOpacity(0.18),
            blurRadius: 36,
            spreadRadius: 8,
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'images/login.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Future<String?> _authOperation(Future<String?> authCall) async {
    await _operation?.cancel();
    _operation = CancelableOperation<String?>.fromFuture(authCall);
    final result = await _operation?.valueOrCancellation();

    if (_operation?.isCompleted != true || !mounted) {
      return result;
    }

    if (result == null) {
      setState(() {
        _loginKey = UniqueKey();
      });
      await _completeAuthentication();
      return null;
    }

    await DialogBuilder(context).showResultDialog(result);
    return result;
  }

  Future<void> _completeAuthentication() async {
    final user = _auth.currentUser;
    if (user == null || !mounted) {
      return;
    }

    await user.reload();
    final refreshed = _auth.currentUser;
    if (!mounted || refreshed == null) {
      return;
    }

    if (!refreshed.emailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Logged in. Email verification is optional, but you can still verify ${refreshed.email}.',
          ),
          action: SnackBarAction(
            label: 'Send link',
            onPressed: sendVerificationEmail,
          ),
        ),
      );
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const RegionScreen(),
      ),
    );
  }

  Future<String?> _onForgotPassword(String email) async {
    if (email.trim().isEmpty) {
      return 'Enter your email first.';
    }

    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return 'Password reset link sent.';
    } on FirebaseAuthException catch (error) {
      return error.message ?? 'Unable to send reset link.';
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification email sent to ${user.email}.')),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending email verification: $error')),
      );
    }
  }

  LoginViewTheme get _mobileTheme => LoginViewTheme(
        backgroundColor: Colors.transparent,
        formFieldBackgroundColor: Colors.white.withOpacity(0.08),
        formWidthRatio: 72,
        actionButtonStyle: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: AppColors.background,
        ),
        privacyPolicyStyle: TextStyle(color: Colors.white.withOpacity(0.65)),
        privacyPolicyLinkStyle: const TextStyle(color: AppColors.accentSoft),
        animatedComponentOrder: const <AnimatedComponent>[
          AnimatedComponent(
            component: LoginComponents.logo,
            animationType: AnimationType.right,
          ),
          AnimatedComponent(component: LoginComponents.title),
          AnimatedComponent(component: LoginComponents.formTitle),
          AnimatedComponent(component: LoginComponents.useEmail),
          AnimatedComponent(component: LoginComponents.form),
          AnimatedComponent(component: LoginComponents.forgotPassword),
          AnimatedComponent(component: LoginComponents.changeActionButton),
          AnimatedComponent(component: LoginComponents.actionButton),
          AnimatedComponent(component: LoginComponents.notHaveAnAccount),
        ],
      );
}
