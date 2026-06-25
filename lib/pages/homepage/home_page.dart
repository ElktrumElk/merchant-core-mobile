import 'package:first_flutter_project/components/greetingCard/greeting_card.dart';
import 'package:first_flutter_project/components/revenueTrend/revenue_trend.dart';
import 'package:first_flutter_project/components/statistics/home_statistics.dart';
import 'package:first_flutter_project/components/subcards/sub_cards.dart';
import 'package:flutter/material.dart';
export './home_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {

    return ListView(
      scrollDirection: Axis.vertical,
      children: [
        GreetingCard(title: 'Dashboard', message: 'Here is what happening at Merchant Core today',),
        HomeStatistics(),
        RevenueTrend(),
        SubCards(title: 'Recent Transaction',),
        SubCards(title: 'Alerts',)

      ],
    );
      
  }
}
