import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/abautapp.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/authentificatin.dart';
import 'package:grainapp/developer.dart';
import 'package:grainapp/districtscreen.dart';
import 'package:grainapp/market_data.dart';
import 'package:grainapp/market_post.dart';
import 'package:grainapp/mypost.dart';
import 'package:grainapp/post_widgets.dart';
import 'package:grainapp/posts.dart';
import 'package:grainapp/profile.dart';
import 'package:grainapp/signupFirebase.dart';
import 'package:grainapp/viewpost.dart';

enum _MenuAction { aboutApp, developer, logout }

class RegionScreen extends StatefulWidget {
  const RegionScreen({super.key});

  @override
  State<RegionScreen> createState() => _RegionScreenState();
}

class _RegionScreenState extends State<RegionScreen> {
  static const List<String> _heroImages = <String>[
    'images/image1.webp',
    'images/image2.jpeg',
    'images/image3.jpeg',
    'images/image4.jpeg',
    'images/image5.jpeg',
    'images/image6.jpeg',
    'images/image7.jpeg',
  ];

  Timer? _heroTimer;
  int _heroIndex = 0;
  String _search = '';
  String _regionSearch = '';
  String _selectedProduct = 'All';
  String _typeFilter = 'all';

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _heroTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _heroIndex = (_heroIndex + 1) % _heroImages.length;
      });
    });
  }

  @override
  void dispose() {
    _heroTimer?.cancel();
    super.dispose();
  }

  Stream<List<String>> _productStream() {
    return FirebaseFirestore.instance.collection('product').snapshots().map((snapshot) {
      final products = <String>{'All'};
      for (final doc in snapshot.docs) {
        for (final value in doc.data().values) {
          final product = value.toString().trim();
          if (product.isNotEmpty) {
            products.add(product);
          }
        }
      }
      final rest = products.where((String item) => item != 'All').toList()..sort();
      return <String>['All', ...rest];
    });
  }

  Stream<List<MarketPost>> _postsStream() {
    return FirebaseFirestore.instance.collection('userpost').snapshots().map(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        final posts = snapshot.docs.map(MarketPost.fromQueryDocument).toList()
          ..sort((MarketPost a, MarketPost b) => b.createdAtMillis.compareTo(a.createdAtMillis));
        return posts;
      },
    );
  }

  List<MarketPost> _filterPosts(List<MarketPost> posts) {
    return posts.where((MarketPost post) {
      final search = _search.toLowerCase();
      final matchesSearch = search.isEmpty ||
          post.title.toLowerCase().contains(search) ||
          post.username.toLowerCase().contains(search) ||
          post.region.toLowerCase().contains(search) ||
          post.district.toLowerCase().contains(search);
      final matchesProduct = _selectedProduct == 'All' || post.title == _selectedProduct;
      final matchesType = _typeFilter == 'all' || post.postType == _typeFilter;
      return matchesSearch && matchesProduct && matchesType;
    }).toList();
  }

  Future<void> _handleMenuAction(_MenuAction action) async {
    switch (action) {
      case _MenuAction.aboutApp:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AboutAppPage()),
        );
        break;
      case _MenuAction.developer:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const DeveloperProfilePage()),
        );
        break;
      case _MenuAction.logout:
        await signOut();
        if (!mounted) {
          return;
        }
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Grain Market',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              Text(
                'Buy fast. Sell faster.',
                style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.68)),
              ),
            ],
          ),
          actions: <Widget>[
            IconButton(
              tooltip: 'My posts',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const ProductCard()),
                );
              },
              icon: const Icon(Icons.inventory_2_outlined),
            ),
            IconButton(
              tooltip: 'Create post',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const MyPost()),
                );
              },
              icon: const Icon(Icons.add_circle_outline_rounded),
            ),
            IconButton(
              tooltip: 'Profile',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const Profile()),
                );
              },
              icon: const Icon(Icons.person_outline_rounded),
            ),
            PopupMenuButton<_MenuAction>(
              onSelected: _handleMenuAction,
              itemBuilder: (BuildContext context) => const <PopupMenuEntry<_MenuAction>>[
                PopupMenuItem<_MenuAction>(
                  value: _MenuAction.aboutApp,
                  child: Text('About app'),
                ),
                PopupMenuItem<_MenuAction>(
                  value: _MenuAction.developer,
                  child: Text('Developer'),
                ),
                PopupMenuItem<_MenuAction>(
                  value: _MenuAction.logout,
                  child: Text('Logout'),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            tabs: <Tab>[
              Tab(icon: Icon(Icons.travel_explore_rounded), text: 'Market'),
              Tab(icon: Icon(Icons.map_outlined), text: 'Regions'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MyPost()),
            );
          },
          icon: const Icon(Icons.add_business_outlined),
          label: const Text('Post'),
        ),
        body: MarketBackground(
          child: SafeArea(
            child: StreamBuilder<List<String>>(
              stream: _productStream(),
              builder: (BuildContext context, AsyncSnapshot<List<String>> productSnapshot) {
                return StreamBuilder<List<MarketPost>>(
                  stream: _postsStream(),
                  builder: (BuildContext context, AsyncSnapshot<List<MarketPost>> postSnapshot) {
                    if (productSnapshot.connectionState == ConnectionState.waiting &&
                        postSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final products = productSnapshot.data ?? const <String>['All'];
                    final posts = postSnapshot.data ?? const <MarketPost>[];

                    return TabBarView(
                      children: <Widget>[
                        _buildMarketTab(products, posts),
                        _buildRegionsTab(posts),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMarketTab(List<String> products, List<MarketPost> posts) {
    final filteredPosts = _filterPosts(posts);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _buildHero(),
        const SizedBox(height: 16),
        const MarketPanel(
          child: SectionHeader(
            icon: Icons.auto_awesome_rounded,
            title: 'Live market',
            subtitle: 'Use icons and filters to find the right trader quickly.',
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search product, trader, region, district',
            prefixIcon: Icon(Icons.search_rounded),
          ),
          onChanged: (String value) {
            setState(() {
              _search = value;
            });
          },
        ),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          style: SegmentedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.04),
            foregroundColor: Colors.white,
            selectedBackgroundColor: AppColors.accent.withOpacity(0.14),
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
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (BuildContext context, int index) {
              final product = products[index];
              return ChoiceChip(
                selected: product == _selectedProduct,
                label: Text(product),
                avatar: Icon(
                  product == _selectedProduct ? Icons.check_circle_rounded : Icons.grass_outlined,
                  size: 18,
                  color: Colors.white,
                ),
                onSelected: (_) {
                  setState(() {
                    _selectedProduct = product;
                  });
                },
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        if (filteredPosts.isEmpty)
          const EmptyStateCard(
            icon: Icons.inbox_outlined,
            title: 'No posts found',
            subtitle: 'Change the filters or create a fresh listing.',
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
  }

  Widget _buildRegionsTab(List<MarketPost> posts) {
    final filteredRegions = marketRegions
        .where((String region) => region.toLowerCase().contains(_regionSearch.toLowerCase()))
        .toList();

    final regionCounts = <String, int>{};
    for (final post in posts) {
      regionCounts.update(post.region, (int value) => value + 1, ifAbsent: () => 1);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          const MarketPanel(
            child: SectionHeader(
              icon: Icons.public_rounded,
              title: 'Regions',
              subtitle: 'Browse available districts and local post volume.',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              hintText: 'Search region',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (String value) {
              setState(() {
                _regionSearch = value;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredRegions.isEmpty
                ? const EmptyStateCard(
                    icon: Icons.map_outlined,
                    title: 'No region found',
                    subtitle: 'Try another search term.',
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 260,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: filteredRegions.length,
                    itemBuilder: (BuildContext context, int index) {
                      final region = filteredRegions[index];
                      final count = regionCounts[region] ?? 0;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(28),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => DistrictScreen(
                                  region: region,
                                  regionid: marketRegions.indexOf(region),
                                ),
                              ),
                            );
                          },
                          child: MarketPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                const Icon(Icons.near_me_outlined, size: 30, color: Colors.white),
                                Text(
                                  region,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 10,
                                  children: <Widget>[
                                    InfoPill(icon: Icons.storefront_outlined, label: '$count posts', compact: true),
                                    InfoPill(
                                      icon: Icons.location_city_outlined,
                                      label: '${districtsForRegion(region).length} districts',
                                      compact: true,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0.96, end: 1),
      curve: Curves.easeOutCubic,
      builder: (BuildContext context, double value, Widget? child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value.clamp(0, 1), child: child),
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: Container(
          key: ValueKey<int>(_heroIndex),
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            image: DecorationImage(
              image: AssetImage(_heroImages[_heroIndex]),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.34),
                BlendMode.darken,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                colors: <Color>[
                  Colors.black.withOpacity(0.16),
                  AppColors.background.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.bolt_rounded, size: 16, color: AppColors.highlight),
                      SizedBox(width: 8),
                      Text('Fast contact, no in-app chat'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Responsive listings built for buying and selling.',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, height: 1.1),
                ),
                const SizedBox(height: 8),
                Text(
                  'Open WhatsApp or place a call directly from every post card.',
                  style: TextStyle(color: Colors.white.withOpacity(0.78), height: 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
