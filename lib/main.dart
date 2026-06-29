import 'package:first_flutter_project/components/pageTitle/pageTitle.dart';
import 'package:first_flutter_project/components/settings/settings.dart';
import 'package:first_flutter_project/global/app_theme.dart';
import 'package:first_flutter_project/global/theme_notifier.dart';
import 'package:first_flutter_project/pages/creditPage/credit_ledger.dart';
import 'package:first_flutter_project/pages/homepage/home_page.dart';
import 'package:first_flutter_project/pages/pos/pos_page.dart';
import 'package:first_flutter_project/pages/splash/splash_screen.dart';
import 'package:first_flutter_project/pages/stockpage/stock_page.dart';
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
          home: ListenableBuilder(
            listenable: isSplashScreen,
            builder: (context, _) {
              return isSplashScreen.value
                  ? const SplashScreen()
                  : const MainLayoutShell();
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
    'Stock',
    'Pos',
    'Credit',
    'Calc',
    'More',
  ];


  final List<IconData> icons = [
    Icons.dashboard,
    Icons.inventory_2,
    Icons.point_of_sale,
    Icons.credit_card,
    Icons.calculate,
    Icons.more,
  ];

  // List of actual body widgets for each tab index
  late final List<Widget> _pages;

  @override
  void initState()  {
    super.initState();
    // Initialize your pages array (added placeholder containers for demo)
    _pages = [
      const MyHomePage(), // Your existing homepage component
      const StockPage(), // stock page
      const PosPage(),
      const CreditLedger(),
      const Center(child: Text('Calc Page')),
      const Center(child: Text('More Page')),
    ];

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            onPressed: () {
              SettingPanel().showSettingPanel(context);
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      // Displays the correct active page body view configuration
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
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
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Stock',
            activeIcon: Icon(Icons.inventory_2),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.point_of_sale_outlined),
            activeIcon: Icon(Icons.point_of_sale),
            label: 'Pos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card_outlined),
            activeIcon: Icon(Icons.credit_card),
            label: 'Credit',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate_outlined),
            activeIcon: Icon(Icons.calculate),
            label: 'Calc',
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
