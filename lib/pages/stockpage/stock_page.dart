import 'package:first_flutter_project/components/greetingCard/greeting_card.dart';
import 'package:first_flutter_project/pages/stockpage/stock_statistics.dart';
import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final double price;
  final int quantity;
  final bool inStock;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.inStock,
  });
}

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  final List<Product> items = const [
    Product(id: 1, name: 'Milk', price: 3.00, quantity: 60, inStock: true),
    Product(id: 2, name: 'Gari', price: 2.00, quantity: 12, inStock: true),
    Product(id: 3, name: 'Sugar', price: 2.00, quantity: 30, inStock: true),
    Product(id: 4, name: 'Bread', price: 5.00, quantity: 10, inStock: true),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const GreetingCard(
          title: 'Stocks',
          message: 'Here is what happening on stocks',
        ),
        const StockStatistics(),
        const SizedBox(height: 10),

        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          padding: const EdgeInsets.all(10),
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: const TextField(
            style: TextStyle(fontSize: 16),
            decoration: InputDecoration(
              fillColor: Colors.white,
              border: InputBorder.none,
              hintText: 'Search stock...', // Added context helper text
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Items cards loop
        ListView.builder(
          itemCount: items.length,
          shrinkWrap: true, // Crucial fix: must be true inside another ListView
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final product = items[index]; // Fetching current loop item

            return Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: const BoxDecoration(color: Colors.white),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5), // Crucial fix: valid hex color
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
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                                color: Colors.white,
                              ),
                              child: Center(
                                child: Text(
                                  product.name.isNotEmpty ? product.name[0] : '?', // Gets first letter dynamically
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
                                      product.name, // Dynamic product name
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: product.inStock ? Colors.green : Colors.red,
                                        ),
                                        color: product.inStock
                                            ? Colors.green.withAlpha(70)
                                            : Colors.red.withAlpha(70),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        product.inStock ? 'In Stock' : 'Out of Stock', // Dynamic badge text
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: product.inStock ? Colors.green[800] : Colors.red[800],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Text('Total: ${product.quantity}') // Dynamic stock quantity tracking
                              ],
                            )
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
                              onPressed: () {},
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                          ],
                        )
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
