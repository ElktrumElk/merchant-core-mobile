import 'package:first_flutter_project/components/cart/cart_bottom_sheet.dart';
import 'package:first_flutter_project/global/market_cart.dart';
import 'package:first_flutter_project/network/market_service.dart';
import 'package:first_flutter_project/pages/market/billboard.dart';
import 'package:first_flutter_project/pages/market/market_product_card.dart';
import 'package:first_flutter_project/pages/market/service_card.dart';
import 'package:first_flutter_project/pages/market/services_more_screen.dart';
import 'package:first_flutter_project/pages/market/shop_card.dart';
import 'package:flutter/material.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final MarketService _marketService = MarketService();
  List<Map<String, dynamic>> _shops = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _adverts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMarketData();
  }

  Future<void> _fetchMarketData() async {
    try {
      final shops = await _marketService.getShops();
      final services = await _marketService.getServices(limit: 6);
      final products = await _marketService.getTopProducts(limit: 6);
      List<Map<String, dynamic>> adverts = [];
      try {
        adverts = await _marketService.getAdverts();
      } catch (_) {}

      if (mounted) {
        setState(() {
          _shops = shops;
          _services = services;
          _products = products;
          _adverts = adverts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: _buildCartFab(theme),
      body: RefreshIndicator(
        onRefresh: _fetchMarketData,
        child: ListView(
          children: [
            Billboard(ads: _adverts),

            _buildSectionHeader('Featured Shops', onSeeAll: () {}),
            _buildHorizontalList(
              height: 180,
              itemCount: _shops.length,
              itemBuilder: (context, index) => ShopCard(shop: _shops[index]),
            ),

            _buildSectionHeader(
              'Services',
              onSeeAll: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ServicesMoreScreen()),
                );
              },
            ),
            _buildHorizontalList(
              height: 150,
              itemCount: _services.isEmpty ? 0 : _services.length + 1,
              itemBuilder: (context, index) {
                if (index == _services.length) {
                  return _buildMoreCard();
                }
                return ServiceCard(service: _services[index]);
              },
            ),

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Top Products',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_products.isEmpty)
              const Center(child: Text('No products available'))
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    return MarketProductCard(product: _products[index]);
                  },
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildCartFab(ThemeData theme) {
    final cart = MarketCart();
    return ListenableBuilder(
      listenable: cart,
      builder: (context, _) {
        if (cart.isEmpty) return const SizedBox.shrink();
        return FloatingActionButton.extended(
          onPressed: () => CartBottomSheet.show(context),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: Badge(
            label: Text('${cart.totalItemCount}'),
            isLabelVisible: cart.totalItemCount > 0,
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          label: Text('SLE ${cart.subtotal.toStringAsFixed(2)}'),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          TextButton(onPressed: onSeeAll, child: const Text('View All')),
        ],
      ),
    );
  }

  Widget _buildHorizontalList({
    required double height,
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    if (_isLoading) {
      return SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }
    if (itemCount == 0) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No items found')),
      );
    }
    return SizedBox(
      height: height,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: itemCount,
        itemBuilder: itemBuilder,
      ),
    );
  }

  Widget _buildMoreCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ServicesMoreScreen()),
        );
      },
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.blue.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.withAlpha(50)),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, color: Colors.blue),
              SizedBox(height: 4),
              Text(
                'See More',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
