import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/routes/app_router.dart';
import 'package:customer_care_webapp/services/notification_service.dart';
import 'package:customer_care_webapp/utils/app_keys.dart';
import 'package:customer_care_webapp/utils/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';

import 'firebase_options.dart';

void main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint(e.toString());
  }

  try {
    await Get.putAsync(() => NotificationService().init());
  } catch (e) {
    debugPrint('NotificationService init failed: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Obx(
      () => MaterialApp.router(
        routerConfig: appRouter,
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: controller.isDarkMode.value
            ? ThemeMode.dark
            : ThemeMode.light,
        title: 'Campus Care Web',
      ),
    );
  }
}
