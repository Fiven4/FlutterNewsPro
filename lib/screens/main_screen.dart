import 'package:flutter/material.dart';
import 'news_feed_screen.dart';
import 'bookmarks_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const NewsFeedScreen(),
    const BookmarksScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFF1F5F9),
          surfaceTintColor: Colors.transparent,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 300),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF0F172A)),
              label: 'Главная',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.bookmark_rounded, color: Color(0xFF0F172A)),
              label: 'Сохраненное',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: Color(0xFF64748B)),
              selectedIcon: Icon(Icons.person_rounded, color: Color(0xFF0F172A)),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}