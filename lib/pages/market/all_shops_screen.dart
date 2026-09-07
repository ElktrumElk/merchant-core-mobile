import 'package:first_flutter_project/network/market_service.dart';
import 'package:first_flutter_project/pages/market/shop_card.dart';
import 'package:first_flutter_project/pages/market/shop_grid_card.dart';
import 'package:flutter/material.dart';

class AllShopsScreen extends StatefulWidget {
  const AllShopsScreen({super.key});

  @override
  State<AllShopsScreen> createState() => _AllShopsScreenState();
}

class _AllShopsScreenState extends State<AllShopsScreen> {
  final MarketService _marketService = MarketService();
  final List<Map<String, dynamic>> _shops = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    try {
      final items = await _marketService.getShops(page: _page, limit: 20);
      if (mounted) {
        setState(() {
          _shops.addAll(items);
          _isLoading = false;
          _isLoadingMore = false;
          if (items.length < 20) _hasMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _loadMore() {
    if (_isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
      _page++;
    });
    _fetchShops();
  }

  List<Map<String, dynamic>> get _verifiedShops =>
      _shops.where((s) => s['verified'] == true).toList();

  List<Map<String, dynamic>> get _topRatedShops {
    final list = _shops
        .where((s) => s['verified'] != true)
        .toList()
      ..sort((a, b) => (b['rating'] ?? 0.0).compareTo(a['rating'] ?? 0.0));
    return list.take(10).toList();
  }

  List<Map<String, dynamic>> get _featuredShops =>
      _shops.where((s) => s['featured'] == true).toList();

  List<Map<String, dynamic>> get _restShops {
    final shown = <String>{
      for (final s in [..._verifiedShops, ..._topRatedShops, ..._featuredShops])
        s['id'].toString(),
    };
    return _shops.where((s) => !shown.contains(s['id'].toString())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Shops'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _shops.isEmpty
              ? const Center(child: Text('No shops found'))
              : ListView(
                  padding: const EdgeInsets.only(bottom: 32),
                  children: [
                    if (_verifiedShops.isNotEmpty) ...[
                      _buildSectionTitle('Verified Shops'),
                      _buildShopsRow(_verifiedShops),
                    ],
                    if (_topRatedShops.isNotEmpty) ...[
                      _buildSectionTitle('Top Rated'),
                      _buildShopsRow(_topRatedShops),
                    ],
                    if (_featuredShops.isNotEmpty) ...[
                      _buildSectionTitle('Featured Shops'),
                      _buildShopsRow(_featuredShops),
                    ],
                    if (_restShops.isNotEmpty) ...[
                      _buildSectionTitle('All Shops'),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                          itemCount: _restShops.length,
                          itemBuilder: (context, index) {
                            return ShopGridCard(shop: _restShops[index]);
                          },
                        ),
                      ),
                    ],
                    if (_hasMore)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: _isLoadingMore
                            ? const Center(child: CircularProgressIndicator())
                            : Center(
                                child: OutlinedButton(
                                  onPressed: _loadMore,
                                  child: const Text('Load More'),
                                ),
                              ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildShopsRow(List<Map<String, dynamic>> shops) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: shops.length,
        itemBuilder: (context, index) => ShopCard(shop: shops[index]),
      ),
    );
  }
}