import 'package:flutter/material.dart';

import 'package:smart_campus/core/presentation/widgets/bottom_nav_bar.dart';
import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/activities/presentation/pages/activities_page.dart';
import 'package:smart_campus/features/announcements/presentation/pages/announcements_page.dart';
import 'package:smart_campus/features/home/presentation/pages/home_page.dart';
import 'package:smart_campus/features/settings/presentation/pages/settings_page.dart';

class AuthenticatedShell extends StatefulWidget {
  const AuthenticatedShell({super.key});

  @override
  State<AuthenticatedShell> createState() => _AuthenticatedShellState();
}

class _AuthenticatedShellState extends State<AuthenticatedShell> {
  NavTab _activeTab = NavTab.home;

  static const _tabBodies = <NavTab, Widget>{
    NavTab.home: HomePage(),
    NavTab.announcements: AnnouncementsPage(),
    NavTab.events: ActivitiesPage(),
    NavTab.settings: SettingsPage(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _activeTab.index,
        children: NavTab.values.map((t) => _tabBodies[t]!).toList(),
      ),
      bottomNavigationBar: BottomNavBar(
        activeTab: _activeTab,
        onTabChange: (tab) => setState(() => _activeTab = tab),
      ),
    );
  }
}

