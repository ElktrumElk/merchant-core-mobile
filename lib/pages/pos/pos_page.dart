import 'package:first_flutter_project/pages/pos/card_items.dart';
import 'package:first_flutter_project/pages/pos/cart_panel.dart';
import 'package:first_flutter_project/pages/pos/categories_button.dart';
import 'package:flutter/material.dart';

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
              child: ListView(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: [

                  const CategoriesButton(),
                  const CardItems(),
                  const CartPanel()
                ],
              ),
            ),
          ],
        ),

        Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsetsGeometry.all(10),
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: Icon(Icons.shopping_cart),
              label: Text('Cart'),
            ),
          ),
        ),


      ],
    );
  }
}
