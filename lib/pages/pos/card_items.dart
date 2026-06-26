import 'package:first_flutter_project/pages/pos/cart_panel.dart';
import 'package:first_flutter_project/pages/stockpage/stock_page.dart';
import 'package:flutter/material.dart';

class CardItems extends StatefulWidget {
  const CardItems({super.key});

  @override
  State<CardItems> createState() => _CardItemState();
}

class _CardItemState extends State<CardItems> {
  final List<Product> itemsData = GlobalItems().getLists();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AddItemsToCart(),
      builder: (context, index) {
        return GridView.builder(
          itemCount: itemsData.length,
          shrinkWrap: true,
          padding: const EdgeInsets.all(10),
          physics: const NeverScrollableScrollPhysics(),
          // Prevents nested scrolling conflicts
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Forces exactly two columns
            crossAxisSpacing: 12.0, // Horizontal spacing between cards
            mainAxisSpacing: 12.0, // Vertical spacing between rows
            childAspectRatio:
                0.75, // Adjust this ratio to balance height vs width of the card
          ),
          itemBuilder: (context, index) {
            final product = itemsData[index];

            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),

              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Product Image / Placeholder Space
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: double.infinity,
                        child: const Icon(Icons.inventory, color: Colors.grey),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 2. Product Name / Title
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // 3. Product Price
                    Text(
                      '\$${product.price}', // Fallback if price is nullable
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 4. Action Button (Using your transparent styled button from earlier!)
                    SizedBox(
                      width: double.infinity,
                      height: 36,

                      child: FilledButton(
                        onPressed: () {
                          setState(() {
                            if (product.quantity <= 0) {
                              return;
                            }

                            AddItemsToCart().addProduct(product);
                            product.quantity--;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart!'),
                              duration: const Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: Colors.black,
                            ),
                          );
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: product.quantity <= 0
                              ? Colors.grey
                              : Colors.black,
                          disabledBackgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.grey),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          product.quantity <= 0 ? "Out of stock" : "Add",
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
