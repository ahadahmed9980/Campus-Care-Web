import 'package:customer_care_webapp/bindings/all_users_binding.dart';
import 'package:customer_care_webapp/bindings/announcement_binding.dart';
import 'package:customer_care_webapp/bindings/campus_binding.dart';
import 'package:customer_care_webapp/bindings/department_binding.dart';
import 'package:customer_care_webapp/bindings/requestCategory_binding.dart';
import 'package:customer_care_webapp/bindings/request_binding.dart';
import 'package:customer_care_webapp/bindings/request_detail_binding.dart';
import 'package:customer_care_webapp/pages/all_users.dart';
import 'package:customer_care_webapp/pages/announcements.dart';
import 'package:customer_care_webapp/pages/campus_info.dart';
import 'package:customer_care_webapp/pages/department.dart';
import 'package:customer_care_webapp/pages/requestCategories.dart';
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
          path: '/request/:requestId',

          builder: (context, state) {
            final requestId = state.pathParameters['requestId']!;
            RequestDetailBinding().dependencies();
            return RequestDetail(
                requestId: requestId,
            );
          },
        ),

        GoRoute(
          path: '/users',
          builder: (context, state) {
            AllUsersBinding().dependencies();
            return AllUsers();
          },
        ),
        GoRoute(
          path: '/announcements',
          builder: (context, state) {
            AnnouncementBinding().dependencies();
            return Announcements();
          },
        ),
        GoRoute(
          path: '/campus-information',
          builder: (context, state) {
            CampusBinding().dependencies();
            return CampusInfo();
          },
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) {
            RequestcategoryBinding().dependencies();
            return requestCategories();
          },
        ),
        GoRoute(
          path: '/departments',

          builder: (context, state) {
            CampusBinding().dependencies();

            DepartmentBinding().dependencies();
            return Department();
          },
        ),
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
