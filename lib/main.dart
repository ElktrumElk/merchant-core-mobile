import 'dart:async';
import 'package:first_flutter_project/components/pageTitle/pageTitle.dart';
import 'package:first_flutter_project/components/settings/notification_panel.dart';
import 'package:first_flutter_project/components/settings/settings.dart';
import 'package:first_flutter_project/global/app_theme.dart';
import 'package:first_flutter_project/global/theme_notifier.dart';
import 'package:first_flutter_project/global/sales_global.dart';
import 'package:first_flutter_project/pages/morepage/more_page.dart';
import 'package:first_flutter_project/pages/chat/chat_list_screen.dart';
import 'package:first_flutter_project/pages/homepage/home_page.dart';
import 'package:first_flutter_project/pages/market/MarketScreen.dart';
import 'package:first_flutter_project/pages/market/market_orders_screen.dart';
import 'package:first_flutter_project/pages/market/market_search_page.dart';
import 'package:first_flutter_project/pages/pos/pos_page.dart';
import 'package:first_flutter_project/pages/splash/splash_screen.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await themeNotifier.init();
  runApp(const MyApp());
}

ValueNotifier<bool> isSplashScreen = ValueNotifier<bool>(true);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: isSplashScreen,
          builder: (context, isSplash, _) {
            return MaterialApp(
              key: ValueKey(isSplash), // Forces full reset of Navigator on login/logout
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeMode,
              debugShowCheckedModeBanner: false,
              home: isSplash ? const SplashScreen() : const MainLayoutShell(),
            );
          },
        );
      },
    );
  }
}

// 2. Create a new StatefulWidget to handle the tab navigation logic
class MainLayoutShell extends StatefulWidget {
  const MainLayoutShell({super.key});

  @override
  State<MainLayoutShell> createState() => _MainLayoutShellState(); // key in creating state
}

class _MainLayoutShellState extends State<MainLayoutShell> {
  // Track the active index
  int _currentIndex = 0;

  // Polls the server for new negotiation messages so the bottom-nav badge
  // updates in real time even while the Negotiate tab isn't the active tab.
  Timer? _unreadPollTimer;

  // Pages opened "inside" the shell (Stock Inventory, Credit Ledger) so the
  // general app bar and the bottom navigation stay visible while viewing them.
  bool _inAux = false;
  Widget? _auxPage;
  String _auxTitle = '';
  IconData _auxIcon = Icons.grid_view;

  void _openInShell(Widget page, String title, IconData icon) {
    setState(() {
      _inAux = true;
      _auxPage = page;
      _auxTitle = title;
      _auxIcon = icon;
    });
  }

  // List of page titles that match each tab index
  final List<String> _titles = [
    'Dashboard',
    'Market',
    'Negotiate',
    'Pos',
    'More',
  ];

  final GlobalKey<ChatListScreenState> _chatListKey =
      GlobalKey<ChatListScreenState>();

  final List<IconData> icons = [
    Icons.dashboard,
    Icons.storefront,
    Icons.chat_bubble_outline,
    Icons.point_of_sale,
    Icons.more_horiz,
  ];

  // List of actual body widgets for each tab index
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize your pages array (added placeholder containers for demo)
    _pages = [
      const MyHomePage(), // Your existing homepage component
      const MarketScreen(),
      ChatListScreen(key: _chatListKey),
      const PosPage(),
      MorePage(onOpenPage: _openInShell),
    ];

    // The chat list screen is disposed when you switch tabs, so its own polling
    // stops. Poll here whenever the Negotiate tab isn't mounted so the badge
    // still gets live updates from the server.
    _unreadPollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_chatListKey.currentState != null) return;
      unawaited(refreshNegotiationUnread());
    });
    unawaited(refreshNegotiationUnread());
  }

  @override
  void dispose() {
    _unreadPollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        shape: Border(
          bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
        toolbarHeight: 80,
        centerTitle: false,
        title: PageTitle(
          title: _inAux ? _auxTitle : _titles[_currentIndex],
          icon: _inAux ? _auxIcon : icons[_currentIndex],
        ),
        actions: [
          if (_currentIndex == 1) // Only show search for Market tab
            IconButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketSearchPage()),
              ),
              icon: const Icon(Icons.search),
            ),

          if (_currentIndex == 1) // My Orders for the Market tab
            IconButton(
              tooltip: 'My Orders',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MarketOrdersScreen()),
              ),
              icon: const Icon(Icons.receipt_long_outlined),
            ),

          if (_currentIndex == 2) // Search on the header for Negotiate
            IconButton(
              onPressed: () => _chatListKey.currentState?.activateSearch(),
              icon: const Icon(Icons.search),
            ),

          if (_currentIndex != 1 && _currentIndex != 2) ...[
            ListenableBuilder(
              listenable: OrderStore(),
              builder: (context, _) {
                final bool hasNotifications = OrderStore().orders.isNotEmpty;
                return IconButton(
                  onPressed: () => NotificationPanel().show(context),
                  icon: Icon(
                    hasNotifications
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                    color: hasNotifications ? Colors.blue : null,
                  ),
                );
              },
            ),

            IconButton(
              onPressed: () => SettingPanel().showSettingPanel(context),
              icon: const Icon(Icons.settings),
            ),
          ],
        ],
      ),
      // Displays the correct active page body view configuration
      body: _inAux ? _auxPage : _pages[_currentIndex],

      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: negotiationUnreadCount,
        builder: (context, unread, _) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            type: BottomNavigationBarType.fixed,
            onTap: (int index) {
              setState(() {
                _inAux = false;
                _auxPage = null;
                _currentIndex =
                    index; // Re-renders the layout with the new tab index view state
              });
              if (index == 2) {
                _chatListKey.currentState?.startPolling();
              } else {
                _chatListKey.currentState?.stopPolling();
              }
            },
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.storefront_outlined),
                activeIcon: Icon(Icons.storefront),
                label: 'Market',
              ),
              BottomNavigationBarItem(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.chat_bubble_outline),
                ),
                activeIcon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.chat_bubble),
                ),
                label: 'Negotiate',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.point_of_sale_outlined),
                activeIcon: Icon(Icons.point_of_sale),
                label: 'Pos',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz_outlined),
                activeIcon: Icon(Icons.more_horiz),
                label: 'More',
              ),
            ],
          );
        },
      ),
    );
  }
}
