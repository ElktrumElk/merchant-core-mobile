import 'package:flutter/material.dart';
import 'package:first_flutter_project/network/product_service.dart';
import 'package:first_flutter_project/pages/stockpage/stock_page.dart';

class StockGlobal extends ChangeNotifier {
  static final StockGlobal _instance = StockGlobal._internal();
  factory StockGlobal() => _instance;
  StockGlobal._internal();

  static List<Product> items = [];
  final ProductService _productService = ProductService();

  double get totalInventoryValue {
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  int get outOfStock {
    return items.where((item) => !item.inStock || item.quantity <= 0).length;
  }

  int get lowStock {
    return items.where((item) => item.quantity > 0 && item.quantity < 10).length;
  }

  int get totalItems {
    return items.length;
  }

  static Future<void> loadItems() async {
    try {
      items = await ProductService().getProducts();
      StockGlobal().notifyListeners();
    } catch (e) {
      // Fallback to local storage if API fails or not logged in
      items = await GlobalItems().loadListFromStorage();
      StockGlobal().notifyListeners();
    }
  }

  static Future<void> saveItems() async {
    await GlobalItems().setList(items);
    StockGlobal().notifyListeners();
  }

  Future<void> syncWithBackend() async {
    try {
      items = await _productService.getProducts();
      await saveItems(); // Sync local cache
      notifyListeners();
    } catch (e) {
      debugPrint('Sync failed: $e');
    }
  }
}
