
import 'package:flutter/material.dart';
class SubCards extends StatelessWidget {
  const SubCards({super.key, this.title = '', this.widget});

  final String title;
  final Widget? widget;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(20),
      decoration:  BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blueGrey.withAlpha(70), width: 1),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Column(
        children: [

          Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey.withAlpha(60))
              )
            ),
              child: Row(
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),)
                ],
              )
          ),


        ],
      ),
    );

  }
}