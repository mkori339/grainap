import 'package:flutter/material.dart';
import 'package:grainapp/market_data.dart';
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
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final districts = districtsForRegion(widget.region)
        .where((String district) => district.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.region)),
      body: MarketBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                const MarketPanel(
                  child: SectionHeader(
                    icon: Icons.location_city_rounded,
                    title: 'Districts',
                    subtitle: 'Pick a district to explore nearby posts.',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search district',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _search = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: districts.isEmpty
                      ? const EmptyStateCard(
                          icon: Icons.location_off_outlined,
                          title: 'No district found',
                          subtitle: 'Try a different search term.',
                        )
                      : GridView.builder(
                          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 280,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.35,
                          ),
                          itemCount: districts.length,
                          itemBuilder: (BuildContext context, int index) {
                            final district = districts[index];
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(28),
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
                                child: MarketPanel(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 32,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        district,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'Open market',
                                        style: TextStyle(color: Colors.white.withOpacity(0.64)),
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
          ),
        ),
      ),
    );
  }
}
