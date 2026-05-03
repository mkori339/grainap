import 'package:animated_login/animated_login.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/signup_firebase.dart';

class LoginFunctions {
  final BuildContext context;

  LoginFunctions(this.context);

  /// Simulate login functionality
  Future<String?> onLogin(LoginData data) async {
    await Future.delayed(const Duration(seconds: 2));
    final feedback = await signIn(data.email, data.password);

    if (feedback == 0) {
      return null;
    }

    return 'Barua pepe au nenosiri si sahihi.';
  }

  /// Simulate signup functionality
  Future<String?> onSignup(SignUpData data) async {
    await Future.delayed(const Duration(seconds: 2));

    if (data.email.contains('@') &&
        data.password.length >= 6 &&
        data.password == data.confirmPassword) {
      final feedback = await signUp(data.email, data.name, data.password);
      if (feedback == 0) {
        return null;
      }

      return 'Mtumiaji huyu tayari yupo au hakuweza kuundwa.';
    }

    return 'Imeshindikana. Angalia taarifa zako kisha jaribu tena.';
  }
}
