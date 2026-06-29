import 'package:first_flutter_project/components/greetingCard/greeting_card.dart';
import 'package:first_flutter_project/global/stock/stock_global.dart';
import 'package:first_flutter_project/pages/stockpage/stock_statistics.dart';
import 'package:flutter/material.dart';

class TotalInventoryValue {
  static double sharedInventoryValue = 0.00;

  void setInventoryValue(double value) {
    sharedInventoryValue = value;
  }

  double getInventoryValue() {
    return sharedInventoryValue;
  }
}

// share items added on the stock page ================================
class GlobalItems {
  static List<Product> lists = [];

  void setList(List<Product> list) {
    lists = list;
  }

  List<Product> getLists() {
    return lists;
  }
}
// ================================================

// Required class to add items=====================
class Product {
  int id;
  String name;
  double price;
  int quantity;
  bool inStock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.inStock,
  });
}

// Main Widget
class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<Product> items = StockGlobal().itemsList;

  TextEditingController productName = TextEditingController();
  TextEditingController productQuantity = TextEditingController();
  TextEditingController productPrice = TextEditingController();
  String typeEdit = 'add';
  int editItemId = 0;

  void _showAddModal(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      showDragHandle: true,
      context: context,
      backgroundColor: theme.cardColor,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Add New items',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight(500),
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      if (int.tryParse(productQuantity.text) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Quantity should be a number',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                      if (double.tryParse(productPrice.text) == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Price should be a Decimal number. Example: 1.00',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                      if (typeEdit == 'add') {
                        _addItem(
                          productName.text,
                          int.parse(productQuantity.text),
                          double.parse(productPrice.text),
                        );
                      } else {
                        setState(() {
                          GlobalItems.lists[editItemId].name = productName.text;
                          GlobalItems.lists[editItemId].price = double.parse(
                            productPrice.text,
                          );
                          GlobalItems.lists[editItemId].quantity = int.parse(
                            productQuantity.text,
                          );
                        });
                      }
                      productPrice.clear();
                      productQuantity.clear();
                      productName.clear();
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
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(180),
                      ),
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(100),
                      ),
                      icon: Icon(Icons.add, color: theme.colorScheme.onSurface),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
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
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(180),
                      ),
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(100),
                      ),
                      icon: Icon(Icons.add, color: theme.colorScheme.onSurface),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
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
                      labelStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(180),
                      ),
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface.withAlpha(100),
                      ),
                      icon: Icon(Icons.add, color: theme.colorScheme.onSurface),
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
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

  void _addItem(String name, int quantity, double price) {
    setState(() {
      items.add(
        Product(
          id: items.length + 1,
          name: name,
          price: price,
          quantity: quantity,
          inStock: true,
        ),
      );
    });
  }

  void _deleteItem(int id) {
    setState(() {
      items.removeWhere((item) => item.id == id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item deleted'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate statistics dynamically
    int totalItems = StockGlobal().totalItems;
    int outOfStock = StockGlobal().outOfStock;
    int lowStock = StockGlobal().lowStock;
    double totalValue = StockGlobal().totalInventoryValue;
    TotalInventoryValue().setInventoryValue(totalValue);
    StockGlobal().setGlobalItems();
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
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SearchBar(
                  keyboardType: TextInputType.text,
                  hintText: 'Milk: ',
                  leading: Icon(Icons.search),
                  backgroundColor: WidgetStateProperty.all(theme.cardColor),
                  hintStyle: WidgetStateProperty.all(
                    TextStyle(
                      color: theme.colorScheme.onSurface.withAlpha(150),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: () {
                  _showAddModal(context);
                  typeEdit = 'add';
                },
                label: Text('Add'),
                icon: Icon(Icons.add),
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  backgroundColor: theme.cardColor,
                  foregroundColor: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        if (items.isEmpty)
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No products available.',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withAlpha(150),
                ),
              ),
            ),
          )
        else
          ListView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final product = items[index];

              return Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  border: Border.all(color: theme.dividerColor)
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2C2C2C)
                            : Colors.white60,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                  color: theme.cardColor,
                                ),
                                child: Center(
                                  child: Text(
                                    product.name.isNotEmpty
                                        ? product.name[0]
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    spacing: 20,
                                    children: [
                                      Text(
                                        product.name.length > 10
                                            ? '${product.name.substring(0, 7)} ...'
                                            : product.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: product.inStock
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          color: product.inStock
                                              ? Colors.green.withAlpha(70)
                                              : Colors.red.withAlpha(70),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Text(
                                          product.inStock
                                              ? 'In Stock'
                                              : 'Out of Stock',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: product.inStock
                                                ? Colors.green[800]
                                                : Colors.red[800],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Total: ${product.quantity}',
                                    style: TextStyle(
                                      color: theme.colorScheme.onSurface
                                          .withAlpha(180),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            spacing: 1,
                            children: [
                              IconButton(
                                onPressed: () {
                                  typeEdit = 'edit';
                                  editItemId = product.id - 1;
                                  productName.text = product.name;
                                  productPrice.text = product.price.toString();
                                  productQuantity.text = product.quantity
                                      .toString();
                                  _showAddModal(context);
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              IconButton(
                                onPressed: () => _deleteItem(product.id),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
