import 'package:flutter/material.dart';
import 'package:frontend/styles/app_colors.dart';
import 'package:frontend/config/unread_badge.dart';

class BottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final bool isProductionCompany;

  const BottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
    this.isProductionCompany = false,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      onTap: onItemTapped,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: AppColors.textSecondary,
      backgroundColor: AppColors.white,
      elevation: 8,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: 'Search',
        ),
        if (isProductionCompany)
          const BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          )
        else
          BottomNavigationBarItem(
            icon: ValueListenableBuilder<bool>(
              valueListenable: unreadBadge.hasUnread,
              builder: (context, hasUnread, child) {
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.chat_bubble_outline),
                    if (hasUnread)
                      Positioned(
                        right: -1,
                        top: -1,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
            label: 'Chat',
          ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
