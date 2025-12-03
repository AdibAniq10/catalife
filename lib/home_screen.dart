import 'package:flutter/material.dart';
import 'package:catalife_pj/dashboard_screen.dart';
import 'package:catalife_pj/control_screen.dart';
import 'package:catalife_pj/theme_service.dart';

class HomeScreen extends StatefulWidget {
  final ThemeService themeService;

  const HomeScreen({super.key, required this.themeService});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
    DashboardScreen(themeService: widget.themeService),
    ControlScreen(themeService: widget.themeService),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          border: Border(
            top: BorderSide(
              color: const Color(0xFF334155).withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          backgroundColor: Colors.transparent,
          indicatorColor: const Color(0xFF6366F1).withValues(alpha: 0.15),
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 72,
          animationDuration: const Duration(milliseconds: 300),
          destinations: [
            NavigationDestination(
              icon: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.dashboard_outlined,
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
              ),
              selectedIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.dashboard,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.settings_remote_outlined,
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
              ),
              selectedIcon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.settings_remote,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              label: 'Control',
            ),
          ],
        ),
      ),
    );
  }
}

