import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/utils/responseive.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sidebarx/sidebarx.dart';

class CampusSidebar extends StatelessWidget {
  final SidebarXController controller;

  const CampusSidebar({super.key, required this.controller});

  void _handleNavigation(BuildContext context, String route) {
    context.go(route);
    final scaffoldState = Scaffold.maybeOf(context);
    if (scaffoldState != null && scaffoldState.isDrawerOpen) {
      scaffoldState.closeDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = Responsive.isMobileScreen(context);
    
    // Dynamic width clamping to ensure usability at all screen resolutions
    final collapsedWidth = isMobile ? 80.0 : (size.width * 0.065).clamp(70.0, 120.0);
    final extendedWidth = isMobile ? 250.0 : (size.width * 0.18).clamp(200.0, 300.0);

    return SidebarX(
      controller: controller,
      theme: SidebarXTheme(
        width: collapsedWidth,
        margin: const EdgeInsets.all(2),
        decoration: const BoxDecoration(
          color: Color(0xFF081522),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15),
            bottomLeft: Radius.circular(15),
          ),
        ),
        textStyle: const TextStyle(color: Colors.white70, fontSize: 14),
        selectedTextStyle: const TextStyle(color: Colors.white),
        itemPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        selectedItemPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        itemMargin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        selectedItemMargin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        itemTextPadding: const EdgeInsets.only(left: 12),
        selectedItemTextPadding: const EdgeInsets.only(left: 12),
        selectedItemDecoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        iconTheme: const IconThemeData(color: Colors.white70, size: 20),
        selectedIconTheme: const IconThemeData(color: Colors.white, size: 20),
      ),
      extendedTheme: SidebarXTheme(width: extendedWidth),
      headerBuilder: (context, extended) {
        return Padding(
          padding: const EdgeInsets.only(
            top: 24,
            bottom: 20,
            left: 16,
            right: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                "assets/images/logo.png",
                width: isMobile ? 40.0 : (size.width * 0.0391).clamp(32.0, 60.0),
              ),
              if (extended) ...[
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Campus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Care',
                            style: TextStyle(
                              color: Color(0xFF00A86B),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Admin Portal',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
   
      items: [
        SidebarXItem(
          icon: Icons.home_outlined,
          label: 'Dashboard',
          onTap: () => _handleNavigation(context, '/dashboard'),
        ),
        SidebarXItem(
          icon: Icons.assignment_outlined,
          label: 'Requests',
          onTap: () => _handleNavigation(context, '/requests'),
        ),
        SidebarXItem(
          icon: Icons.people_outline,
          label: 'Users',
          onTap: () => _handleNavigation(context, '/users'),
        ),
        SidebarXItem(
          icon: Icons.campaign_outlined,
          label: 'Announcements',
          onTap: () => _handleNavigation(context, '/announcements'),
        ),
        SidebarXItem(
          icon: Icons.domain_outlined,
          label: 'Campus Information',
          onTap: () => _handleNavigation(context, '/campus-information'),
        ),
        SidebarXItem(
          icon: Icons.category_outlined,
          label: 'Categories',
          onTap: () => _handleNavigation(context, '/categories'),
        ),
        SidebarXItem(
          icon: Icons.insert_chart_outlined,
          label: 'Reports',
          onTap: () => _handleNavigation(context, '/reports'),
        ),
        SidebarXItem(
          icon: Icons.notifications_none_outlined,
          label: 'Notifications',
          onTap: () => _handleNavigation(context, '/notifications'),
        ),
        SidebarXItem(
          icon: Icons.settings_outlined,
          label: 'Settings',
          onTap: () => _handleNavigation(context, '/settings'),
        ),
      ],
      footerBuilder: (context, extended) {
        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white12, width: 1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?img=12',
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00A86B),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF0D1B2A),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              if (extended) ...[
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Admin User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Super Admin',
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white54,
                  size: 18,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}