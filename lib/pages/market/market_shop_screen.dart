import 'package:first_flutter_project/network/market_service.dart';
import 'package:first_flutter_project/pages/market/market_product_card.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class MarketShopScreen extends StatefulWidget {
  final String shopId;
  const MarketShopScreen({super.key, required this.shopId});

  @override
  State<MarketShopScreen> createState() => _MarketShopScreenState();
}

class _MarketShopScreenState extends State<MarketShopScreen> {
  final MarketService _marketService = MarketService();
  Map<String, dynamic>? _shop;
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchShopData();
  }

  Future<void> _fetchShopData() async {
    try {
      final data = await _marketService.getShop(widget.shopId);
      if (mounted) {
        setState(() {
          _shop = data;
          _products = List<Map<String, dynamic>>.from(data['products'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _shareShop() {
    if (_shop == null) return;
    final shopName = _shop!['shop_name'] ?? 'Shop';
    final shopUrl = 'https://merchantcore.netlify.app/shop/${widget.shopId}';
    Share.share('Check out $shopName on Merchant Core: $shopUrl');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_shop == null) return const Scaffold(body: Center(child: Text('Shop not found')));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            leading: const BackButton(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Image.network(
                    _shop!['background_image'] ?? 'https://via.placeholder.com/400x240',
                    fit: BoxFit.cover,
                  ),
                  // Smoke Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withAlpha(50),
                          theme.scaffoldBackgroundColor.withAlpha(255),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                  ),
                  // Profile Image overlapping
                  Positioned(
                    bottom: 0,
                    left: 20,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withAlpha(50), blurRadius: 10)
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(_shop!['profile_image'] ?? ''),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _shop!['shop_name'] ?? '',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber, size: 18),
                              Text(
                                ' ${_shop!['rating'] ?? 0.0}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              if (_shop!['verified'] == true) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.verified, color: Colors.blue, size: 18),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Message and Share Buttons
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            // Messaging logic placeholder
                          },
                          icon: const Icon(Icons.message_outlined),
                          label: const Text('Message'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filled(
                        onPressed: _shareShop,
                        icon: const Icon(Icons.share_outlined),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.dividerColor.withAlpha(100),
                          foregroundColor: theme.colorScheme.onSurface,
                          padding: const EdgeInsets.all(12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _shop!['description'] ?? 'No description available.',
                    style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(200), height: 1.5),
                  ),
                  const Divider(height: 48),
                  const Text(
                    'Products',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => MarketProductCard(product: _products[index]),
                childCount: _products.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}
