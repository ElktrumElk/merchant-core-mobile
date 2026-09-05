import 'package:first_flutter_project/network/chat_service.dart';
import 'package:first_flutter_project/network/market_service.dart';
import 'package:first_flutter_project/pages/chat/chat_thread_screen.dart';
import 'package:first_flutter_project/pages/market/market_product_card.dart';
import 'package:first_flutter_project/pages/market/service_card.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class MarketShopScreen extends StatefulWidget {
  final String shopId;
  const MarketShopScreen({super.key, required this.shopId});

  @override
  State<MarketShopScreen> createState() => _MarketShopScreenState();
}

class _MarketShopScreenState extends State<MarketShopScreen> with SingleTickerProviderStateMixin {
  final MarketService _marketService = MarketService();
  final ChatService _chatService = ChatService();
  Map<String, dynamic>? _shop;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchShopData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchShopData() async {
    try {
      final data = await _marketService.getShop(widget.shopId);
      if (mounted) {
        setState(() {
          _shop = data;
          _products = List<Map<String, dynamic>>.from(data['products'] ?? []);
          _services = List<Map<String, dynamic>>.from(data['services'] ?? []);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _startChat() async {
    if (_shop == null) return;
    
    final shopId = _shop!['id'];
    final shopName = _shop!['shop_name'] ?? 'Shop';
    final ownerId = (_shop!['owner_id'] ?? _shop!['org_id'] ?? '').toString();
    final ownerKey = ownerId.startsWith('org:') ? ownerId : 'org:$ownerId';

    try {
      await _chatService.createThread(shopId, shopName, ownerKey);
      final threads = await _chatService.getThreads();
      final thread = threads.firstWhere((t) => t['shop_id'] == shopId);
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatThreadScreen(thread: thread)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start chat: $e')),
        );
      }
    }
  }

  void _shareShop() {
    if (_shop == null) return;
    final shopName = _shop!['shop_name'] ?? 'Shop';
    final shopUrl = 'https://merchantcore.netlify.app/market/${widget.shopId}';
    Share.share('Check out $shopName on Merchant Core: $shopUrl');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_shop == null) return const Scaffold(body: Center(child: Text('Shop not found')));

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240,
              pinned: true,
              leading: const BackButton(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      _shop!['background_image'] ?? 'https://via.placeholder.com/400x240',
                      fit: BoxFit.cover,
                    ),
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
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
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _startChat,
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
                    const SizedBox(height: 20),
                    Text(
                      _shop!['description'] ?? 'No description available.',
                      style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(200), height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: theme.colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: theme.colorScheme.primary,
                  tabs: const [
                    Tab(text: 'Products'),
                    Tab(text: 'Services'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductsGrid(),
            _buildServicesGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsGrid() {
    if (_products.isEmpty) {
      return const Center(child: Text('No shop products available'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) => MarketProductCard(product: _products[index]),
    );
  }

  Widget _buildServicesGrid() {
    if (_services.isEmpty) {
      return const Center(child: Text('No shop services available'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _services.length,
      itemBuilder: (context, index) => ServiceCard(service: _services[index]),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
