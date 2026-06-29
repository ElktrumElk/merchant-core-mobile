import 'package:first_flutter_project/global/sales_global.dart';
import 'package:flutter/material.dart';
import 'package:first_flutter_project/pages/stockpage/stock_page.dart';

class AddItemsToCart extends ChangeNotifier {
  static final AddItemsToCart _instance = AddItemsToCart._internal();
  factory AddItemsToCart() => _instance;
  AddItemsToCart._internal();

  final List<CartItem> _cartItems = [];

  List<CartItem> get items => _cartItems;

  int get totalItemCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalPrice {
    return _cartItems.fold(0.0, (sum, item) {
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

  void removeProduct(Product product) {
    final existingItemIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Shopping Cart (${cart.totalItemCount})',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
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
              Divider(height: 24, color: theme.dividerColor),
              Expanded(
                child: cartList.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 64, color: theme.colorScheme.onSurface.withAlpha(100)),
                      const SizedBox(height: 12),
                      Text('Your cart is empty', style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150), fontSize: 16)),
                    ],
                  ),
                )
                    : ListView.separated(
                  itemCount: cartList.length,
                  separatorBuilder: (context, index) => Divider(height: 16, color: theme.dividerColor),
                  itemBuilder: (context, index) {
                    final item = cartList[index];
                    return Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.image, color: theme.colorScheme.onSurface.withAlpha(100)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: theme.colorScheme.onSurface),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '\$${item.product.price}',
                                style: TextStyle(color: theme.colorScheme.onSurface.withAlpha(150)),
                              ),
                            ],
                          ),
                        ),
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
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.onSurface),
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
              Divider(height: 24, color: theme.dividerColor),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Amount:', style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface.withAlpha(150))),
                  Text(
                    '\$${cart.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: cartList.isEmpty
                      ? null
                      : () {
                    final products = cartList.map((item) => item.product).toList();
                    OrderStore().addOrder(products, cart.totalPrice);
                    cart.clearCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Order completed!'),
                        duration: Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.black,
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
