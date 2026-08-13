import 'package:customer_care_webapp/widgets/campus_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';

class MainPage extends StatelessWidget {
  final Widget child;

  MainPage({
    super.key,
    required this.child,
  });

  final SidebarXController _controller = SidebarXController(
    selectedIndex: 1,
    extended: true,
  );


  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/requests')) return 1;
    if (location.startsWith('/users')) return 2;
    if (location.startsWith('/announcements')) return 3;
    if (location.startsWith('/campus-information')) return 4;
    if (location.startsWith('/categories')) return 5;
    if (location.startsWith('/reports')) return 6;
    if (location.startsWith('/notifications')) return 7;
    if (location.startsWith('/settings')) return 8;
    return 0; // Default /dashboard
  }

  @override
  Widget build(BuildContext context) {
    _controller.selectIndex(_calculateSelectedIndex(context));

    return Scaffold(
      body: Row(
        children: [
          CampusSidebar(
            controller: _controller,
          ),
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}