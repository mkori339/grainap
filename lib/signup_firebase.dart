import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:grainapp/app_access.dart';

Future<int> signUp(String email, String name, String password) async {
  try {
    final credential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
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
    debugPrint('Error during registration: $e');
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
    debugPrint('Error: $e');
    return 1;
  }
}

Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
  debugPrint('User signed out.');
}

Future<void> addUser(String name, String uid, String email) async {
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
    'uid': uid,
    'name': name.trim(),
    'email': email.trim(),
    'role': defaultRoleForEmail(email),
    'created_at': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));
}

Future<int> userPost({
  required String street,
  required String quantity,
  required String phone,
  required String explanation,
  required String productName,
  required double pricePerKg,
  required String region,
  required String districtName,
  required String postType,
  String? postId,
}) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    String uid = currentUser.uid;
    try {
      final userDocument = await firestore.collection('users').doc(uid).get();
      final userData = userDocument.data();
      final payload = <String, dynamic>{
        'username': (userData?['name'] ?? currentUser.displayName ?? 'Trader')
            .toString(),
        'usertable': uid,
        'mtaa': street.trim(),
        'quantyty': quantity.trim(),
        'phone': phone.trim(),
        'expl': explanation.trim(),
        'pname': productName.trim(),
        'price_per_kg': pricePerKg,
        'currency': 'TZS',
        'region': region,
        'distrname': districtName,
        'postType': postType.toLowerCase() == 'buy' ? 'buy' : 'sell',
      };

      if (postId == null || postId.trim().isEmpty) {
        await firestore.collection('userpost').add({
          ...payload,
          'created_at': FieldValue.serverTimestamp(),
        });
      } else {
        await firestore.collection('userpost').doc(postId).set({
          ...payload,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return 0;
    } catch (e) {
      debugPrint('Error: $e');
      return 1;
    }
  }
  return 1;
}
