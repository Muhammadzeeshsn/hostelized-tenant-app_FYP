// lib/screens/home/home_shell.dart

import 'package:flutter/material.dart';
import 'tabs/home_tab.dart';
import '../invoices/invoices_screen.dart';
import '../services/services_screen.dart';
import '../mess/mess_screen.dart';
import '../account/account_details_screen.dart';

const _brandBlue = Color(0xFF003A60);

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 2; // Start with Home (center)
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<Widget> _screens = const [
    InvoicesScreen(),
    ServicesScreen(),
    HomeTab(),
    MessScreen(),
    AccountDetailsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _SimpleBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        animation: _animation,
      ),
      extendBody: true,
    );
  }
}

class _SimpleBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final Animation<double> animation;

  const _SimpleBottomNav({
    required this.currentIndex,
    required this.onTap,
    required this.animation,
  });

  // Calculate position for the elevated circle
  double _getElevatedPosition(BuildContext context, int index) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Positions for each icon
    final positions = [
      screenWidth * 0.1, // Icon 0 (10% from left)
      screenWidth * 0.3, // Icon 1 (30% from left)
      screenWidth * 0.5, // Icon 2 (50% - center)
      screenWidth * 0.7, // Icon 3 (70% from left)
      screenWidth * 0.9, // Icon 4 (90% from left)
    ];

    return positions[index] - 35; // Subtract half of circle width
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: _brandBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Bottom nav items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavIcon(
                icon: Icons.receipt_long_outlined,
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavIcon(
                icon: Icons.build_outlined,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavIcon(
                icon: Icons.home_rounded,
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavIcon(
                icon: Icons.restaurant_menu_outlined,
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavIcon(
                icon: Icons.account_balance_wallet_outlined,
                isActive: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),

          // Animated elevated circle that slides
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            top: -30,
            left: _getElevatedPosition(context, currentIndex),
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (animation.value * 0.1),
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: () => onTap(currentIndex),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: _brandBlue,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _brandBlue.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    _getIconForIndex(currentIndex),
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.receipt_long_outlined;
      case 1:
        return Icons.build_outlined;
      case 2:
        return Icons.home_rounded;
      case 3:
        return Icons.restaurant_menu_outlined;
      case 4:
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.home_rounded;
    }
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Icon(
          icon,
          color: isActive ? Colors.transparent : Colors.white.withOpacity(0.5),
          size: 28,
        ),
      ),
    );
  }
}
