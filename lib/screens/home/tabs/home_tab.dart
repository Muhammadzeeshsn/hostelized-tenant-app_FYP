// lib/screens/home/tabs/home_tab.dart
import 'package:flutter/material.dart';
import '../home_screen.dart';

/// This simply bridges the shell/tab system to the actual home UI.
class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Render the new HomeScreen (complete UI with notifications, dues, etc.)
    return const HomeScreen();
  }
}
