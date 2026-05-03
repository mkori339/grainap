import 'package:animated_login/animated_login.dart';
import 'package:async/async.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/app_support.dart';
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
    final palette = context.appPalette;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[
                palette.background,
                palette.backgroundSoft,
                palette.panel,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: AnimatedLogin(
                      key: _loginKey,
                      logo: _buildLogo(),
                      initialMode: _currentMode,
                      signUpMode: SignUpModes.both,
                      loginTexts: _loginTexts,
                      loginMobileTheme: _mobileTheme,
                      onLogin: (LoginData data) async {
                        return _authOperation(
                          LoginFunctions(context).onLogin(data),
                        );
                      },
                      onSignup: (SignUpData data) async {
                        return _authOperation(
                          LoginFunctions(context).onSignup(data),
                        );
                      },
                      onForgotPassword: _onForgotPassword,
                      onAuthModeChange: (AuthMode newMode) async {
                        _currentMode = newMode;
                        await _operation?.cancel();
                      },
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ThemeModeButton(color: onSurface),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    final palette = context.appPalette;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      width: 124,
      height: 124,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: onSurface.withValues(alpha: 0.2)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: palette.accent.withValues(alpha: 0.18),
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
            'Umeingia. Unaweza kuthibitisha ${refreshed.email} ukitaka.',
          ),
          action: SnackBarAction(
            label: bi('Tuma linki', 'Send link'),
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
    final trimmedEmail = email.trim();

    if (trimmedEmail.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weka barua pepe kwanza.'),
          ),
        );
      }
      return null;
    }

    try {
      await _auth.sendPasswordResetEmail(email: trimmedEmail);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kiungo cha kubadili nenosiri kimetumwa kwa $trimmedEmail.',
            ),
          ),
        );
      }
      return null;
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message ??
                  'Imeshindikana kutuma kiungo cha kubadili nenosiri.',
            ),
          ),
        );
      }
      return null;
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
          SnackBar(
            content: Text(
              'Barua ya uthibitisho imetumwa kwa ${user.email}.',
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Hitilafu kutuma uthibitisho wa barua pepe: $error',
          ),
        ),
      );
    }
  }

  LoginTexts get _loginTexts => LoginTexts(
        welcome: bi('Karibu!', 'Welcome!'),
        welcomeDescription: bi(
          'Pata wanunuzi na wauzaji wa mazao kwa haraka.',
          'Find grain buyers and sellers quickly.',
        ),
        signUp: bi('Jisajili', 'Sign Up'),
        signUpFormTitle: bi('Fungua akaunti', 'Create account'),
        signUpUseEmail: bi(
          'au tumia barua pepe kujisajili:',
          'or use your email for registration:',
        ),
        welcomeBack: bi('Karibu tena!', 'Welcome back!'),
        welcomeBackDescription: bi(
          'Ingia uone bei, matangazo na masoko ya karibu.',
          'Sign in to view prices, listings, and nearby markets.',
        ),
        login: bi('Ingia', 'Login'),
        loginFormTitle: bi('Ingia kwenye akaunti', 'Login to account'),
        loginUseEmail: bi(
          'au tumia akaunti yako ya barua pepe:',
          'or use your email account:',
        ),
        forgotPassword: bi(
          'Umesahau nenosiri?',
          'Forgot password?',
        ),
        notHaveAnAccount: bi(
          'Huna akaunti?',
          'Don\'t have an account?',
        ),
        alreadyHaveAnAccount: bi(
          'Una akaunti tayari?',
          'Already have an account?',
        ),
        nameHint: bi('Jina', 'Name'),
        signupEmailHint: bi('Barua pepe', 'Email'),
        signupPasswordHint: bi('Nenosiri', 'Password'),
        loginEmailHint: bi('Barua pepe', 'Email'),
        loginPasswordHint: bi('Nenosiri', 'Password'),
        confirmPasswordHint: bi('Thibitisha nenosiri', 'Confirm password'),
        passwordMatchingError: bi(
          'Nenosiri halifanani. Angalia tena.',
          'Passwords do not match. Check again.',
        ),
        dialogButtonText: bi('Sawa', 'OK'),
      );

  LoginViewTheme get _mobileTheme => LoginViewTheme(
        backgroundColor: Colors.transparent,
        formFieldBackgroundColor: context.appPalette.panelSoft.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.34 : 0.84,
        ),
        formFieldHoverColor: context.appPalette.accent.withValues(alpha: 0.08),
        formWidthRatio: 72,
        textFormStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
        hintTextStyle: TextStyle(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.58),
        ),
        useEmailStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        changeActionTextStyle: TextStyle(
          color: context.appPalette.accentSoft,
          fontWeight: FontWeight.w700,
          decoration: TextDecoration.none,
        ),
        forgotPasswordStyle: TextStyle(
          color: context.appPalette.accentSoft,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.none,
        ),
        actionButtonStyle: FilledButton.styleFrom(
          backgroundColor: context.appPalette.accent,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        privacyPolicyStyle: TextStyle(
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
        ),
        privacyPolicyLinkStyle: TextStyle(
          color: context.appPalette.accentSoft,
          decoration: TextDecoration.none,
        ),
        enabledBorderColor:
            Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.12),
        focusedBorderColor: context.appPalette.accent,
        focusedErrorBorderColor: Theme.of(context).colorScheme.error,
        errorBorderColor: Theme.of(context).colorScheme.error,
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
