import 'package:first_flutter_project/global/market_cart.dart';
import 'package:first_flutter_project/network/market_service.dart';
import 'package:first_flutter_project/pages/market/market_orders_screen.dart';
import 'package:flutter/material.dart';

class CartBottomSheet extends StatefulWidget {
  const CartBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, _, _) => const CartBottomSheet(),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          );
        },
      ),
    );
  }

  @override
  State<CartBottomSheet> createState() => _CartBottomSheetState();
}

class _CartBottomSheetState extends State<CartBottomSheet> {
  final MarketCart _cart = MarketCart();
  final MarketService _marketService = MarketService();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();

  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _checkout() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _submitting = true);

    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final address = _addressCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    try {
      final groups = _cart.buildGroups(
        deliveryName: name,
        deliveryPhone: phone,
        deliveryAddress: address,
      );
      final result = await _marketService.placeOrders(groups);
      final alerts = (result['alerts'] as List? ?? [])
          .whereType<Map<dynamic, dynamic>>()
          .map((a) => Map<String, dynamic>.from(a))
          .toList();

      _cart.clear();
      if (!mounted) return;
      Navigator.pop(context);
      _showSuccess(alerts, email: email);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Checkout failed: $e')));
    }
  }

  void _showSuccess(List<Map<String, dynamic>> alerts, {String email = ''}) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return AlertDialog(
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(25),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 32,
            ),
          ),
          title: const Text('Order Placed'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your order has been sent to the store(s). The shop owners '
                  'have been alerted and will confirm your order soon.',
                ),
                if (alerts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Shop alerts',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  for (final alert in alerts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.storefront,
                            size: 18,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${alert['shop_name'] ?? 'Store'}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (alert['message'] != null)
                                  Text(
                                    '${alert['message']}',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                if (ctx.mounted) {
                  Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => const MarketOrdersScreen(),
                    ),
                  );
                }
              },
              child: const Text('View My Orders'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: _cart,
      builder: (context, _) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Close',
              onPressed: () => Navigator.pop(context),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                const Text(
                  'Your Cart',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${_cart.totalItemCount} item(s)',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              if (!_cart.isEmpty)
                TextButton(onPressed: _cart.clear, child: const Text('Clear')),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: _cart.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        children: [
                          ..._buildShopGroups(theme),
                          _buildDeliveryForm(theme),
                        ],
                      ),
              ),
              if (!_cart.isEmpty) _buildFooter(theme),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildShopGroups(ThemeData theme) {
    final byShop = <String, List<MarketCartItem>>{};
    for (final item in _cart.items) {
      byShop.putIfAbsent(item.shopId, () => []).add(item);
    }

    final widgets = <Widget>[];
    byShop.forEach((shopId, items) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: theme.colorScheme.primary.withAlpha(20),
                child: Icon(
                  Icons.storefront,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  items.first.shopName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${items.length} item(s)',
                style: TextStyle(
                  fontSize: 12.5,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
      for (final item in items) {
        widgets.add(_buildItemRow(theme, item));
      }
      widgets.add(const Divider(height: 24));
    });
    return widgets;
  }

  Widget _buildItemRow(ThemeData theme, MarketCartItem item) {
    final imageUrl = item.imageUrl ?? '';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _imageFallback(theme),
                    )
                  : _imageFallback(theme),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'SLE ${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _qtyButton(
                theme,
                icon: Icons.remove,
                onTap: () => _cart.updateQuantity(item, -1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              _qtyButton(
                theme,
                icon: Icons.add,
                onTap: () => _cart.updateQuantity(item, 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _qtyButton(
    ThemeData theme, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: theme.colorScheme.onSurface),
      ),
    );
  }

  Widget _imageFallback(ThemeData theme) {
    return Container(
      color: theme.dividerColor.withAlpha(80),
      child: Icon(
        Icons.image_outlined,
        color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
      ),
    );
  }

  Widget _buildDeliveryForm(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor.withAlpha(120),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Delivery Details',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              scrollPadding: const EdgeInsets.all(24),
              decoration: _inputDecoration(
                theme,
                'Full name',
                Icons.person_outline,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter your full name'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              scrollPadding: const EdgeInsets.all(24),
              decoration: _inputDecoration(
                theme,
                'Phone number',
                Icons.phone_outlined,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter your phone number'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _addressCtrl,
              textCapitalization: TextCapitalization.sentences,
              scrollPadding: const EdgeInsets.all(24),
              decoration: _inputDecoration(
                theme,
                'Delivery address',
                Icons.home_outlined,
              ),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Enter your delivery address'
                  : null,
              onFieldSubmitted: (_) => _checkout(),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              scrollPadding: const EdgeInsets.all(24),
              decoration: _inputDecoration(
                theme,
                'Email (optional)',
                Icons.email_outlined,
              ),
              validator: (v) {
                final value = v?.trim() ?? '';
                if (value.isEmpty) return null;
                final pattern = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                return pattern.hasMatch(value)
                    ? null
                    : 'Enter a valid email address';
              },
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    ThemeData theme,
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20),
      isDense: true,
      filled: true,
      fillColor: theme.cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.dividerColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.4),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    final subtotal = _cart.subtotal;
    final tax = subtotal * MarketCart.defaultTaxRate;
    final total = subtotal + tax;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal (${_cart.shopCount} shop${_cart.shopCount == 1 ? '' : 's'})',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                Text(
                  'SLE ${subtotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tax (5%)',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
                Text(
                  'SLE ${tax.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  'SLE ${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _submitting ? null : _checkout,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.lock_outline, size: 18),
                label: Text(
                  _submitting
                      ? 'Placing Order...'
                      : 'Place Order — SLE ${total.toStringAsFixed(2)}',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 15),
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

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withAlpha(120),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Browse the market and add items to get started',
            style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
