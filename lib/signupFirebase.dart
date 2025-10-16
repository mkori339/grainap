import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'dart:io'; // Import for File type
// import 'package:firebase_storage/firebase_storage.dart';



Future<int> signUp(String email, String name, String password) async {
  try {
    // Create user with email and password
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid; 
         // Send email verification
      await currentUser.sendEmailVerification();
      print("Verification email sent to ${currentUser.email}.");
      // Insert user details into Firestore or another database
      await addUser(name, uid, email, password);
       
    }
    print("User registered successfully.");
    return 0; // Registration successful
  } on FirebaseAuthException catch (e) {
    print("Error during registration: $e");
    return 1; // Registration failed
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
Future<void> addUser(String name,String uid,String email,String password ) async {
  await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'uid': uid,
       'password': password,
      'name': name,
      'email': email,
      'created_at': FieldValue.serverTimestamp(),
    });
}
 // Import for Firebase Storage

// Future<String?> uploadFile(File file) async {
//   try {
//     // Create a unique filename based on the current timestamp
//     String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    
//     // Create a reference to the Firebase Storage path
//     Reference ref = FirebaseStorage.instance.ref().child('product_images/$fileName.jpg');
    
//     // Upload the file
//     UploadTask uploadTask = ref.putFile(file);
    
//     // Wait for the upload to complete and get the download URL
//     TaskSnapshot snapshot = await uploadTask;
//     String downloadUrl = await snapshot.ref.getDownloadURL();
    
//     return downloadUrl;
//   } on FirebaseException catch (e) {
//     print("Error uploading file: $e");
//     return null;
//   }
// }

Future<int> userPost(var mtaa, var quantyty, var phone, var expl, String pname, String region, String distrname, String prdpath) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  User? currentUser = FirebaseAuth.instance.currentUser;
  
  if (currentUser != null) {
    String uid = currentUser.uid;
    try {
      // Find user data from 'users' collection
      QuerySnapshot querySnapshot = await firestore.collection('users').where('uid', isEqualTo: uid).limit(1).get();
      DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
      Map<String, dynamic> userData = documentSnapshot.data() as Map<String, dynamic>;
      
      // Upload the image to Firebase Storage
      // String? imageUrl;
      // if (prdpath.isNotEmpty && prdpath != 'path') {
      //   File imageFile = File(prdpath);
      //   imageUrl = await uploadFile(imageFile);
      //   if (imageUrl == null) {
      //     print("Failed to upload image.");
      //     return 1;
      //   }
      // }
      
      // Add a new document to the 'userpost' collection
      await firestore.collection('userpost').add({
        'username': userData['name'],
        'created_at': FieldValue.serverTimestamp(),
        'usertable': uid,
        'mtaa': mtaa,
        'quantyty': quantyty,
        'phone': phone,
        'expl': expl,
        'pname': pname,
        'region': region,
        'distrname': distrname,
        'prdpath': "not defined", // Store the download URL here
      });
      
      print("Post saved successfully!");
      return 0;
    } catch (e) {
      print("Error: $e");
      return 1;
    }
  }
  return 1; // Return 1 if no user is signed in
}


