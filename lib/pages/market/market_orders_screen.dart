import 'dart:async';
import 'package:first_flutter_project/network/market_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MarketOrdersScreen extends StatefulWidget {
  const MarketOrdersScreen({super.key});

  @override
  State<MarketOrdersScreen> createState() => _MarketOrdersScreenState();
}

class _MarketOrdersScreenState extends State<MarketOrdersScreen> {
  final MarketService _marketService = MarketService();

  List<Map<String, dynamic>> _orders = [];
  final Map<String, String> _qrTokens = {};
  bool _isLoading = true;
  String? _error;

  Timer? _pollTimer;
  Map<String, String> _previousStatuses = {};

  @override
  void initState() {
    super.initState();
    _loadOrders();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _loadOrders(isBackground: true);
    });
  }

  Future<void> _loadOrders({bool isBackground = false}) async {
    try {
      final orders = await _marketService.fetchMyOrders();
      if (!mounted) return;

      if (!isBackground) {
        setState(() {
          _orders = orders;
          _isLoading = false;
          _error = null;
        });
      } else {
        _previousStatuses = _detectStatusChanges(orders);
        setState(() {
          _orders = orders;
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (!mounted) return;
      if (!isBackground) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  Map<String, String> _detectStatusChanges(List<Map<String, dynamic>> fresh) {
    final notifications = <String>[];
    for (final order in fresh) {
      final id = (order['id'] ?? '').toString();
      final status = (order['status'] ?? 'pending').toString();
      final previous = _previousStatuses[id];
      if (previous != null && previous != status) {
        if (status == 'completed' && previous == 'pending') {
          notifications.add('Order ${_shortId(id)} completed — thank you!');
        } else if (status == 'cancelled') {
          notifications.add('Order ${_shortId(id)} was cancelled');
        }
      }
    }
    if (notifications.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(notifications.join('\n')),
              behavior: SnackBarBehavior.floating,
            ),
          );
      });
    }
    return {
      for (final order in fresh)
        (order['id'] ?? '').toString(): (order['status'] ?? '').toString(),
    };
  }

  String _shortId(String id) {
    if (id.length <= 8) return id;
    return id.substring(0, 8).toUpperCase();
  }

  Future<void> _deleteOrder(Map<String, dynamic> order) async {
    final id = (order['id'] ?? '').toString();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete order'),
        content: Text('Delete order ${_shortId(id)}? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _marketService.deleteBuyerOrder(id);
      if (!mounted) return;
      setState(() {
        _orders.removeWhere((o) => (o['id'] ?? '').toString() == id);
        _previousStatuses.remove(id);
        _qrTokens.remove(id);
      });
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Order deleted')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Could not delete order')));
    }
  }

  Future<void> _revealQr(String orderId) async {
    if (_qrTokens[orderId] != null) {
      setState(
        () => _expandedOrderId = _expandedOrderId == orderId ? null : orderId,
      );
      return;
    }
    try {
      final token = await _marketService.getOrderQrToken(orderId);
      if (!mounted) return;
      setState(() {
        _qrTokens[orderId] = token;
        _expandedOrderId = orderId;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Could not load QR code')));
    }
  }

  String? _expandedOrderId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _isLoading ? null : () => _loadOrders(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_isLoading && _orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            const Text('Could not load your orders'),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadOrders();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: theme.colorScheme.primary.withAlpha(80),
            ),
            const SizedBox(height: 12),
            const Text('No orders yet'),
            const SizedBox(height: 4),
            Text(
              'Your market orders will appear here.',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => _loadOrders(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        itemCount: _orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildOrderCard(_orders[index], theme),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order, ThemeData theme) {
    final id = (order['id'] ?? '').toString();
    final status = (order['status'] ?? 'pending').toString();
    final createdAt = _formatDate(order['created_at']);
    final total = (order['total'] as num?)?.toDouble() ?? 0;
    final items = (order['items'] as List<dynamic>? ?? []);
    final deliveryName = (order['delivery_name'] ?? '').toString();
    final deliveryAddress = (order['delivery_address'] ?? '').toString();
    final deliveryPhone = (order['delivery_phone'] ?? '').toString();
    final paymentMethod = (order['payment_method'] ?? 'Cash').toString();

    final statusMeta = _statusMeta(status, theme);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${_shortId(id)}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        createdAt,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(meta: statusMeta),
                const SizedBox(width: 8),
                IconButton(
                  tooltip: 'Delete order',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _deleteOrder(order),
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item['name'] ?? 'Item'} ×${item['quantity'] ?? 1}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'SLE ${((item['price'] as num? ?? 0) * (item['quantity'] as num? ?? 1)).toStringAsFixed(2)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    '${items.length} item(s) · $paymentMethod',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'SLE ${total.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            if (deliveryName.isNotEmpty ||
                deliveryAddress.isNotEmpty ||
                deliveryPhone.isNotEmpty) ...[
              const Divider(height: 20),
              if (deliveryName.isNotEmpty)
                _deliveryLine(
                  theme,
                  Icons.person_outline,
                  'Deliver to: $deliveryName',
                ),
              if (deliveryAddress.isNotEmpty)
                _deliveryLine(
                  theme,
                  Icons.location_on_outlined,
                  deliveryAddress,
                ),
              if (deliveryPhone.isNotEmpty)
                _deliveryLine(theme, Icons.phone_outlined, deliveryPhone),
            ],
            if (status == 'pending') ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _revealQr(id),
                  icon: const Icon(Icons.qr_code_2, size: 18),
                  label: Text(
                    _expandedOrderId == id ? 'Hide QR code' : 'Show QR code',
                  ),
                ),
              ),
              if (_expandedOrderId == id) ...[
                const SizedBox(height: 12),
                _buildQrSection(id, order, theme),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _deliveryLine(ThemeData theme, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrSection(
    String orderId,
    Map<String, dynamic> order,
    ThemeData theme,
  ) {
    final token = _qrTokens[orderId];
    final code = token ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        children: [
          if (code.isNotEmpty)
            QrImageView(
              data: code,
              version: QrVersions.auto,
              size: 170,
              backgroundColor: Colors.white,
              padding: EdgeInsets.zero,
            )
          else
            const SizedBox(
              height: 170,
              child: Center(child: CircularProgressIndicator()),
            ),
          const SizedBox(height: 10),
          Text(
            'Show this code to the shop to complete your order.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (code.isNotEmpty) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(content: Text('Order code copied')),
                  );
              },
              icon: const Icon(Icons.copy, size: 16),
              label: const Text('Copy code'),
            ),
          ],
        ],
      ),
    );
  }

  ({String label, Color color, Color bg, IconData icon}) _statusMeta(
    String status,
    ThemeData theme,
  ) {
    switch (status) {
      case 'completed':
        return (
          label: 'Completed',
          color: const Color(0xFF16A34A),
          bg: const Color(0xFF16A34A).withAlpha(16),
          icon: Icons.check_circle_outline,
        );
      case 'cancelled':
        return (
          label: 'Cancelled',
          color: const Color(0xFFDC2626),
          bg: const Color(0xFFDC2626).withAlpha(16),
          icon: Icons.cancel_outlined,
        );
      default:
        return (
          label: 'Pending',
          color: const Color(0xFFB45309),
          bg: const Color(0xFFB45309).withAlpha(16),
          icon: Icons.schedule,
        );
    }
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return raw.toString();
    return DateFormat('MMM d, h:mm a').format(parsed.toLocal());
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.meta});

  final ({String label, Color color, Color bg, IconData icon}) meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: meta.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(meta.icon, size: 13, color: meta.color),
          const SizedBox(width: 4),
          Text(
            meta.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: meta.color,
            ),
          ),
        ],
      ),
    );
  }
}
