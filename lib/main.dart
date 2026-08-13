import 'package:customer_care_webapp/pages/dashboard.dart';
import 'package:customer_care_webapp/routes/app_pages.dart';
import 'package:customer_care_webapp/utils/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/route_manager.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint(e.toString());
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1280, 585.3),
      minTextAdapt: true, // Text scaling support ke liye
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.pages,
          unknownRoute: GetPage(
            name: '/not-found',
            page: () =>
                const Scaffold(body: Center(child: Text("Page Not Found!"))),
          ),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          title: 'Campus Care Web',

          home: Dashboard(),
        );
      },
    );
  }
}
