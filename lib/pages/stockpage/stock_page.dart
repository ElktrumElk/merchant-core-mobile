import 'dart:convert';

import 'package:first_flutter_project/components/greetingCard/greeting_card.dart';
import 'package:first_flutter_project/global/stock/stock_global.dart';
import 'package:first_flutter_project/module/storage/device_storage.dart';
import 'package:first_flutter_project/network/product_service.dart';
import 'package:first_flutter_project/pages/stockpage/stock_statistics.dart';
import 'package:flutter/material.dart';

// ============================================
// Class that holds the list of product
// ============================================
class GlobalItems {
  static List<Product> lists = [];

  Future<void> setList(List<Product> list) async {
    lists = list;

    List<Map<String, dynamic>> savedList = [];

    for (int i = 0; i < lists.length; i++) {
      savedList.add(lists[i].toJson());
    }

    DeviceStorage.setKey('user_products');
    await DeviceStorage.saveValue(jsonEncode(savedList));
  }

  List<Product> getLists() {
    return lists;
  }

  Future<List<Product>> loadListFromStorage() async {
    DeviceStorage.setKey('user_products');
    String? savedProduct = await DeviceStorage.loadValue('user_products');

    if (savedProduct == null || savedProduct.isEmpty) {
      lists = [];
      return lists;
    }

    List<dynamic> newList = jsonDecode(savedProduct);
    lists = newList.map((x) => Product.fromJson(x)).toList();
    return lists;
  }
}

// ==============================================
// Class to add new Items
//===============================================
class Product {
  String id;
  String name;
  double price;
  int quantity;
  bool inStock;
  String sku;
  String category;
  String status;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.inStock,
    this.sku = '',
    this.category = 'General',
    this.status = 'in-stock',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['stock'] ?? json['quantity'] ?? 0,
      inStock: (json['stock'] ?? json['quantity'] ?? 0) > 0,
      sku: json['sku'] ?? '',
      category: json['category'] ?? 'General',
      status: json['status'] ?? 'in-stock',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': quantity,
      'sku': sku,
      'category': category,
      'status': status,
    };
  }
}

// Main Widget
class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  String _stockFilter = 'All';

  // Controllers
  TextEditingController productName = TextEditingController();
  TextEditingController productQuantity = TextEditingController();
  TextEditingController productPrice = TextEditingController();
  TextEditingController productSku = TextEditingController();
  TextEditingController productCategory = TextEditingController();
  String typeEdit = 'add';
  String editItemId = '';

  List<Product> get items => StockGlobal.items;

  List<Product> get _filteredItems {
    if (_stockFilter == 'All') return items;
    return items.where((p) {
      final low = p.quantity >= 1 && p.quantity < 10;
      if (_stockFilter == 'In Stock') return p.inStock && !low;
      if (_stockFilter == 'Low Stock') return low;
      if (_stockFilter == 'Out of Stock') return !p.inStock || p.quantity <= 0;
      return true;
    }).toList();
  }

  String _searchQuery = '';
  void _searchFilter(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  List<Product> get _searchedItems {
    if (_searchQuery.isEmpty) return _filteredItems;
    return _filteredItems
        .where((x) => x.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  void _showAddModal(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      showDragHandle: true,
      isScrollControlled: true,
      context: context,
      backgroundColor: theme.cardColor,
      builder: (context) {

        return Container(
          constraints: const BoxConstraints(
            maxHeight: 600
          ),
          padding: EdgeInsets.only(
            right: 10,
            left: 10,
            top: 10,
            bottom: MediaQuery.of(context).viewInsets.bottom
          ),
          child: ListView(
            children: [
              Row(
                children: [
                  Text(
                    typeEdit == 'add' ? 'Add New items' : 'Edit Item',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (int.tryParse(productQuantity.text) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Quantity should be a number'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                      if (double.tryParse(productPrice.text) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Price should be a Decimal number.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                      if (typeEdit == 'add') {
                        _addItem(
                          productName.text,
                          int.parse(productQuantity.text),
                          double.parse(productPrice.text),
                          productSku.text,
                          productCategory.text,
                        );
                      } else {
                        _updateItem(
                          editItemId,
                          productName.text,
                          int.parse(productQuantity.text),
                          double.parse(productPrice.text),
                          productSku.text,
                          productCategory.text,
                        );
                      }
                      productPrice.clear();
                      productQuantity.clear();
                      productName.clear();
                      productSku.clear();
                      productCategory.clear();
                      Navigator.pop(context);
                    },
                    child: Text(
                      'Done',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                children: [
                  TextField(
                    controller: productName,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Milk',
                      labelText: 'Product Name',
                      icon: Icon(Icons.shopping_bag, color: theme.colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: productSku,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'SKU123',
                      labelText: 'SKU',
                      icon: Icon(Icons.qr_code, color: theme.colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: productCategory,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Dairy',
                      labelText: 'Category',
                      icon: Icon(Icons.category, color: theme.colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: productQuantity,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Quantity: 1',
                      labelText: 'Quantity',
                      icon: Icon(Icons.inventory, color: theme.colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: productPrice,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Price: 1.00',
                      labelText: 'Price',
                      icon: Icon(Icons.attach_money, color: theme.colorScheme.onSurface),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _addItem(String name, int quantity, double price, String sku, String category) async {
    final newProduct = Product(
      id: '', 
      name: name,
      price: price,
      quantity: quantity,
      inStock: quantity > 0,
      sku: sku,
      category: category,
    );

    try {
      await ProductService().createProduct(newProduct);
      await StockGlobal.loadItems();
    } catch (e) {
      debugPrint('Failed to add product: $e');
    }
  }

  void _updateItem(String id, String name, int quantity, double price, String sku, String category) async {
     try {
      await ProductService().updateProduct(id, {
        "name": name,
        "stock": quantity,
        "price": price,
        "sku": sku,
        "category": category,
      });
      await StockGlobal.loadItems();
    } catch (e) {
      debugPrint('Failed to update product: $e');
    }
  }

  void _deleteItem(String id) async {
    try {
      await ProductService().deleteProduct(id);
      await StockGlobal.loadItems();
    } catch (e) {
      debugPrint('Failed to delete product: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: StockGlobal(),
      builder: (context, _) {
        int totalItems = StockGlobal().totalItems;
        int outOfStock = StockGlobal().outOfStock;
        int lowStock = StockGlobal().lowStock;
        double totalValue = StockGlobal().totalInventoryValue;
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return ListView(
          children: [
            const GreetingCard(
              title: 'Stocks',
              message: 'Here is what happening on stocks',
            ),
            StockStatistics(
              totalItems: totalItems,
              lowStock: lowStock,
              totalValue: totalValue,
              outOfStock: outOfStock,
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: SearchBar(
                      onChanged: (query) => _searchFilter(query),
                      hintText: 'Search products...',
                      leading: const Icon(Icons.search),
                      backgroundColor: WidgetStateProperty.all(theme.cardColor),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: () {
                      typeEdit = 'add';
                      _showAddModal(context);
                    },
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['All', 'In Stock', 'Low Stock', 'Out of Stock'].map((label) {
                    final selected = _stockFilter == label;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: selected,
                        onSelected: (_) => setState(() => _stockFilter = label),
                        selectedColor: const Color(0xFF1565C0),
                        labelStyle: TextStyle(
                          color: selected ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_searchedItems.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('No products found.'),
                ),
              )
            else
              ListView.builder(
                itemCount: _searchedItems.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final product = _searchedItems[index];
                  bool isLow = product.quantity >= 1 && product.quantity < 10;
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(product.name.isNotEmpty ? product.name[0] : '?'),
                      ),
                      title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Stock: ${product.quantity} | Price: SLE ${product.price.toStringAsFixed(2)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () {
                              typeEdit = 'edit';
                              editItemId = product.id;
                              productName.text = product.name;
                              productPrice.text = product.price.toString();
                              productQuantity.text = product.quantity.toString();
                              productSku.text = product.sku;
                              productCategory.text = product.category;
                              _showAddModal(context);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.red),
                            onPressed: () => _deleteItem(product.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
