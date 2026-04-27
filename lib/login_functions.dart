import 'package:animated_login/animated_login.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/signupFirebase.dart';

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

    return 'Invalid email or password.';
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

      return 'This user already exists or could not be created.';
    }

    return 'Failed. Check your details and try again.';
  }
}
