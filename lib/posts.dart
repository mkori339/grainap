import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/post_widgets.dart';
import 'package:grainapp/market_post.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<List<MarketPost>> _postsStream() {
    return _firestore
        .collection('userpost')
        .where('usertable', isEqualTo: _uid)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      final posts = snapshot.docs.map(MarketPost.fromQueryDocument).toList()
        ..sort((MarketPost a, MarketPost b) => b.createdAtMillis.compareTo(a.createdAtMillis));
      return posts;
    });
  }

  Future<void> _deletePost(MarketPost post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete post'),
          content: Text('Remove "${post.title}" from your listings?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) {
      return;
    }

    await _firestore.collection('userpost').doc(post.id).delete();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post deleted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Posts')),
      body: MarketBackground(
        child: SafeArea(
          child: StreamBuilder<List<MarketPost>>(
            stream: _postsStream(),
            builder: (BuildContext context, AsyncSnapshot<List<MarketPost>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final posts = snapshot.data ?? const <MarketPost>[];
              if (posts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyStateCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'No posts yet',
                    subtitle: 'Your sell offers and buy requests will appear here after you publish them.',
                    action: FilledButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create one'),
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (BuildContext context, int index) {
                  final post = posts[index];
                  return MarketPostCard(
                    post: post,
                    showContactActions: false,
                    trailing: IconButton(
                      onPressed: () => _deletePost(post),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
