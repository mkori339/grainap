import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/app_support.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/mypost.dart';
import 'package:grainapp/post_widgets.dart';
import 'package:grainapp/market_post.dart';
import 'package:grainapp/viewpost.dart';

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
        ..sort((MarketPost a, MarketPost b) =>
            b.createdAtMillis.compareTo(a.createdAtMillis));
      return posts;
    });
  }

  Future<void> _openEditor(MarketPost post) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MyPost(existingPost: post),
      ),
    );
  }

  Future<void> _deletePost(MarketPost post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete post'),
          content: Text(
            'Ondoa "${post.title}" kwenye matangazo yako?',
          ),
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
      const SnackBar(content: Text('Tangazo limefutwa.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MarketPageTitle(
          title: 'Matangazo Yangu / My Posts',
          subtitle:
              'Pitia, hariri au futa matangazo yako / Review, edit, or remove your active listings.',
        ),
        actions: const <Widget>[ThemeModeButton()],
      ),
      body: MarketBackground(
        child: SafeArea(
          child: StreamBuilder<List<MarketPost>>(
            stream: _postsStream(),
            builder: (BuildContext context,
                AsyncSnapshot<List<MarketPost>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final posts = snapshot.data ?? const <MarketPost>[];
              if (posts.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: EmptyStateCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Hakuna matangazo bado / No posts yet',
                    subtitle: bi(
                      'Matangazo yako ya kuuza na kununua yataonekana hapa ukishachapisha.',
                      'Your sell offers and buy requests will appear here after you publish them.',
                    ),
                    action: FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const MyPost(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('Create one'),
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length + 1,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    return MarketPanel(
                      child: SectionHeader(
                        icon: Icons.inventory_2_outlined,
                        title: 'Matangazo yako hai / Your live listings',
                        subtitle:
                            'Fungua tangazo kuona maelezo au lisimamie hapa / Open any post to review the full details, or manage it directly here.',
                        trailing: InfoPill(
                          icon: Icons.storefront_outlined,
                          label: '${posts.length} jumla / total',
                          compact: true,
                        ),
                      ),
                    );
                  }

                  final post = posts[index - 1];
                  return MarketPostCard(
                    post: post,
                    showContactActions: false,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ViewPost(
                            pid: post.id,
                            userId_: _uid,
                            postuid: post.ownerId,
                          ),
                        ),
                      );
                    },
                    footer: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        FilledButton.tonalIcon(
                          onPressed: () => _openEditor(post),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Edit'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _deletePost(post),
                          icon: const Icon(Icons.delete_outline_rounded),
                          label: const Text('Delete'),
                        ),
                      ],
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
