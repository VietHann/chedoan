import 'package:flutter/material.dart';

import '../app_theme.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomBottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Material(
      elevation: 8.0,
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Trang chủ',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.insert_chart_outlined),
                  activeIcon: Icon(Icons.insert_chart),
                  label: 'Thống kê',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: 'Hồ sơ',
                ),
              ],
              currentIndex: selectedIndex,
              selectedItemColor: AppTheme.primaryColor,
              unselectedItemColor: AppTheme.secondaryTextColor,
              backgroundColor: Colors.white,
              onTap: onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              elevation: 0,
            ),
            SizedBox(height: bottomPadding),
          ],
        ),
      ),
    );
  }
}
