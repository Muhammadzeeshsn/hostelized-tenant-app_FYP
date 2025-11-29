// lib/screens/home/home_shell.dart

import 'package:flutter/material.dart';

import 'tabs/services_tab.dart' as services;
import 'tabs/home_tab.dart' as home;
import 'tabs/fees_tab.dart' as fees;
import 'tabs/profile_tab.dart' as profile;

import '../../widgets/app_bottom_nav.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 1; // start from Home tab

  late final List<Widget> _pages = [
    const services.ServicesTab(), // 0
    const home.HomeTab(), // 1 (center)
    const fees.FeesTab(), // 2
    const profile.ProfileTab(), // 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      body: SafeArea(
        child: IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: AppBottomNav(
        index: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}
