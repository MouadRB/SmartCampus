import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:smart_campus/core/presentation/widgets/app_top_bar.dart';
import 'package:smart_campus/core/presentation/widgets/bottom_nav_bar.dart';
import 'package:smart_campus/core/theme/app_theme.dart';
import 'package:smart_campus/features/announcements/presentation/pages/announcements_page.dart';
import 'package:smart_campus/features/home/presentation/pages/home_page.dart';

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
    NavTab.events: _ComingSoonStub(title: 'Events'),
    NavTab.settings: _ComingSoonStub(title: 'Settings'),
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

class _ComingSoonStub extends StatelessWidget {
  const _ComingSoonStub({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppTopBar(title: title),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.construction_outlined,
                size: 32.r,
                color: AppColors.textTertiary,
              ),
              SizedBox(height: 16.h),
              Text(
                '$title coming soon',
                style: AppTextStyles.sectionHeader,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'This screen will be wired up in a future sprint.',
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
