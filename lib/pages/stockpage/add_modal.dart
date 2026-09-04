/*
import 'package:first_flutter_project/global/stock/stock_global.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddModal {
  void _showAddModal(
    BuildContext context,
    int editItemId,
    String typeEdit,
    TextEditingController productName,
    TextEditingController productQuantity,
    TextEditingController productPrice,
      addItem,
  ) {
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
                        addItem(
                          productName.text,
                          int.parse(productQuantity.text),
                          double.parse(productPrice.text),
                        );
                      } else {
                        (() {
                          int idx = items.indexWhere(
                            (item) => item.id == editItemId,
                          );
                          if (idx != -1) {
                            items[idx].name = productName.text;
                            items[idx].price = double.parse(productPrice.text);
                            items[idx].quantity = int.parse(
                              productQuantity.text,
                            );
                          }
                        });
                        StockGlobal.saveItems();
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
}
*/
