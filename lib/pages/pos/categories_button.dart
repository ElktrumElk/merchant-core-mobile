import 'package:flutter/material.dart';

class CategoriesButton extends StatelessWidget {
  const CategoriesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50, // Added height for the horizontal ListView

      padding: const EdgeInsets.all(10),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              
              FilledButton(
                onPressed: () {},
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.transparent),
                  foregroundColor: WidgetStateProperty.all(Colors.black),
                  side: WidgetStateProperty.all(
                    const BorderSide(color: Colors.grey),
                  ),
                ),

                child: Text('All'),
              ),
            ],
          ),


        ],
      ),
    );
  }
}
