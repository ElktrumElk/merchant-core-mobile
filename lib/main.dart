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
        return MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: ValueListenableBuilder<bool>(
            valueListenable: isSplashScreen,
            builder: (context, isSplash, _) {
              return isSplash ? const SplashScreen() : const MainLayoutShell();
            },
          ),
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
  void initState()  {
    super.initState();
    // Initialize your pages array (added placeholder containers for demo)
    _pages = [
      const MyHomePage(), // Your existing homepage component
      const MarketScreen(),
      ChatListScreen(key: _chatListKey),
      const PosPage(),
      const MorePage(),
    ];
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
          title: _titles[_currentIndex],
          icon: icons[_currentIndex],
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

          if (_currentIndex == 2) // Search on the header for Negotiate
            IconButton(
              onPressed: () => _chatListKey.currentState?.activateSearch(),
              icon: const Icon(Icons.search),
            ),

          if (_currentIndex != 2) ...[
            ListenableBuilder(
              listenable: OrderStore(),
              builder: (context, _) {
                final bool hasNotifications = OrderStore().orders.isNotEmpty;
                return IconButton(
                  onPressed: () => NotificationPanel().show(context),
                  icon: Icon(
                    hasNotifications ? Icons.notifications_active : Icons.notifications_none,
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
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            _currentIndex =
                index; // Re-renders the layout with the new tab index view state
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Market',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Negotiate',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_outlined),
            activeIcon: Icon(Icons.point_of_sale),
            label: 'Pos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz_outlined),
            activeIcon: Icon(Icons.more_horiz),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
