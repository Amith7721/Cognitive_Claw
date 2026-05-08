import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CCBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CCBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1B2E) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFF6B4EE6).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4EE6).withValues(alpha: 0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: const Color(0xFF00F2FE),
          unselectedItemColor: isDark ? Colors.white54 : Colors.black54,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), activeIcon: Icon(Icons.home_rounded, size: 28), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), activeIcon: Icon(Icons.assignment_rounded, size: 28), label: 'Briefs'),
            BottomNavigationBarItem(icon: Icon(Icons.task_alt_rounded), activeIcon: Icon(Icons.task_alt_rounded, size: 28), label: 'Tasks'),
            BottomNavigationBarItem(icon: Icon(Icons.science_rounded), activeIcon: Icon(Icons.science_rounded, size: 28), label: 'Research'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), activeIcon: Icon(Icons.settings_rounded, size: 28), label: 'Settings'),
          ],
        ),
      ),
    ).animate().slideY(begin: 1, duration: 600.ms, curve: Curves.easeOutBack);
  }
}
