import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grainapp/public%20chats.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late String uid;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    uid = uidfind();
  }

  String uidfind() {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      return currentUser.uid;
    }
    return '';
  }

  Stream<QuerySnapshot> getUsers() {
    return firestore
        .collection('userpost')
        .where('usertable', isEqualTo: uid)
        .snapshots();
  }

  Stream<int> getLikeCount(String postId) {
    return firestore
        .collection('post_likes')
        .where('post_id', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<bool> isLikedByUser(String postId) {
    return firestore
        .collection('post_likes')
        .doc('$uid$postId')
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<void> toggleLike(String postId) async {
    final likeDoc = firestore.collection('post_likes').doc('$uid$postId');
    final likeSnapshot = await likeDoc.get();

    if (likeSnapshot.exists) {
      await likeDoc.delete();
    } else {
      await likeDoc.set({
        'user_id': uid,
        'post_id': postId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<int> getCommentCount(String postId) {
    return firestore
        .collection('comments')
        .where('prid', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> deleteposts(String pid) async {
    try {
      await firestore.collection('userpost').doc(pid).delete();
      setState(() {});
      print('Document with ID $pid deleted successfully.');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey.shade900,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.blueGrey.shade800.withOpacity(0.1),
        title: const Center(
          child: Text(
            'Post informations',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                margin: const EdgeInsets.all(0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueGrey[800]!,
                        Colors.blueGrey[800]!,
                        Colors.black87
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: getUsers(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      return ListView(
                        children: snapshot.data!.docs.map((doc) {
                          String pstid = doc.id;
                          Timestamp timestamp = doc['created_at'];
                          DateTime dateTime = timestamp.toDate();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Product Name Container
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black,
                                      Colors.blueGrey.shade900
                                    ],
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                  child: Text(
                                    "posted product: ${doc['pname']}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Image Explanation Container
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[600],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  doc['expl'],
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Quantity, Region, District, Mtaa, Phone, and Time Container
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[500],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.storage, color: Colors.white70, size: 18),
                                        const SizedBox(width: 5),
                                        Text(
                                          "Quantity: ${doc['quantyty']} kg",
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, color: Colors.white70, size: 18),
                                        const SizedBox(width: 5),
                                        Text(
                                          "${doc['region']}, ${doc['distrname']}-${doc['mtaa']}",
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.phone, color: Colors.white70, size: 18),
                                        const SizedBox(width: 5),
                                        Text(
                                          doc['phone'],
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time, color: Colors.white70, size: 18),
                                        const SizedBox(width: 5),
                                        Text(
                                          dateTime.toString(),
                                          style: const TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.asset(
                                  'images/image3.jpeg',
                                  height: 180,
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Like, Comment, and Share Buttons
                              StreamBuilder<int>(
                                stream: getLikeCount(pstid),
                                builder: (context, likeCountSnapshot) {
                                  final likeCount = likeCountSnapshot.data ?? 0;
                                  return StreamBuilder<bool>(
                                    stream: isLikedByUser(pstid),
                                    builder: (context, isLikedSnapshot) {
                                      final isLiked = isLikedSnapshot.data ?? false;
                                      return StreamBuilder<int>(
                                        stream: getCommentCount(pstid),
                                        builder: (context, commentCountSnapshot) {
                                          final commentCount = commentCountSnapshot.data ?? 0;
                                          return Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton.icon(
                                                onPressed: () => toggleLike(pstid),
                                                icon: Icon(
                                                  isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                                                  color: Colors.white,
                                                ),
                                                label: Text(
                                                  '$likeCount Likes',
                                                  style: const TextStyle(color: Colors.white),
                                                ),
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.blue,
                                                ),
                                              ),
                                              InteractiveButton(
                                                icon: Icons.comment,
                                                label: 'Comments',
                                                count: commentCount,
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ChatScreen(pid: pstid, uid: uid),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 16),

                              // Delete Button
                              Center(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    deleteposts(pstid);
                                  },
                                  icon: const Icon(Icons.delete, color: Colors.white),
                                  label: const Text('Delete', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[700],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              margin: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Colors.blueGrey.shade900,
              ),
              height: MediaQuery.sizeOf(context).height * 0.25,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    'Nafaka nzuri kwa ajili ya lishe bora ya mama na mtoto! Ulipo tupo!!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      letterSpacing: 1.2,
                      height: 1.5,
                      shadows: [
                        Shadow(
                          offset: Offset(2.0, 2.0),
                          blurRadius: 4.0,
                          color: Color.fromARGB(150, 0, 0, 0),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InteractiveButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int? count;
  final VoidCallback onPressed;

  const InteractiveButton({
    super.key,
    required this.icon,
    required this.label,
    this.count,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade100,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.blueGrey.shade900),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: Colors.blueGrey.shade900,
              fontSize: 16,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 10),
            Text(
              count.toString(),
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}