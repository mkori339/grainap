import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/app_support.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/market_post.dart';
import 'package:grainapp/post_widgets.dart';
import 'package:grainapp/product_catalog.dart';
import 'package:grainapp/viewpost.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({
    super.key,
    required this.district,
    required this.region,
  });

  final String district;
  final String region;

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  static const String _allProductsLabel = 'All';

  final ProductCatalogService _productCatalogService = ProductCatalogService();
  final TextEditingController _searchController = TextEditingController();
  String _search = '';
  String _selectedProduct = _allProductsLabel;
  String _typeFilter = 'all';

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  Stream<List<String>> _productStream() {
    return _productCatalogService.watchProductLabels(
      includeAllOption: true,
      allLabel: _allProductsLabel,
    );
  }

  Stream<List<MarketPost>> _postsStream() {
    return FirebaseFirestore.instance
        .collection('userpost')
        .where('region', isEqualTo: widget.region)
        .where('distrname', isEqualTo: widget.district)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      final posts = snapshot.docs.map(MarketPost.fromQueryDocument).toList()
        ..sort((MarketPost a, MarketPost b) =>
            b.createdAtMillis.compareTo(a.createdAtMillis));
      return posts;
    });
  }

  List<MarketPost> _filterPosts(List<MarketPost> posts) {
    return posts.where((MarketPost post) {
      final matchesSearch = _search.isEmpty ||
          post.title.toLowerCase().contains(_search.toLowerCase());
      final matchesProduct = _selectedProduct == _allProductsLabel ||
          post.title == _selectedProduct;
      final matchesType = _typeFilter == 'all' || post.postType == _typeFilter;
      return matchesSearch && matchesProduct && matchesType;
    }).toList();
  }

  void _applySearch() {
    setState(() {
      _search = _searchController.text.trim();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final palette = context.appPalette;

    return Scaffold(
      appBar: AppBar(
        title: MarketPageTitle(
          title: widget.district,
          subtitle: bi(
            'Matangazo ya soko la ${widget.region}',
            '${widget.region} market listings',
          ),
        ),
        actions: const <Widget>[ThemeModeButton()],
      ),
      body: MarketBackground(
        child: SafeArea(
          child: StreamBuilder<List<String>>(
            stream: _productStream(),
            builder: (BuildContext context,
                AsyncSnapshot<List<String>> productSnapshot) {
              final products =
                  productSnapshot.data ?? const <String>[_allProductsLabel];

              return StreamBuilder<List<MarketPost>>(
                stream: _postsStream(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<MarketPost>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      productSnapshot.connectionState ==
                          ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filteredPosts =
                      _filterPosts(snapshot.data ?? const <MarketPost>[]);

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: <Widget>[
                      const MarketPanel(
                        child: SectionHeader(
                          icon: Icons.store_mall_directory_outlined,
                          title: 'Soko la wilaya / District market',
                          subtitle:
                              'Chuja matangazo na wasiliana moja kwa moja / Filter posts and contact traders directly.',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        cursorColor: palette.accent,
                        style: TextStyle(color: onSurface),
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Tafuta bidhaa',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: IconButton(
                            onPressed: _applySearch,
                            icon: const Icon(Icons.arrow_forward_rounded),
                          ),
                        ),
                        onSubmitted: (_) => _applySearch(),
                      ),
                      const SizedBox(height: 16),
                      SegmentedButton<String>(
                        style: SegmentedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.04),
                          foregroundColor: Colors.white,
                          selectedBackgroundColor:
                              Colors.white.withValues(alpha: 0.12),
                        ),
                        segments: const <ButtonSegment<String>>[
                          ButtonSegment<String>(
                            value: 'all',
                            icon: Icon(Icons.apps_rounded),
                            label: Text('All'),
                          ),
                          ButtonSegment<String>(
                            value: 'sell',
                            icon: Icon(Icons.sell_outlined),
                            label: Text('Sell'),
                          ),
                          ButtonSegment<String>(
                            value: 'buy',
                            icon: Icon(Icons.shopping_bag_outlined),
                            label: Text('Buy'),
                          ),
                        ],
                        selected: <String>{_typeFilter},
                        onSelectionChanged: (Set<String> values) {
                          setState(() {
                            _typeFilter = values.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 54,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (BuildContext context, int index) {
                            final product = products[index];
                            final selected = product == _selectedProduct;
                            return ChoiceChip(
                              selected: selected,
                              label: Text(product),
                              avatar: Icon(
                                selected
                                    ? Icons.check_circle_rounded
                                    : Icons.grass_outlined,
                                size: 18,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  _selectedProduct = product;
                                });
                              },
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemCount: products.length,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (filteredPosts.isEmpty)
                        const EmptyStateCard(
                          icon: Icons.inbox_outlined,
                          title:
                              'Hakuna matangazo yanayofanana / No matching posts',
                          subtitle:
                              'Jaribu kichujio kingine au angalia wilaya jirani / Try another filter or check a nearby district.',
                        )
                      else
                        ...filteredPosts.map(
                          (MarketPost post) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: MarketPostCard(
                              post: post,
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
                            ),
                          ),
                        ),
                    ],
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
