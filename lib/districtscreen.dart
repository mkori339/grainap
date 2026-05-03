import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grainapp/app_support.dart';
import 'package:grainapp/app_theme.dart';
import 'package:grainapp/market_data.dart';
import 'package:grainapp/market_post.dart';
import 'package:grainapp/post_widgets.dart';
import 'package:grainapp/spesificproduct.dart';

class DistrictScreen extends StatefulWidget {
  const DistrictScreen({
    super.key,
    required this.region,
    required this.regionid,
  });

  final String region;
  final int regionid;

  @override
  State<DistrictScreen> createState() => _DistrictScreenState();
}

class _DistrictScreenState extends State<DistrictScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  Stream<List<MarketPost>> _postsStream() {
    return FirebaseFirestore.instance
        .collection('userpost')
        .where('region', isEqualTo: widget.region)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      final posts = snapshot.docs.map(MarketPost.fromQueryDocument).toList()
        ..sort((MarketPost a, MarketPost b) =>
            b.createdAtMillis.compareTo(a.createdAtMillis));
      return posts;
    });
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

    return Scaffold(
      appBar: AppBar(
        title: MarketPageTitle(
          title: widget.region,
          subtitle: bi(
            'Chagua wilaya kuona matangazo ya karibu.',
            'Select a district to view active listings nearby.',
          ),
        ),
        actions: const <Widget>[ThemeModeButton()],
      ),
      body: MarketBackground(
        child: SafeArea(
          child: StreamBuilder<List<MarketPost>>(
            stream: _postsStream(),
            builder: (BuildContext context,
                AsyncSnapshot<List<MarketPost>> snapshot) {
              final districts = districtsForRegion(widget.region)
                  .where((String district) =>
                      district.toLowerCase().contains(_search.toLowerCase()))
                  .toList();

              final districtCounts = <String, int>{};
              for (final post in snapshot.data ?? const <MarketPost>[]) {
                final district = post.district.trim();
                if (district.isEmpty) {
                  continue;
                }
                districtCounts.update(
                  district,
                  (int value) => value + 1,
                  ifAbsent: () => 1,
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    const MarketPanel(
                      child: SectionHeader(
                        icon: Icons.location_city_rounded,
                        title: 'Wilaya / Districts',
                        subtitle:
                            'Chagua wilaya kuona matangazo ya karibu / Pick a district to explore nearby posts.',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _searchController,
                      cursorColor: Theme.of(context).colorScheme.primary,
                      style: TextStyle(color: onSurface),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: 'Tafuta wilaya',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: IconButton(
                          onPressed: _applySearch,
                          icon: const Icon(Icons.arrow_forward_rounded),
                        ),
                      ),
                      onSubmitted: (_) => _applySearch(),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: districts.isEmpty
                          ? const EmptyStateCard(
                              icon: Icons.location_off_outlined,
                              title: 'Wilaya haijapatikana / No district found',
                              subtitle:
                                  'Jaribu neno tofauti / Try a different search term.',
                            )
                          : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 280,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                                mainAxisExtent: 196,
                              ),
                              itemCount: districts.length,
                              itemBuilder: (BuildContext context, int index) {
                                final district = districts[index];
                                return _DistrictCard(
                                  district: district,
                                  postCount: districtCounts[district] ?? 0,
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => ProductScreen(
                                          district: district,
                                          region: widget.region,
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
            },
          ),
        ),
      ),
    );
  }
}

class _DistrictCard extends StatelessWidget {
  const _DistrictCard({
    required this.district,
    required this.postCount,
    required this.onTap,
  });

  final String district;
  final int postCount;
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: onSurface.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.08
                            : 0.05,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 24,
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
                district,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Open market',
                style: TextStyle(color: onSurface.withValues(alpha: 0.64)),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: onSurface.withValues(
                    alpha: Theme.of(context).brightness == Brightness.dark
                        ? 0.05
                        : 0.04,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: onSurface.withValues(alpha: 0.06)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.storefront_outlined,
                      size: 15,
                      color: palette.accentSoft,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$postCount posts',
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
