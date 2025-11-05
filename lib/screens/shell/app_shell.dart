import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _brand = Color(0xFF003A60);

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});

  void _goBranch(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final idx = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _BottomBar(
        currentIndex: idx,
        onTap: (i) => _goBranch(context, i),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _BottomBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // order: dashboard(2) centered, others around
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // dark ribbon
        Container(
          height: 76,
          decoration: const BoxDecoration(
            color: _brand,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Item(
                icon: Icons.grid_view_rounded,
                label: 'Dashboard',
                selected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _Item(
                icon: Icons.build_rounded,
                label: 'Services',
                selected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              const SizedBox(width: 64), // hole for floating home
              _Item(
                icon: Icons.receipt_long_rounded,
                label: 'Fees',
                selected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              _Item(
                icon: Icons.person_outline_rounded,
                label: 'Profile',
                selected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
        // raised home
        Positioned(
          bottom: 32,
          child: GestureDetector(
            onTap: () => onTap(2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: currentIndex == 2 ? _brand : Colors.white,
                  width: 3,
                ),
              ),
              child: Icon(
                Icons.home_rounded,
                size: currentIndex == 2 ? 32 : 28,
                color: _brand,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Item({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(selected ? 1 : .7),
              size: selected ? 26 : 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: selected ? 12 : 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: Colors.white.withOpacity(selected ? 1 : .8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
