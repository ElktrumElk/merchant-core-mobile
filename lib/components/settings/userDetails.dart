import 'package:flutter/material.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Icon(Icons.supervised_user_circle_rounded, size: 40, color: Colors.blueAccent[200],),
          const SizedBox(width: 20,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Elkanah Cole'),
              Text('festinacole373@gmail.com', style: TextStyle(color: Colors.grey),)
            ],
          )
        ],  
      ),
    );
  }
}