import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../utils/theme.dart';

import 'home_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';

/// Main Navigation Screen with iOS-style bottom tab bar
/// 
/// Provides navigation between Home, Stats, and Settings screens
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late PageController _pageController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const StatsScreen(),
    const SettingsScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = [
    const BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.home),
      activeIcon: Icon(CupertinoIcons.house_fill),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.chart_bar),
      activeIcon: Icon(CupertinoIcons.chart_bar_fill),
      label: 'Stats',
    ),
    const BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.settings),
      activeIcon: Icon(CupertinoIcons.settings_solid),
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Handle tab selection
  void _onTabSelected(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Handle page change from swipe
  void _onPageChanged(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundDark,
          border: Border(
            top: BorderSide(
              color: AppTheme.greyLight.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 50,
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabSelected,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppTheme.greyPrimary,
              unselectedItemColor: AppTheme.secondaryText.withValues(alpha: 0.6),
              selectedFontSize: 11,
              unselectedFontSize: 11,
              iconSize: 22,
              items: _navItems,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontFamily: 'SourGummy',
                height: 1.2,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: 'SourGummy',
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}