import 'package:flutter/material.dart';

// Use prefixes to avoid conflicts:
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
  int _index = 0;

  late final List<Widget> _pages = [
    const services.ServicesTab(),
    const home.HomeTab(),
    const fees.FeesTab(),
    const profile.ProfileTab(),
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
