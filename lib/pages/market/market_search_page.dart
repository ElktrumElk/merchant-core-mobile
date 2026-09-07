import 'package:first_flutter_project/network/market_service.dart';
import 'package:first_flutter_project/pages/market/market_product_card.dart';
import 'package:first_flutter_project/pages/market/service_card.dart';
import 'package:flutter/material.dart';

class MarketSearchPage extends StatefulWidget {
  const MarketSearchPage({super.key});

  @override
  State<MarketSearchPage> createState() => _MarketSearchPageState();
}

class _MarketSearchPageState extends State<MarketSearchPage> {
  final MarketService _marketService = MarketService();
  final TextEditingController _searchCtrl = TextEditingController();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _services = [];
  bool _isSearching = false;

  void _onSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _products = [];
        _services = [];
      });
      return;
    }

    setState(() => _isSearching = true);
    try {
      final results = await _marketService.searchMarket(query);
      if (mounted) {
        setState(() {
          _products = results['products'] ?? [];
          _services = results['services'] ?? [];
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 52,
        titleSpacing: 8,
        title: TextField(
          controller: _searchCtrl,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search products or services...',
            hintStyle: const TextStyle(fontSize: 14),
            prefixIcon: const Icon(Icons.search, size: 20),
            suffixIcon: IconButton(
              icon: const Icon(Icons.close, size: 20),
              tooltip: 'Close',
              onPressed: () => Navigator.pop(context),
            ),
            suffixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
            isDense: true,
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: _onSearch,
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty && _services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: theme.dividerColor),
                      const SizedBox(height: 16),
                      const Text('Type to search the market'),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (_services.isNotEmpty) ...[
                      const Text('Services', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _services.length,
                          itemBuilder: (context, index) => ServiceCard(service: _services[index]),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    if (_products.isNotEmpty) ...[
                      const Text('Products', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 12),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (context, index) => MarketProductCard(product: _products[index]),
                      ),
                    ],
                  ],
                ),
    );
  }
}
