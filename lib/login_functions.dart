import 'package:animated_login/animated_login.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/signupFirebase.dart';

class LoginFunctions {
  final BuildContext context;

  LoginFunctions(this.context);

  /// Simulate login functionality
  Future<String?> onLogin(LoginData data) async {
    // Simulate a delay for a real network call
    await Future.delayed(const Duration(seconds: 2));
    int fedback= await  signIn(data.email, data.password );
    print("this is $fedback");
    print("mmmmmmmmmmmmmmmmmmmmmmmmmmmmm");
    // Mock logic for authentication
    if (fedback==0) {
    return null; // Return null on success (as the operation completed successfully)
    } else {
      return 'Invalid credential'; // Return error message on failure
    }
  }

  /// Simulate signup functionality
  Future<String?> onSignup(SignUpData data) async {
    // Simulate a delay for a real network call
    await Future.delayed(const Duration(seconds: 2));

    // Mock logic for creating a new user
    if (data.email.contains('@') && data.password.length >= 6 && data.password==data.confirmPassword) {
      int feedback= await signUp(data.email,data.name, data.password);
  if(feedback==0){
 return 'please go to your email to verify';
  }else{
  return 'this user is already exist'; 
  }
      // Successful signup
    } else {
      return 'failed,Please check your details.'; // Error message on failure
    }
  }

 
}

