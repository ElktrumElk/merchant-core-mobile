import 'package:first_flutter_project/components/pageTitle/pageTitle.dart';
import 'package:first_flutter_project/pages/homepage/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// 1. Keep MyApp clean and Stateless
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainLayoutShell(), // Points to our new Stateful structural shell
    );
  }
}

// 2. Create a new StatefulWidget to handle the tab navigation logic
class MainLayoutShell extends StatefulWidget {
  const MainLayoutShell({super.key});

  @override
  State<MainLayoutShell> createState() => _MainLayoutShellState();
}

class _MainLayoutShellState extends State<MainLayoutShell> {
  // Track the active index
  int _currentIndex = 0;

  // List of page titles that match each tab index
  final List<String> _titles = ['Dashboard', 'Stock', 'Pos', 'Credit', 'Calc', 'More'];

  // List of actual body widgets for each tab index
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Initialize your pages array (added placeholder containers for demo)
    _pages = [
      const MyHomePage(), // Your existing homepage component
      const Center(child: Text('Stock Page')),
      const Center(child: Text('Pos Page')),
      const Center(child: Text('Credit Page')),
      const Center(child: Text('Calc Page')),
      const Center(child: Text('More Page')),

    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: Colors.white,
        shape: Border(
          bottom: BorderSide(
            color: Colors.grey.shade50,
            width: 1,
          ),
        ),
        toolbarHeight: 80,
        centerTitle: false,
        // Dynamically changes the title bar text string using the current index state variable
        title: PageTitle(title: _titles[_currentIndex]),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      // Displays the correct active page body view configuration
      body: _pages[_currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          setState(() {
            _currentIndex = index; // Re-renders the layout with the new tab index view state
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
            activeIcon: Icon(Icons.inventory_2)
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
          )
        ],
      ),
    );
  }
}
