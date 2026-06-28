import 'package:first_flutter_project/components/greetingCard/greeting_card.dart';
import 'package:first_flutter_project/components/statistics/statistics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class CreditLedger extends StatelessWidget {
  const CreditLedger({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.vertical,

      children: [
        const GreetingCard(
          title: 'Credit',
          message: 'Get Insight of your credit',
        ),

        Container(
          padding: const EdgeInsets.all(10),

          // Height is kept at 400 to give the explicit Grid area a bounding box inside the ListView
          child: StaggeredGrid.count(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              StaggeredGridTile.count(
                crossAxisCellCount: 2,
                mainAxisCellCount: 2,
                child: const Statistics(
                  title: 'Total Outstanding',
                  value: 'NLE 0.00',
                ),
              ),

              StaggeredGridTile.count(
                crossAxisCellCount: 1,
                mainAxisCellCount: 1,
                child: const Statistics(title: 'Overdue Account', value: '0'),
              ),

              StaggeredGridTile.count(
                crossAxisCellCount: 1,
                mainAxisCellCount: 1,
                child: const Statistics(title: 'Collected', value: 'NLE 0.00'),
              ),
            ],
          ),
        ),

      ],
    );
  }
}
