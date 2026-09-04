import 'package:first_flutter_project/network/market_service.dart';
import 'package:first_flutter_project/pages/market/market_shop_screen.dart';
import 'package:flutter/material.dart';

class ServiceInfoScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  const ServiceInfoScreen({super.key, required this.service});

  @override
  State<ServiceInfoScreen> createState() => _ServiceInfoScreenState();
}

class _ServiceInfoScreenState extends State<ServiceInfoScreen> {
  final MarketService _marketService = MarketService();
  late Map<String, dynamic> _service;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service;
  }

  void _rateService(double rating) async {
    try {
      // Backend already has PUT /market/services/{id}/rate
      // I should update MarketService to include rateService
      await _marketService.rateService(_service['id'], rating);
      _refresh();
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

  Future<void> _refresh() async {
    // Ideally we fetch one service
    // For now we just use the passed data
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(_service['name'] ?? 'Service Details')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              _service['image_url'] ?? 'https://via.placeholder.com/400',
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
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
                          _service['name'] ?? '',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        'SLE ${_service['price']}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Provided by: ${_service['shop_name'] ?? 'Shop'}',
                    style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        '${_service['rating'] ?? 0.0}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 40),
                  const Text('About this Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_service['description'] ?? 'No description provided.'),
                  const SizedBox(height: 32),
                  const Text('Rate this Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                   Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () => _rateService(index + 1.0),
                        icon: Icon(
                          index < (_service['rating'] ?? 0).floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
             Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  if (_service['shop_id'] != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MarketShopScreen(shopId: _service['shop_id']),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.storefront),
                label: const Text('Visit Shop'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 16),
             Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  // Request service logic
                },
                icon: const Icon(Icons.mail_outline),
                label: const Text('Request Service'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
