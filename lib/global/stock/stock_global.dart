import 'package:first_flutter_project/pages/stockpage/stock_page.dart';

class StockGlobal {
  static List<Product> items = [];

  double get totalInventoryValue {
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  int get outOfStock {
    return items.where((item) => !item.inStock || item.quantity <= 0).length;
  }

  int get lowStock {
    return items.where((item) => item.quantity > 0 && item.quantity < 15).length;
  }

  int get totalItems {
    return items.length;
  }

  List<Product> get itemsList {
    return items;
  }
  void setGlobalItems () {
    GlobalItems().setList(items);
  }

  void setTotalInventoryValue() {
    TotalInventoryValue().setInventoryValue(totalInventoryValue);
  }

  void addItem(Product item) {
    items.add(item);
  }
}
