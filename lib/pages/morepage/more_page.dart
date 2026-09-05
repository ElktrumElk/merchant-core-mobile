import 'package:first_flutter_project/components/settings/notification_panel.dart';
import 'package:first_flutter_project/components/settings/settings.dart';
import 'package:first_flutter_project/components/settings/userDetails.dart';
import 'package:first_flutter_project/global/valueNotifiers/gloabal_value_notifiers.dart';
import 'package:first_flutter_project/network/logout/logout.dart';
import 'package:first_flutter_project/pages/calcpage/calc_page.dart';
import 'package:first_flutter_project/pages/creditPage/credit_ledger.dart';
import 'package:first_flutter_project/pages/stockpage/stock_page.dart';
import 'package:flutter/material.dart';

class MorePage extends StatelessWidget {
  /// When provided, pages are opened inside the main scaffold body (keeping
  /// the general app bar and bottom navigation visible) instead of as a
  /// full-screen pushed route.
  final void Function(Widget page, String title, IconData icon)? onOpenPage;

  const MorePage({super.key, this.onOpenPage});

  void _open(BuildContext context, Widget page, String title, IconData icon) {
    if (onOpenPage != null) {
      onOpenPage!(page, title, icon);
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          const UserDetails(),
          const SizedBox(height: 20),

          _section(
            context,
            children: [
              _optionTile(
                context,
                icon: Icons.inventory_2_outlined,
                title: 'Stock Inventory',
                subtitle: 'Manage your products and stock levels',
                onTap: () => _open(
                  context,
                  const StockPage(),
                  'Stock Inventory',
                  Icons.inventory_2_outlined,
                ),
              ),
              _optionTile(
                context,
                icon: Icons.credit_card_outlined,
                title: 'Credit Ledger',
                subtitle: 'Track customer debts and payments',
                onTap: () => _open(
                  context,
                  const CreditLedger(),
                  'Credit Ledger',
                  Icons.credit_card_outlined,
                ),
              ),
              _optionTile(
                context,
                icon: Icons.calculate_outlined,
                title: 'Calculator',
                subtitle: 'Quick business calculations',
                onTap: () => _open(
                  context,
                  const CalcPage(),
                  'Calculator',
                  Icons.calculate_outlined,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _section(
            context,
            children: [
              _optionTile(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                subtitle: 'Theme, notifications, backup',
                onTap: () => SettingPanel().showSettingPanel(context),
              ),
              _optionTile(
                context,
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: GlobalValueNotifiers.isGetNotify.value
                    ? 'Enabled'
                    : 'Disabled',
                onTap: () => NotificationPanel().show(context),
              ),
              _optionTile(
                context,
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'Version 1.0.0',
                onTap: () => _showAbout(context),
              ),
              _optionTile(
                context,
                icon: Icons.share_outlined,
                title: 'Share App',
                subtitle: 'Tell others about Merchant Core',
                onTap: () => _shareApp(context),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _section(
            context,
            children: [
              _optionTile(
                context,
                icon: Icons.logout,
                title: 'Log Out',
                subtitle: 'Exit your current session',
                onTap: () => _confirmLogout(context),
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(BuildContext context, {required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _optionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final primaryColor = color ?? const Color(0xFF1565C0);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          leading: Icon(icon, color: primaryColor),
          title: Text(
            title,
            style: TextStyle(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Merchant Core'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.leaderboard, size: 48, color: Color(0xFF1565C0)),
            const SizedBox(height: 12),
            Text(
              'Version 1.0.0',
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your business in one place',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _shareApp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share link copied to clipboard')),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Logout().logout();
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
