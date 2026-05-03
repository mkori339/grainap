import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/app_access.dart';
import 'package:grainapp/app_support.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/market_post.dart';
import 'package:grainapp/post_widgets.dart';
import 'package:grainapp/product_catalog.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ProductCatalogService _catalogService = ProductCatalogService();

  String get _uid => _auth.currentUser?.uid ?? '';
  String get _email => _auth.currentUser?.email ?? '';

  Future<void> _showAddProductDialog() async {
    final nameController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Add product'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Jina la bidhaa',
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Weka jina la bidhaa.'),
                    ),
                  );
                  return;
                }

                Navigator.of(dialogContext).pop();
                await _catalogService.addProduct(
                  nameSw: name,
                  nameEn: name,
                  categorySw: '',
                  categoryEn: '',
                );
                if (!mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bidhaa imeongezwa: $name'),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteProduct(ProductCatalogEntry entry) async {
    await _catalogService.deleteProduct(entry.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bidhaa imefutwa: ${entry.label}'),
      ),
    );
  }

  Future<void> _setUserRole(String uid, String role) async {
    await _firestore.collection('users').doc(uid).set(
      <String, dynamic>{'role': role},
      SetOptions(merge: true),
    );
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          role == 'admin'
              ? 'Mtumiaji amewekwa admin.'
              : 'Mtumiaji amewekwa user.',
        ),
      ),
    );
  }

  List<MapEntry<String, int>> _rankTexts(Iterable<String> items) {
    final counts = <String, int>{};
    for (final item in items) {
      final trimmed = item.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      counts.update(trimmed, (int value) => value + 1, ifAbsent: () => 1);
    }

    final ranked = counts.entries.toList()
      ..sort((MapEntry<String, int> a, MapEntry<String, int> b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) {
          return byCount;
        }
        return a.key.toLowerCase().compareTo(b.key.toLowerCase());
      });
    return ranked;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MarketPageTitle(
          title: 'Admin',
          subtitle: 'Takwimu, bidhaa na users',
        ),
        actions: const <Widget>[ThemeModeButton()],
      ),
      body: MarketBackground(
        child: SafeArea(
          child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _firestore.collection('users').doc(_uid).snapshots(),
            builder: (
              BuildContext context,
              AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>>
                  userSnapshot,
            ) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final currentUserData = userSnapshot.data?.data();
              if (!isAdminUser(currentUserData, _email)) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: EmptyStateCard(
                    icon: Icons.lock_outline_rounded,
                    title: 'Hakuna ruhusa',
                    subtitle: 'Skrini hii ni ya admin pekee.',
                  ),
                );
              }

              return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: _firestore.collection('users').snapshots(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                      usersSnapshot,
                ) {
                  return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: _firestore.collection('userpost').snapshots(),
                    builder: (
                      BuildContext context,
                      AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                          postsSnapshot,
                    ) {
                      return StreamBuilder<List<ProductCatalogEntry>>(
                        stream: _catalogService.watchProducts(),
                        builder: (
                          BuildContext context,
                          AsyncSnapshot<List<ProductCatalogEntry>>
                              productsSnapshot,
                        ) {
                          if (usersSnapshot.connectionState ==
                                  ConnectionState.waiting &&
                              postsSnapshot.connectionState ==
                                  ConnectionState.waiting &&
                              productsSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final userDocs = usersSnapshot.data?.docs ??
                              const <QueryDocumentSnapshot<
                                  Map<String, dynamic>>>[];
                          final posts = (postsSnapshot.data?.docs ??
                                  const <QueryDocumentSnapshot<
                                      Map<String, dynamic>>>[])
                              .map(MarketPost.fromQueryDocument)
                              .toList();
                          final products = productsSnapshot.data ??
                              const <ProductCatalogEntry>[];

                          final sellCount = posts
                              .where((MarketPost post) => !post.isBuy)
                              .length;
                          final buyCount = posts
                              .where((MarketPost post) => post.isBuy)
                              .length;
                          final pricedPosts = posts
                              .where((MarketPost post) => post.hasPrice)
                              .toList();
                          final averagePrice = pricedPosts.isEmpty
                              ? null
                              : pricedPosts
                                      .map(
                                          (MarketPost post) => post.pricePerKg!)
                                      .reduce((double a, double b) => a + b) /
                                  pricedPosts.length;
                          final adminCount = userDocs
                              .where(
                                (QueryDocumentSnapshot<Map<String, dynamic>>
                                        doc) =>
                                    isAdminUser(doc.data(),
                                        doc.data()['email']?.toString()),
                              )
                              .length;
                          final topProducts = _rankTexts(
                                  posts.map((MarketPost post) => post.title))
                              .take(5)
                              .toList();
                          final topRegions = _rankTexts(
                                  posts.map((MarketPost post) => post.region))
                              .take(5)
                              .toList();

                          return ListView(
                            padding: const EdgeInsets.all(16),
                            children: <Widget>[
                              const MarketPanel(
                                child: SectionHeader(
                                  icon: Icons.analytics_outlined,
                                  title: 'Muhtasari',
                                  subtitle: 'Angalia hali ya soko kwa haraka.',
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                children: <Widget>[
                                  _AdminStatCard(
                                    title: bi('Watumiaji', 'Users'),
                                    value: '${userDocs.length}',
                                  ),
                                  _AdminStatCard(
                                    title: bi('Admin', 'Admins'),
                                    value: '$adminCount',
                                  ),
                                  _AdminStatCard(
                                    title: bi('Matangazo', 'Posts'),
                                    value: '${posts.length}',
                                  ),
                                  _AdminStatCard(
                                    title: bi('Uza', 'Sell'),
                                    value: '$sellCount',
                                  ),
                                  _AdminStatCard(
                                    title: bi('Nunua', 'Buy'),
                                    value: '$buyCount',
                                  ),
                                  _AdminStatCard(
                                    title: bi('Bidhaa', 'Products'),
                                    value: '${products.length}',
                                  ),
                                  _AdminStatCard(
                                    title:
                                        bi('Bei ya wastani/kg', 'Avg price/kg'),
                                    value: averagePrice == null
                                        ? 'N/A'
                                        : formatTzsPerKg(averagePrice),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              MarketPanel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SectionHeader(
                                      icon: Icons.insights_outlined,
                                      title: 'Uchambuzi',
                                      subtitle:
                                          'Bidhaa na maeneo yanayoongoza.',
                                    ),
                                    const SizedBox(height: 18),
                                    Text(
                                      bi('Bidhaa zinazoongoza', 'Top products'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    if (topProducts.isEmpty)
                                      const Text(
                                        'Hakuna data bado.',
                                      )
                                    else
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: topProducts
                                            .map(
                                              (MapEntry<String, int> entry) =>
                                                  InfoPill(
                                                icon: Icons.grass_outlined,
                                                label:
                                                    '${entry.key} (${entry.value})',
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    const SizedBox(height: 18),
                                    Text(
                                      bi('Mikoa inayoongoza', 'Top regions'),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    if (topRegions.isEmpty)
                                      const Text(
                                        'Hakuna data bado.',
                                      )
                                    else
                                      Wrap(
                                        spacing: 10,
                                        runSpacing: 10,
                                        children: topRegions
                                            .map(
                                              (MapEntry<String, int> entry) =>
                                                  InfoPill(
                                                icon: Icons.public_rounded,
                                                label:
                                                    '${entry.key} (${entry.value})',
                                              ),
                                            )
                                            .toList(),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              MarketPanel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SectionHeader(
                                      icon: Icons.category_outlined,
                                      title: 'Products',
                                      subtitle: 'Ongeza au futa bidhaa.',
                                    ),
                                    const SizedBox(height: 18),
                                    Wrap(
                                      spacing: 12,
                                      runSpacing: 12,
                                      children: <Widget>[
                                        FilledButton.icon(
                                          onPressed: _showAddProductDialog,
                                          icon: const Icon(Icons.add_rounded),
                                          label: const Text('Add product'),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 18),
                                    if (products.isEmpty)
                                      const Text(
                                        'Hakuna bidhaa bado.',
                                      )
                                    else
                                      ...products.map(
                                        (ProductCatalogEntry entry) => ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(entry.label),
                                          subtitle: Text(
                                            entry.categorySw.isEmpty &&
                                                    entry.categoryEn.isEmpty
                                                ? bi('Bidhaa ya soko',
                                                    'Market product')
                                                : bi(
                                                    entry.categorySw,
                                                    entry.categoryEn,
                                                  ),
                                          ),
                                          trailing: IconButton(
                                            tooltip: 'Delete product',
                                            onPressed: () =>
                                                _deleteProduct(entry),
                                            icon: const Icon(
                                              Icons.delete_outline_rounded,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              MarketPanel(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SectionHeader(
                                      icon: Icons.manage_accounts_outlined,
                                      title: 'Users',
                                      subtitle: 'Badili role za user na admin.',
                                    ),
                                    const SizedBox(height: 18),
                                    if (userDocs.isEmpty)
                                      const Text(
                                        'Hakuna users bado.',
                                      )
                                    else
                                      ...userDocs.map(
                                        (QueryDocumentSnapshot<
                                                Map<String, dynamic>>
                                            doc) {
                                          final data = doc.data();
                                          final email =
                                              (data['email'] ?? '').toString();
                                          final role =
                                              resolveUserRole(data, email);
                                          final isCurrentUser = doc.id == _uid;
                                          final displayName =
                                              (data['name'] ?? 'U')
                                                  .toString()
                                                  .trim();
                                          final avatarLabel =
                                              displayName.isEmpty
                                                  ? 'U'
                                                  : displayName
                                                      .substring(0, 1)
                                                      .toUpperCase();

                                          return ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            leading: CircleAvatar(
                                              child: Text(avatarLabel),
                                            ),
                                            title: Text(
                                              (data['name'] ?? 'Trader')
                                                  .toString(),
                                            ),
                                            subtitle: Text(
                                              '$email • ${role == 'admin' ? 'Admin' : 'User'}',
                                            ),
                                            trailing: isCurrentUser
                                                ? const Text('You')
                                                : PopupMenuButton<String>(
                                                    onSelected: (String value) {
                                                      _setUserRole(
                                                          doc.id, value);
                                                    },
                                                    itemBuilder: (BuildContext
                                                            context) =>
                                                        const <PopupMenuEntry<
                                                            String>>[
                                                      PopupMenuItem<String>(
                                                        value: 'admin',
                                                        child:
                                                            Text('Make admin'),
                                                      ),
                                                      PopupMenuItem<String>(
                                                        value: 'user',
                                                        child:
                                                            Text('Make user'),
                                                      ),
                                                    ],
                                                  ),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
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

class _AdminStatCard extends StatelessWidget {
  const _AdminStatCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      child: MarketPanel(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(
                      alpha: 0.68,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
