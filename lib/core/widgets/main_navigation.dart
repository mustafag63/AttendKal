import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/courses/presentation/pages/courses_page.dart';
import '../../features/analytics/presentation/pages/analytics_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import 'bottom_navigation.dart';

class MainNavigation extends StatefulWidget {
  final int initialIndex;

  const MainNavigation({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const HomePage(),
    const CoursesPage(),
    const AnalyticsPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
      floatingActionButton: (_currentIndex == 0 || _currentIndex == 1) 
        ? FloatingActionButton(
            heroTag: "main_fab",
            onPressed: () => context.go('/add-course'),
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            child: const Icon(Icons.add),
          )
        : null,
    );
  }
}
