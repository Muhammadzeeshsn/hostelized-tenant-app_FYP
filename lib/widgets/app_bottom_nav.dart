// lib/widgets/app_bottom_nav.dart

import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const AppBottomNav({super.key, required this.index, required this.onTap});

  static const _bg = Color(0xFF003A60);
  static const _iconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _item(
                context,
                0,
                Icons.miscellaneous_services_outlined,
                'Services',
              ),
              _item(context, 2, Icons.receipt_long_outlined, 'Fees'),
              _item(context, 3, Icons.person_outline, 'Profile'),
            ],
          ),
          Positioned(
            top: -18,
            child: InkWell(
              onTap: () => onTap(1), // center = Home, index 1
              borderRadius: BorderRadius.circular(40),
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: _bg,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.home_filled,
                    size: _iconSize + 6,
                    color: _bg,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, int i, IconData icon, String label) {
    final active = i == index;
    return InkWell(
      onTap: () => onTap(i),
      child: SizedBox(
        width: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: _iconSize,
              color: Colors.white.withOpacity(active ? 1 : .7),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(active ? 1 : .7),
                fontSize: active ? 12.5 : 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
