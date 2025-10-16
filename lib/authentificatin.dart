
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grainapp/regionscreen.dart';
import '../dialog_builders.dart';
import '../login_functions.dart';
import 'package:animated_login/animated_login.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
/// Example login screen
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
   Key _loginKey= UniqueKey();
   
  /// Current auth mode, default is [AuthMode.login].
  AuthMode currentMode = AuthMode.login;
 final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isEmailVerified = false;
  CancelableOperation? _operation;


  @override
  Widget build(BuildContext context) {
 
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Container(
          decoration: BoxDecoration(
        gradient: LinearGradient(
        colors: [Colors.blueGrey.shade900,  Colors.blueGrey.shade900, Colors.blueGrey.shade700,Colors.blueGrey.shade900,Colors.blueGrey.shade900],
         
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
        ),
      ),
        child: AnimatedLogin(
          key: _loginKey,
          onLogin: (LoginData data) async =>
              _authOperation(LoginFunctions(context).onLogin(data)),
          onSignup: (SignUpData data) async =>
             _authOperation(LoginFunctions(context).onSignup(data)),
          onForgotPassword: _onForgotPassword,
          logo: Container(
          width: 120,  // Adjust the width as needed
          height: 120, // Adjust the height as needed
          decoration: BoxDecoration(
        shape: BoxShape.circle,
       
          ),
          child: ClipOval(
        child: Image.asset(
          'images/login.png',
          width: 100,  // Adjust the width of the image as needed
          height: 200, // Adjust the height of the image as needed
          fit: BoxFit.fill, // Ensures the image fits within the circle
        ),
          ),
        ),
        
        
          signUpMode: SignUpModes.both,
          loginMobileTheme: _mobileTheme,
          emailValidator: ValidatorModel(
              validatorCallback: (String? email) => 'What an email! $email'),
          initialMode: currentMode,
          onAuthModeChange: (AuthMode newMode) async {
            currentMode = newMode;
            await _operation?.cancel();
          },
        ),
      ),
    );
  }

  Future<String?> _authOperation(Future<String?> func) async {
    await _operation?.cancel();
    _operation = CancelableOperation.fromFuture(func);
    final String? res = await _operation?.valueOrCancellation();
    if (_operation?.isCompleted == true) {
      if(res==null){
        setState(() {
      _loginKey = UniqueKey(); // Change the key to rebuild the AnimatedLogin widget.
    });
      checkVerificationStatus();
      }
      else {
        DialogBuilder(context).showResultDialog(res);
      }  
    }
    
    return res;
  }

   /// Simulate forgot password functionality
  Future<String?> _onForgotPassword(String email) async {
         ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.blueGrey.shade200,  content:  Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(
            maxWidth: 200, // Set maximum width for the dialog
            maxHeight: 150, // Set maximum height for the dialog
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Center(
                      child: Text("fill your email",
                        style: const TextStyle(
                          color: Colors.red, // Red text for the message
                          fontSize: 14, // Smaller font size for the message
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  //validate and send the link to chandge password
                },
              ),
            ],
          ),
        ),
                ),);
       return "link sent to your email for reset new password";   
  }


  /// Mobile theme customization.
  LoginViewTheme get _mobileTheme => LoginViewTheme(
        backgroundColor: Colors.transparent,
        formFieldBackgroundColor: Colors.white30,
        formWidthRatio: 60,
        actionButtonStyle: ButtonStyle(
          foregroundColor: WidgetStateProperty.all(Colors.white),
          backgroundColor: WidgetStateProperty.all(Colors.black),
        ),
        animatedComponentOrder: const <AnimatedComponent>[
          AnimatedComponent(
            component: LoginComponents.logo,
            animationType: AnimationType.right,
          ),
          AnimatedComponent(component: LoginComponents.title,animationType: AnimationType.left),
         // AnimatedComponent(component: LoginComponents.description,animationType: AnimationType.left),
  
         AnimatedComponent(component: LoginComponents.formTitle),
          AnimatedComponent(component: LoginComponents.useEmail),
          AnimatedComponent(component: LoginComponents.form),
          AnimatedComponent(component: LoginComponents.notHaveAnAccount),
          AnimatedComponent(component: LoginComponents.forgotPassword),
          AnimatedComponent(component: LoginComponents.changeActionButton),
          AnimatedComponent(component: LoginComponents.actionButton),
        ],
        privacyPolicyStyle: const TextStyle(color: Colors.white70,
         ),
        privacyPolicyLinkStyle: const TextStyle(
            color: Colors.white,),
      );
    

    Future<void> checkVerificationStatus() async {
   try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.reload();
        setState(() {
        isEmailVerified = user.emailVerified;
        });

        if (isEmailVerified) {
             Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  RegionScreen(),
            ),
          );
        } else {
           String verify="Please verify your email by click the link we send to ${user.email} within 24 hours";
    
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Column(
              children: [
                Text(verify),
                 SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                    await sendVerificationEmail();
                     setState(() {
                       verify="link  send to ${user.email} please go to your email to verify";
                     });
                    // await checkVerificationStatus();
                    },
                    child: Text("Resend ",
                    style: TextStyle( color:Colors.blueGrey.shade800),),
                  ),
              ],
            )),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error checking email verification: $e")),
      );
    }
  }
    Future<void> sendVerificationEmail() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification email sent to ${user.email}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error sending email verification: $e")),
      );
    }
  }
}

/// Example forgot password screen

