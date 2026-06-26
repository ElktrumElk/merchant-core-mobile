import 'package:first_flutter_project/pages/stockpage/stock_page.dart';
import 'package:flutter/material.dart';

class HomeStatistics extends StatefulWidget {
  const HomeStatistics({super.key});

  @override
  State<HomeStatistics> createState() => _HomeStatisticsState();

}

class _HomeStatisticsState extends State<HomeStatistics> {
  double totalRevenue = 0.00;
  int orders = 0;
  double inventory = TotalInventoryValue().getInventoryValue();
  int creditOutstanding = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'TOTAL REVENU',
                  value: 'NLE ${totalRevenue.toStringAsFixed(2)}',
                  color: Colors.black,
                  info: 'NLE${totalRevenue.toStringAsFixed(2)} this month',
                  infoColor: Colors.green,
                  iconUrl: 'assets/icons/dollar.png',
                  iconColor: Colors.grey
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: 'ORDERS',
                  value: orders.toString(),
                  color: Colors.black,
                  info: '${orders.toString()} active customers',
                  infoColor: Colors.grey,
                    iconUrl: 'assets/icons/increase.png',
                    iconColor: Colors.grey
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'INVENTORY',
                  value: 'NLE ${inventory.toStringAsFixed(2)}',
                  color: Colors.black,
                  info: '0 Products',
                  infoColor: Colors.grey,
                    iconUrl: 'assets/icons/inventory.png',
                    iconColor: Colors.grey
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: 'CREDIT OUTSTANDING',
                  value: creditOutstanding.toString(),
                  color: Colors.yellow.shade700,
                  info: '${creditOutstanding.toString()} low stock alert',
                  infoColor: Colors.grey,
                    iconUrl: 'assets/icons/alert.png',
                    iconColor: Colors.yellow.shade700
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget  _buildStatCard({
    String title = 'untitled',
    String value = '',
    Color color = Colors.black,
    String info = '',
    Color infoColor = Colors.black,
    Color iconColor = Colors.black,
    String iconUrl = ''
  }) {
    return Container(
      width: 150.0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xFFEAEAEA), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(90),
            blurRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),

              Image.asset(
               iconUrl,
                width: 20,
                height: 20,
                color: iconColor,
              ),
            ],
          ),

          const SizedBox(height: 20),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            info,
            style: TextStyle(
              color: infoColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
