import 'dart:ffi';

import 'package:first_flutter_project/components/greetingCard/greeting_card.dart';
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

  List<Product> getLists () {
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
//=========================================================

// Main Widget
class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  List<Product> items = [
     Product(
      id: 1,
      name: 'Milk',
      price: 3.00,
      quantity: 5,
      inStock: true,
    ),
    Product(
      id: 2,
      name: 'Gari',
      price: 2.00,
      quantity: 12,
      inStock: true,
    ),
    Product(
      id: 3,
      name: 'Sugar',
      price: 2.00,
      quantity: 30,
      inStock: true,
    ),
    Product(
      id: 4,
      name: 'Bread',
      price: 5.00,
      quantity: 10,
      inStock: true,
    ),
  ];

  void _addItem(String name, int quantity, double price) {
    setState(() {
      items.add(
        Product(
          id: items.length,
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
    int totalItems = items.length;
    int outOfStock = items
        .where((item) => !item.inStock || item.quantity <= 0)
        .length;
    int lowStock = items
        .where((item) => item.quantity > 0 && item.quantity < 15)
        .length;
    double totalValue = items.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    TotalInventoryValue().setInventoryValue(totalValue);
    GlobalItems().setList(items);


    return ListView(
      children: [

        const GreetingCard(
          title: 'Stocks',
          message: 'Here is what happening on stocks',
        ),

        // Statistics card===============================
        StockStatistics(
          totalItems: totalItems,
          lowStock: lowStock,
          totalValue: totalValue,
          outOfStock: outOfStock,
        ),

        //=============================================
        const SizedBox(height: 10),

        //Search===========================================
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          padding: const EdgeInsets.all(10),

          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),

          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: const SearchBar(
                  keyboardType: TextInputType.text,
                  hintText: 'Milk: ',
                  leading: Icon(Icons.search),
                ),
              ),

              IconButton(onPressed: () {}, icon: Icon(Icons.add), iconSize: 30),
            ],
          ),
        ),


        //=======================================
        const SizedBox(height: 10),

        // Items cards loop==============================================
        if (items.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No products available.'),
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
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.all(Radius.circular(10)),
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
                              decoration: const BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                                color: Colors.white,
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
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  spacing: 20,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
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
                                        borderRadius: BorderRadius.circular(10),
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
                                Text('Total: ${product.quantity}'),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          spacing: 1,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(Icons.edit),
                            ),
                            IconButton(
                              onPressed: () => _deleteItem(product.id),
                              icon: const Icon(Icons.delete, color: Colors.red),
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
