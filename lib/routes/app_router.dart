import 'package:customer_care_webapp/bindings/request_binding.dart';
import 'package:customer_care_webapp/bindings/request_detail_binding.dart';
import 'package:customer_care_webapp/pages/dashboard.dart';
import 'package:customer_care_webapp/pages/main_page.dart';
import 'package:customer_care_webapp/pages/request_detail.dart';
import 'package:customer_care_webapp/pages/requests.dart';
import 'package:go_router/go_router.dart';

final appRouter = GoRouter(
  initialLocation: '/dashboard',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return MainPage(child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) {
            return Dashboard();
          },
        ),
        GoRoute(
          path: '/requests',

          builder: (context, state) {
            RequestBinding().dependencies();
            return Requests();
          },
        ),
        GoRoute(
          path: '/request-details',
       

          builder: (context, state) {
            RequestDetailBinding().dependencies();
            return RequestDetail();
          },
        ),

        //     GoRoute(
        //       path: '/users',
        //       builder: (context, state) {
        //         return UsersPage();
        //       },
        //     ),
        //     GoRoute(
        //       path: '/announcements',
        //       builder: (context, state) {
        //         return AnnouncementsPage();
        //       },
        //     ),
        //     GoRoute(
        //       path: '/campus-information',
        //       builder: (context, state) {
        //         return CampusInformationPage();
        //       },
        //     ),
        //     GoRoute(
        //       path: '/categories',
        //       builder: (context, state) {
        //         return CategoriesPage();
        //       },
        //     ),
        //     GoRoute(
        //       path: '/reports',
        //       builder: (context, state) {
        //         return ReportsPage();
        //       },
        //     ),
        //     GoRoute(
        //       path: '/notifications',
        //       builder: (context, state) {
        //         return NotificationsPage();
        //       },
        //     ),
        //     GoRoute(
        //       path: '/settings',
        //       builder: (context, state) {
        //         return SettingsPage();
        //       },
        //     ),
      ],
      // ),
    ),
  ],
);
