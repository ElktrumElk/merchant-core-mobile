import 'package:first_flutter_project/components/toast/toast.dart';
import 'package:first_flutter_project/global/market_cart.dart';
import 'package:first_flutter_project/network/chat_service.dart';
import 'package:first_flutter_project/network/market_service.dart';
import 'package:first_flutter_project/pages/chat/chat_thread_screen.dart';
import 'package:first_flutter_project/pages/market/market_shop_screen.dart';
import 'package:flutter/material.dart';

class ProductInfoScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  const ProductInfoScreen({super.key, required this.product});

  @override
  State<ProductInfoScreen> createState() => _ProductInfoScreenState();
}

class _ProductInfoScreenState extends State<ProductInfoScreen> {
  final MarketService _marketService = MarketService();
  final ChatService _chatService = ChatService();
  late Map<String, dynamic> _product;
  bool _isLoading = false;
  bool _isChatLoading = false;

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

  void _startChat() async {
    final shopId = _product['shop_id'];
    final shopName = _product['shop_name'] ?? 'Official Store';

    if (shopId == null) return;

    setState(() => _isChatLoading = true);

    try {
      // Fetch shop details to get the owner key
      final shop = await _marketService.getShop(shopId);
      final ownerId = (shop['owner_id'] ?? shop['org_id'] ?? '').toString();
      final ownerKey = ownerId.startsWith('org:') ? ownerId : 'org:$ownerId';
      final shopImage = (shop['profile_image'] ?? '').toString();

      await _chatService.createThread(
        shopId,
        shopName,
        ownerKey,
        shopImage: shopImage,
      );

      // Navigate to chat list or specific thread?
      // For simplicity, we navigate to the thread screen by finding the new thread
      final threads = await _chatService.getThreads();
      final thread = threads.firstWhere((t) => t['shop_id'] == shopId);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatThreadScreen(thread: thread)),
        ).then((_) {
          if (mounted) setState(() => _isChatLoading = false);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChatLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not start chat: $e')));
      }
    }
  }

  void _rateProduct(double rating) async {
    try {
      await _marketService.rateProduct(_product['id'], rating);
      _fetchDetails(); // Refresh to show new average and breakdown
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Thanks for rating!')));
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
    final breakdown = Map<String, dynamic>.from(
      _product['rating_breakdown'] ?? {},
    );
    final totalRatings = _product['_rating_count'] ?? 0;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            actions: [
              if (_product['in_stock'] == true)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: IconButton.filled(
                    onPressed: _isChatLoading ? null : _startChat,
                    icon: _isChatLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.message_outlined),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'prod_${_product['id']}',
                child: Image.network(
                  _product['image_url'] ?? 'https://via.placeholder.com/400',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(
                      Icons.inventory,
                      size: 100,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _product['name'] ?? '',
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            GestureDetector(
                              onTap: () {
                                if (_product['shop_id'] != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => MarketShopScreen(
                                        shopId: _product['shop_id'],
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'By ${_product['shop_name'] ?? 'Official Store'}',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            'SLE ${_product['price']}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ratings & Reviews',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Text(
                            '${_product['rating'] ?? 0.0}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.star, color: Colors.amber, size: 28),
                          Text(
                            '$totalRatings ratings',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: Column(
                          children: [5, 4, 3, 2, 1].map((star) {
                            final count = breakdown[star.toString()] ?? 0;
                            final progress = totalRatings > 0
                                ? count / totalRatings
                                : 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                children: [
                                  Text(
                                    '$star',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: LinearProgressIndicator(
                                      value: progress.toDouble(),
                                      backgroundColor: Colors.grey.shade200,
                                      color: Colors.amber,
                                      minHeight: 8,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 48),
                  const Text(
                    'Product Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _product['description'] ??
                        'No description available for this product.',
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      height: 1.6,
                      fontSize: 15,
                    ),
                  ),
                  if (variants.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    const Text(
                      'Available Variants',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 45,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: variants.length,
                        itemBuilder: (context, index) {
                          final v = variants[index];
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Center(
                              child: Text(
                                '${v['size'] ?? ''} ${v['color'] ?? ''}'.trim(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const Divider(height: 64),
                  const Center(
                    child: Text(
                      'How would you rate this product?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () => _rateProduct(index + 1.0),
                        iconSize: 40,
                        icon: Icon(
                          index < (_product['rating'] ?? 0).floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border(top: BorderSide(color: theme.dividerColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
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
                        builder: (_) =>
                            MarketShopScreen(shopId: _product['shop_id']),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.storefront),
                label: const Flexible(
                  child: Text(
                    'Visit Shop',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  MarketCart().addItem(
                    MarketCartItem(
                      productId: _product['id'].toString(),
                      sourceId: _product['source_id']?.toString(),
                      name: _product['name'] ?? 'Product',
                      price: (_product['price'] as num?)?.toDouble() ?? 0,
                      imageUrl: _product['image_url']?.toString(),
                      shopId: _product['shop_id']?.toString() ?? '',
                      shopName: _product['shop_name']?.toString() ?? 'Shop',
                    ),
                  );
                  AppToast.show(context, message: 'Added to cart!');
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Flexible(
                  child: Text(
                    'Add to Cart',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                  backgroundColor: theme.colorScheme.onSurface,
                  foregroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
