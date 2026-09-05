import 'package:flutter/foundation.dart';

class MarketCartItem {
  final String productId;
  final String? sourceId;
  final String name;
  final double price;
  int quantity;
  final String? imageUrl;
  final String shopId;
  final String shopName;

  MarketCartItem({
    required this.productId,
    this.sourceId,
    required this.name,
    required this.price,
    this.quantity = 1,
    this.imageUrl,
    required this.shopId,
    required this.shopName,
  });

  double get lineTotal => price * quantity;

  Map<String, dynamic> toOrderItem() => {
    'product_id': productId,
    'source_id': sourceId ?? '',
    'name': name,
    'price': price,
    'quantity': quantity,
  };
}

class MarketCart extends ChangeNotifier {
  MarketCart._internal();
  static final MarketCart _instance = MarketCart._internal();
  factory MarketCart() => _instance;

  static const double defaultTaxRate = 0.05;

  final List<MarketCartItem> _items = [];

  List<MarketCartItem> get items => List.unmodifiable(_items);
  int get totalItemCount => _items.fold(0, (sum, i) => sum + i.quantity);
  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.lineTotal);
  int get shopCount => _shopIds.length;
  bool get isEmpty => _items.isEmpty;

  List<String> get _shopIds => _items.map((i) => i.shopId).toSet().toList();

  /// Adds an item, merging by product + shop when it already exists.
  void addItem(MarketCartItem item) {
    for (final existing in _items) {
      if (existing.productId == item.productId &&
          existing.shopId == item.shopId) {
        existing.quantity += item.quantity;
        notifyListeners();
        return;
      }
    }
    _items.add(item);
    notifyListeners();
  }

  /// Changes the quantity of [item] by [delta]; removes it when it reaches 0.
  void updateQuantity(MarketCartItem item, int delta) {
    item.quantity += delta;
    if (item.quantity <= 0) {
      _items.remove(item);
    }
    notifyListeners();
  }

  void removeItem(MarketCartItem item) {
    _items.remove(item);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Builds the per-shop groups the backend checkout endpoint expects.
  List<Map<String, dynamic>> buildGroups({
    required String deliveryName,
    required String deliveryPhone,
    required String deliveryAddress,
    String paymentMethod = 'Cash',
    double taxRate = defaultTaxRate,
  }) {
    final byShop = <String, List<MarketCartItem>>{};
    for (final item in _items) {
      byShop.putIfAbsent(item.shopId, () => []).add(item);
    }

    final groups = <Map<String, dynamic>>[];
    for (final shopId in byShop.keys) {
      final shopItems = byShop[shopId]!;
      final subtotal = shopItems.fold(0.0, (sum, i) => sum + i.lineTotal);
      final tax = subtotal * taxRate;
      groups.add({
        'shop_id': shopId,
        'items': shopItems.map((i) => i.toOrderItem()).toList(),
        'subtotal': _round(subtotal),
        'tax': _round(tax),
        'total': _round(subtotal + tax),
        'payment_method': paymentMethod,
        'delivery_name': deliveryName,
        'delivery_phone': deliveryPhone,
        'delivery_address': deliveryAddress,
      });
    }
    return groups;
  }

  static double _round(double value) => double.parse(value.toStringAsFixed(2));
}
