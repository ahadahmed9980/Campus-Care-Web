import 'package:customer_care_webapp/utils/responseive.dart';
import 'package:customer_care_webapp/widgets/campus_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';

class MainPage extends StatefulWidget {
  final Widget child;

  const MainPage({super.key, required this.child});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late final SidebarXController _controller;

  @override
  void initState() {
    super.initState();

    _controller = SidebarXController(selectedIndex: 0, extended: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/request')) return 1;

    if (location.startsWith('/users')) return 2;

    if (location.startsWith('/announcements')) return 3;
    if (location.startsWith('/campus-information')) return 4;
    if (location.startsWith('/categories')) return 5;
    if (location.startsWith('/departments')) return 6;
    if (location.startsWith('/notifications')) return 7;
    if (location.startsWith('/settings')) return 8;

    return 0;
  }

  String _getTitle(String location) {
    if (location.startsWith('/request')) return 'Requests';

    if (location.startsWith('/users')) return 'Users';
    if (location.startsWith('/announcements')) return 'Announcements';
    if (location.startsWith('/campus-information')) {
      return 'Campus Information';
    }
    if (location.startsWith('/categories')) return 'Categories';
    if (location.startsWith('/departments')) return 'Departments';
    if (location.startsWith('/notifications')) return 'Notifications';
    if (location.startsWith('/settings')) return 'Settings';

    return 'Dashboard';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobileScreen(context);
    final isTablet = Responsive.isTabletScreen(context);

    final location = GoRouterState.of(context).uri.path;

    final calculatedIndex = _calculateSelectedIndex(context);

    if (_controller.selectedIndex != calculatedIndex) {
      _controller.selectIndex(calculatedIndex);
    }

    final targetExtended = !isMobile && !isTablet;

    if (_controller.extended != targetExtended) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _controller.setExtended(targetExtended);
        }
      });
    }

    final showMobileLayout = isMobile || isTablet;

    return Scaffold(
      appBar: showMobileLayout
          ? AppBar(
              title: Text(
                _getTitle(location),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              leading: Builder(
                builder: (context) {
                  return IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                  );
                },
              ),
              elevation: 0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            )
          : null,

      drawer: showMobileLayout
          ? Drawer(
              width: 250,
              backgroundColor: const Color(0xFF081522),
              child: CampusSidebar(controller: _controller),
            )
          : null,

      body: Row(
        children: [
          if (!showMobileLayout) CampusSidebar(controller: _controller),

          Expanded(child: widget.child),
        ],
      ),
    );
  }
}
