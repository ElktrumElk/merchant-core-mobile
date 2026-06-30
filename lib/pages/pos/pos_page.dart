import 'package:first_flutter_project/pages/pos/card_items.dart';
import 'package:first_flutter_project/pages/pos/cart_panel.dart';
import 'package:first_flutter_project/pages/pos/categories_button.dart';
import 'package:flutter/material.dart';

ValueNotifier<bool> isCart = ValueNotifier<bool>(false);

class PosPage extends StatelessWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ListenableBuilder(
                listenable: isCart,
                builder: (context, _) {
                  return ListView(
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      if(!isCart.value)
                        const CategoriesButton(),
                      isCart.value ? const CartPanel() : const CardItems(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),

        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsetsGeometry.all(10),
            child: ElevatedButton.icon(
              onPressed: () {
                isCart.value = !isCart.value;
              },
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).cardColor,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
