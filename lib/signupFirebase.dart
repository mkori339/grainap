import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

Future<int> signUp(String email, String name, String password) async {
  try {
    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final currentUser = credential.user;
    if (currentUser != null) {
      await currentUser.updateDisplayName(name.trim());
      await currentUser.sendEmailVerification();
      await addUser(name, currentUser.uid, email);
    }

    return 0;
  } on FirebaseAuthException catch (e) {
    print("Error during registration: $e");
    return 1;
  }
}

Future<int> signIn(String email, String password) async {
  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return 0;
  } on FirebaseAuthException catch (e) {
    print("Error: $e");
    return 1;
  }
}
Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
  print("User signed out.");
}
Future<void> addUser(String name, String uid, String email) async {
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'uid': uid,
    'name': name.trim(),
    'email': email.trim(),
    'created_at': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<int> userPost({
  required String street,
  required String quantity,
  required String phone,
  required String explanation,
  required String productName,
  required String region,
  required String districtName,
  required String postType,
}) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    String uid = currentUser.uid;
    try {
      final userDocument = await firestore.collection('users').doc(uid).get();
      final userData = userDocument.data();

      await firestore.collection('userpost').add({
        'username': (userData?['name'] ?? currentUser.displayName ?? 'Trader').toString(),
        'created_at': FieldValue.serverTimestamp(),
        'usertable': uid,
        'mtaa': street.trim(),
        'quantyty': quantity.trim(),
        'phone': phone,
        'expl': explanation.trim(),
        'pname': productName.trim(),
        'region': region,
        'distrname': districtName,
        'postType': postType.toLowerCase() == 'buy' ? 'buy' : 'sell',
      });

      return 0;
    } catch (e) {
      print("Error: $e");
      return 1;
    }
  }
  return 1;
}
