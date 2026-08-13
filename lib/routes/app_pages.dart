import 'package:customer_care_webapp/pages/dashboard.dart';
import 'package:customer_care_webapp/routes/app_routes.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';

class AppPages {
  static const INITIAL = Routes.DASHBOARD;
  static final pages = [
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const Dashboard(),
      transition: Transition.fadeIn, // Optional Transition Effect
    ),
  ];
}
