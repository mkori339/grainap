import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/authentificatin.dart';
import 'package:grainapp/firebase_options.dart';

void main()async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
     return MaterialApp(
        theme: ThemeData(
         // primarySwatch: Colors.grey,
          //primaryColor: Color.fromARGB(255, 247, 246, 246)
          primaryColor: Colors.white,
        colorScheme: const ColorScheme.light(primary: Colors.white),
        
        textTheme: Theme.of(context).textTheme.apply(
         decorationColor:Colors.transparent.withOpacity(0.01),
         decoration: TextDecoration.none
),
        inputDecorationTheme: const InputDecorationTheme(
          prefixIconColor: Colors.black54,
          suffixIconColor: Colors.black54,
          iconColor: Colors.black54,
          labelStyle: TextStyle(color: Colors.black54),
          hintStyle: TextStyle(color: Colors.black54),
        ),),
        //home: RegionScreen(),
        home: LoginScreen(),
        
      );
  }
}


