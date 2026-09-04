import 'package:first_flutter_project/network/market_service.dart';
import 'package:first_flutter_project/pages/market/market_shop_screen.dart';
import 'package:first_flutter_project/pages/pos/cart_panel.dart';
import 'package:first_flutter_project/pages/stockpage/stock_page.dart';
import 'package:flutter/material.dart';

class ProductInfoScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductInfoScreen({super.key, required this.product});

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  final MarketService _marketService = MarketService();
  late Map<String, dynamic> _product;
  bool _isLoading = false;
  double _userRating = 0;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final details = await _marketService.getProduct(_product['id']);
      if (mounted) {
        setState(() {
          _product = details;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _rateProduct(double rating) async {
    try {
      await _marketService.rateProduct(_product['id'], rating);
      _fetchDetails(); // Refresh to show new average
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanks for rating!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit rating')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final variants = _product['variants'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(_product['name'] ?? 'Product Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Header
            Hero(
              tag: 'prod_${_product['id']}',
              child: Image.network(
                _product['image_url'] ?? 'https://via.placeholder.com/400',
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 300,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.inventory, size: 100, color: Colors.grey),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _product['name'] ?? '',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'SLE ${_product['price']}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sold by: ${_product['shop_name'] ?? 'Official Store'}',
                    style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  
                  // Rating Display
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '${_product['rating'] ?? 0.0}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${_product['_rating_count'] ?? 0} reviews)',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),

                  const Divider(height: 40),

                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product['description'] ?? 'No description available for this product.',
                    style: TextStyle(color: Colors.grey.shade800, height: 1.5),
                  ),

                  if (variants.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Available Variants',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: variants.length,
                        itemBuilder: (context, index) {
                          final v = variants[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${v['size'] ?? ''} ${v['color'] ?? ''}'.trim(),
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],

                  const Divider(height: 60),

                  // Rating Panel
                  const Text(
                    'Rate this Product',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () => _rateProduct(index + 1.0),
                        icon: Icon(
                          index < (_product['rating'] ?? 0).floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 100), // Space for bottom buttons
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  if (_product['shop_id'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MarketShopScreen(shopId: _product['shop_id']),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.storefront),
                label: const Text('Visit Shop'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.black),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  // Re-use POS Product model if possible
                  final p = Product(
                    id: _product['id'],
                    name: _product['name'],
                    price: (_product['price'] as num).toDouble(),
                    quantity: 1,
                    inStock: true,
                  );
                  AddItemsToCart().addProduct(p);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to cart!')),
                  );
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Add to Cart'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
