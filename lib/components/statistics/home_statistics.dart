import 'package:first_flutter_project/global/credit_global.dart';
import 'package:first_flutter_project/global/sales_global.dart';
import 'package:first_flutter_project/global/stock/stock_global.dart';
import 'package:first_flutter_project/pages/stockpage/stock_page.dart';
import 'package:flutter/material.dart';

class HomeStatistics extends StatefulWidget {
  const HomeStatistics({super.key});

  @override
  State<HomeStatistics> createState() => _HomeStatisticsState();
}

class _HomeStatisticsState extends State<HomeStatistics> {
  final OrderStore _orderStore = OrderStore();
  final CreditStore _creditStore = CreditStore();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _creditStore.loadSampleData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return ListenableBuilder(
      listenable: Listenable.merge([_orderStore, _creditStore, StockGlobal()]),
      builder: (context, _) {
        final inventory = StockGlobal().totalInventoryValue;
        final totalRevenue = _orderStore.totalRevenue;
        final orders = _orderStore.orderCount;
        final creditOutstanding = _creditStore.totalOutstanding;

        return Container(
          padding: EdgeInsets.all(screenWidth < 360 ? 10 : 16.0),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'TOTAL REVENUE',
                      value: 'SLE ${totalRevenue.toStringAsFixed(2)}',
                      color: theme.colorScheme.onSurface,
                      info: '$orders order${orders == 1 ? '' : 's'} completed',
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
                      color: theme.colorScheme.onSurface,
                      info: '$orders total order${orders == 1 ? '' : 's'}',
                      infoColor: Colors.grey,
                      iconUrl: 'assets/icons/increase.png',
                      iconColor: Colors.grey
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'INVENTORY',
                      value: 'SLE ${inventory.toStringAsFixed(2)}',
                      color: theme.colorScheme.onSurface,
                      info: '${StockGlobal.items.length} Products',
                      infoColor: Colors.grey,
                      iconUrl: 'assets/icons/inventory.png',
                      iconColor: Colors.grey
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      title: 'CREDIT OUTSTANDING',
                      value: 'SLE ${creditOutstanding.toStringAsFixed(2)}',
                      color: Colors.amber.shade700,
                      info: '${_creditStore.overdueCount} overdue',
                      infoColor: Colors.grey,
                      iconUrl: 'assets/icons/alert.png',
                      iconColor: Colors.amber.shade700
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

  Widget _buildStatCard({
    String title = 'untitled',
    String value = '',
    Color color = Colors.black,
    String info = '',
    Color infoColor = Colors.black,
    Color iconColor = Colors.black,
    String iconUrl = ''
  }) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 370;
    final isVerySmall = screenWidth < 340;

    final titleFont = isVerySmall ? 9.0 : (isSmall ? 10.0 : 12.0);
    final valueFont = isVerySmall ? 13.0 : (isSmall ? 15.0 : 18.0);
    final infoFont = isVerySmall ? 9.0 : (isSmall ? 10.0 : 12.0);
    final iconSize = isSmall ? 16.0 : 20.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isVerySmall ? 6 : 12,
        vertical: isVerySmall ? 10 : 16,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withAlpha(130)
                : Colors.grey.withAlpha(90),
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
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withAlpha(180),
                    fontSize: titleFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Image.asset(
                iconUrl,
                width: iconSize,
                height: iconSize,
                color: iconColor,
              ),
            ],
          ),
          SizedBox(height: isVerySmall ? 10 : 20),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: valueFont,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          SizedBox(height: isVerySmall ? 8 : 20),
          Text(
            info,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: infoColor,
              fontSize: infoFont,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
