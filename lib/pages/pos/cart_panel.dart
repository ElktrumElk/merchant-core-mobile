import 'package:flutter/material.dart'; // Material components used for icons, buttons, and layouts
import 'package:first_flutter_project/pages/stockpage/stock_page.dart'; // Your Product model import

class AddItemsToCart extends ChangeNotifier {
  static final AddItemsToCart _instance = AddItemsToCart._internal();
  factory AddItemsToCart() => _instance;
  AddItemsToCart._internal();

  final List<CartItem> _cartItems = [];

  List<CartItem> get items => _cartItems;

  int get totalItemCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  //  quick helper to calculate total monetary checkout value
  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) {
      // Safely parse price string to double
      final double priceValue = item.product.price;
      return sum + (priceValue * item.quantity);
    });
  }

  void addProduct(Product product, {int quantity = 1}) {
    if (product.quantity <= 0) return;

    final existingItemIndex = _cartItems.indexWhere(
          (item) => item.product.id == product.id,
    );

    if (existingItemIndex != -1) {
      _cartItems[existingItemIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    product.quantity -= quantity;
    notifyListeners();
  }

  // logic to decrement product volume or remove if it hits zero
  void removeProduct(Product product) {
    final existingItemIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (existingItemIndex != -1) {
      product.quantity++;
      if (_cartItems[existingItemIndex].quantity > 1) {
        _cartItems[existingItemIndex].quantity--;
      } else {
        _cartItems.removeAt(existingItemIndex);
      }
    }
    notifyListeners();
  }

  void clearCart() {
    for (var item in _cartItems) {
      item.product.quantity += item.quantity;
    }
    _cartItems.clear();
    notifyListeners();
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });
}

class CartPanel extends StatefulWidget {
  const CartPanel({super.key});

  @override
  State<CartPanel> createState() => _CartPanelState();
}

class _CartPanelState extends State<CartPanel> {
  final cart = AddItemsToCart();
  final itemData = GlobalItems().getLists();

  @override
  Widget build(BuildContext context) {

    return ListenableBuilder(
      listenable: cart,
      builder: (context, child) {
        final cartList = cart.items;

        return Container(
          margin: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),

          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          height: 500,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Dynamic Header with Item Counter
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shopping Cart (${cart.totalItemCount})',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (cartList.isNotEmpty)
                    TextButton.icon(
                      onPressed: () {
                        cart.clearCart();
                      },
                      icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                      label: const Text('Clear All', style: TextStyle(color: Colors.red)),
                    )
                ],
              ),
              const Divider(height: 24),

              // 2. Conditional Rendering: Empty State vs Scrollable Cart List
              Expanded(
                child: cartList.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('Your cart is empty', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
                    : ListView.separated(
                  itemCount: cartList.length,
                  separatorBuilder: (context, index) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final item = cartList[index];
                    return Row(
                      children: [
                        // Product Image Placeholder Block
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image, color: Colors.grey),
                        ),
                        const SizedBox(width: 12),

                        // Product Name & Total Row Item Calculation Display
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${item.product.price}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),

                        // Math Counter Action Buttons (Minus / Count / Plus)
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                              onPressed: () {
                                cart.removeProduct(item.product);
                              },
                            ),
                            Text(
                              '${item.quantity}',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                              onPressed: () {
                                cart.addProduct(item.product);
                              },
                            ),
                          ],
                        )
                      ],
                    );
                  },
                ),
              ),
              const Divider(height: 24),

              // 3. Absolute Bottom Calculation Summary Block
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Amount:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text(
                    '\$${cart.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 4. Checkout Action button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(

                  onPressed: cartList.isEmpty
                      ? null
                      : () {
                    // Place your checkout processing logic here
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.black
                  ),
                  child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
