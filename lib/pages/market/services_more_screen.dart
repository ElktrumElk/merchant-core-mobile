import 'package:first_flutter_project/network/market_service.dart';
import 'package:first_flutter_project/pages/market/service_card.dart';
import 'package:flutter/material.dart';

class ServicesMoreScreen extends StatefulWidget {
  const ServicesMoreScreen({super.key});

  @override
  State<ServicesMoreScreen> createState() => _ServicesMoreScreenState();
}

class _ServicesMoreScreenState extends State<ServicesMoreScreen> {
  final MarketService _marketService = MarketService();
  final List<Map<String, dynamic>> _services = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _page = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final items = await _marketService.getServices(page: _page, limit: 20);
      if (mounted) {
        setState(() {
          _services.addAll(items);
          _isLoading = false;
          _isLoadingMore = false;
          if (items.length < 20) {
            _hasMore = false;
          }
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
    _fetchServices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Services'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? const Center(child: Text('No services found'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _services.length,
                      itemBuilder: (context, index) {
                        return ServiceCard(service: _services[index]);
                      },
                    ),
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
}
