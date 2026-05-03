import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/abautapp.dart';
import 'package:grainapp/app_support.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/authentificatin.dart';
import 'package:grainapp/districtscreen.dart';
import 'package:grainapp/market_data.dart';
import 'package:grainapp/market_post.dart';
import 'package:grainapp/mypost.dart';
import 'package:grainapp/post_widgets.dart';
import 'package:grainapp/posts.dart';
import 'package:grainapp/profile.dart';
import 'package:grainapp/product_catalog.dart';
import 'package:grainapp/signup_firebase.dart';
import 'package:grainapp/viewpost.dart';

enum _MenuAction { aboutApp, logout }

class RegionScreen extends StatefulWidget {
  const RegionScreen({super.key});

  @override
  State<RegionScreen> createState() => _RegionScreenState();
}

class _RegionScreenState extends State<RegionScreen> {
  static const String _allProductsLabel = 'All';

  final ProductCatalogService _productCatalogService = ProductCatalogService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _regionSearchController = TextEditingController();
  String _search = '';
  String _regionSearch = '';
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
    return FirebaseFirestore.instance.collection('userpost').snapshots().map(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        final posts = snapshot.docs.map(MarketPost.fromQueryDocument).toList()
          ..sort((MarketPost a, MarketPost b) =>
              b.createdAtMillis.compareTo(a.createdAtMillis));
        return posts;
      },
    );
  }

  List<MarketPost> _filterPosts(List<MarketPost> posts) {
    return posts.where((MarketPost post) {
      final search = _search.toLowerCase();
      final matchesSearch =
          search.isEmpty || post.title.toLowerCase().contains(search);
      final matchesProduct = _selectedProduct == _allProductsLabel ||
          post.title == _selectedProduct;
      final matchesType = _typeFilter == 'all' || post.postType == _typeFilter;
      return matchesSearch && matchesProduct && matchesType;
    }).toList();
  }

  void _applyMarketSearch() {
    setState(() {
      _search = _searchController.text.trim();
    });
  }

  void _applyRegionSearch() {
    setState(() {
      _regionSearch = _regionSearchController.text.trim();
    });
  }

  Future<void> _handleMenuAction(_MenuAction action) async {
    switch (action) {
      case _MenuAction.aboutApp:
        await Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const AboutAppPage()),
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
  void dispose() {
    _searchController.dispose();
    _regionSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const MarketPageTitle(
            title: 'Soko la Nafaka / Grain Market',
            subtitle:
                'Tazama matangazo, mikoa na wafanyabiashara / Browse listings, regions, and active traders.',
          ),
          actions: <Widget>[
            const ThemeModeButton(),
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
              itemBuilder: (BuildContext context) =>
                  const <PopupMenuEntry<_MenuAction>>[
                PopupMenuItem<_MenuAction>(
                  value: _MenuAction.aboutApp,
                  child: Text('About'),
                ),
                PopupMenuItem<_MenuAction>(
                  value: _MenuAction.logout,
                  child: Text('Toka'),
                ),
              ],
            ),
          ],
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(58),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TabBar(
                tabs: <Tab>[
                  Tab(
                    icon: Icon(Icons.travel_explore_rounded),
                    text: 'Market',
                  ),
                  Tab(icon: Icon(Icons.map_outlined), text: 'Mikoa'),
                ],
              ),
            ),
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
              builder: (BuildContext context,
                  AsyncSnapshot<List<String>> productSnapshot) {
                return StreamBuilder<List<MarketPost>>(
                  stream: _postsStream(),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<MarketPost>> postSnapshot) {
                    if (productSnapshot.connectionState ==
                            ConnectionState.waiting &&
                        postSnapshot.connectionState ==
                            ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final products = productSnapshot.data ??
                        const <String>[_allProductsLabel];
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
    final palette = context.appPalette;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final filteredPosts = _filterPosts(posts);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        const _RotatingHeroBanner(),
        const SizedBox(height: 16),
        MarketPanel(
          child: SectionHeader(
            icon: Icons.auto_awesome_rounded,
            title: 'Soko la moja kwa moja / Live market',
            subtitle:
                'Tumia vichujio kupata mfanyabiashara kwa haraka / Use filters to find the right trader quickly.',
            trailing: InfoPill(
              icon: Icons.storefront_outlined,
              label: '${filteredPosts.length} yanaonekana / visible',
              compact: true,
            ),
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
              onPressed: _applyMarketSearch,
              icon: const Icon(Icons.arrow_forward_rounded),
            ),
          ),
          onSubmitted: (_) => _applyMarketSearch(),
        ),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          style: SegmentedButton.styleFrom(
            backgroundColor: onSurface.withValues(
              alpha:
                  Theme.of(context).brightness == Brightness.dark ? 0.04 : 0.03,
            ),
            foregroundColor: onSurface,
            selectedBackgroundColor: palette.accent.withValues(alpha: 0.14),
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
                  product == _selectedProduct
                      ? Icons.check_circle_rounded
                      : Icons.grass_outlined,
                  size: 18,
                  color: onSurface,
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
            title: 'Hakuna matangazo / No posts found',
            subtitle:
                'Badili kichujio au tengeneza tangazo jipya / Change the filters or create a fresh listing.',
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
        .where((String region) =>
            region.toLowerCase().contains(_regionSearch.toLowerCase()))
        .toList();

    final regionCounts = <String, int>{};
    for (final post in posts) {
      regionCounts.update(post.region, (int value) => value + 1,
          ifAbsent: () => 1);
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: <Widget>[
          const MarketPanel(
            child: SectionHeader(
              icon: Icons.public_rounded,
              title: 'Mikoa / Regions',
              subtitle:
                  'Tazama wilaya zilizopo na wingi wa matangazo / Browse available districts and local post volume.',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _regionSearchController,
            cursorColor: Theme.of(context).colorScheme.primary,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Tafuta mkoa',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: IconButton(
                onPressed: _applyRegionSearch,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ),
            onSubmitted: (_) => _applyRegionSearch(),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: filteredRegions.isEmpty
                ? const EmptyStateCard(
                    icon: Icons.map_outlined,
                    title: 'Mkoa haujapatikana / No region found',
                    subtitle: 'Jaribu neno jingine / Try another search term.',
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 260,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 264,
                    ),
                    itemCount: filteredRegions.length,
                    itemBuilder: (BuildContext context, int index) {
                      final region = filteredRegions[index];
                      final count = regionCounts[region] ?? 0;
                      return _RegionCard(
                        region: region,
                        postCount: count,
                        districtCount: districtsForRegion(region).length,
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _RegionCard extends StatelessWidget {
  const _RegionCard({
    required this.region,
    required this.postCount,
    required this.districtCount,
    required this.onTap,
  });

  final String region;
  final int postCount;
  final int districtCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: MarketPanel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: onSurface.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.08
                            : 0.05,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.near_me_outlined,
                      size: 26,
                      color: palette.accentSoft,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_outward_rounded,
                    color: onSurface.withValues(alpha: 0.56),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                region,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                bi(
                  'Gusa kuona shughuli za biashara za wilaya.',
                  'Tap to explore district-level trading activity.',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.64),
                  height: 1.3,
                ),
              ),
              const Spacer(),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: <Widget>[
                  _RegionMetricChip(
                    icon: Icons.storefront_outlined,
                    label: '$postCount posts',
                  ),
                  _RegionMetricChip(
                    icon: Icons.location_city_outlined,
                    label: '$districtCount districts',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RegionMetricChip extends StatelessWidget {
  const _RegionMetricChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: onSurface.withValues(
          alpha: Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.04,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: onSurface.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 15, color: palette.accentSoft),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RotatingHeroBanner extends StatefulWidget {
  const _RotatingHeroBanner();

  @override
  State<_RotatingHeroBanner> createState() => _RotatingHeroBannerState();
}

class _RotatingHeroBannerState extends State<_RotatingHeroBanner> {
  static const List<String> _heroImages = <String>[
    'images/image2.jpeg',
    'images/image3.jpeg',
    'images/image7.jpeg',
  ];

  Timer? _timer;
  int _heroIndex = 0;
  bool _didPrecache = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didPrecache) {
      return;
    }
    _didPrecache = true;
    for (final image in _heroImages) {
      precacheImage(AssetImage(image), context);
    }
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
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
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.appPalette;
    const heroForeground = Colors.white;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 550),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: Container(
        key: ValueKey<int>(_heroIndex),
        height: 220,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          image: DecorationImage(
            image: AssetImage(_heroImages[_heroIndex]),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.34),
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
                Colors.black.withValues(alpha: 0.18),
                AppPalettes.dark.background.withValues(alpha: 0.9),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.bolt_rounded,
                      size: 16,
                      color: palette.highlight,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      bi(
                        'Mawasiliano ya haraka, hakuna chat ya ndani',
                        'Fast contact, no in-app chat',
                      ),
                      style: const TextStyle(color: heroForeground),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                bi(
                  'Matangazo ya kununua na kuuza yaliyoboreshwa.',
                  'Responsive listings built for buying and selling.',
                ),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                  color: heroForeground,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                bi(
                  'Fungua WhatsApp au piga simu moja kwa moja kutoka kwenye tangazo.',
                  'Open WhatsApp or place a call directly from every post card.',
                ),
                style: TextStyle(
                  color: heroForeground.withValues(alpha: 0.82),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
