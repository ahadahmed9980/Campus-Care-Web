import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    final controller = Get.find<DashboardController>();

    return Scaffold(
      body: Column(
        children: [
          //notification row
          Obx(
            () => Container(
              padding: const EdgeInsets.all(10),
              height: size.height * 0.10,
              width: size.width,
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      controller.toggleTheme();
                    },
                    child: Icon(
                      controller.isDarkMode.value
                          ? Icons.dark_mode
                          : Icons.sunny,
                      color: controller.isDarkMode.value
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.notifications_active_outlined),
                  const SizedBox(width: 10),
                  //profile
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
                              color: controller.isDarkMode.value
                                  ? Colors.black
                                  : const Color(0xFF0D1B2A),
                              width: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // main dashboard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.01),
                  // dashboard view of all activities
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Dashboard", style: textTheme.headlineLarge),
                          SizedBox(height: size.height * 0.001),
                          Text(
                            "Overview of all activities",
                            style: textTheme.labelLarge,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.02),
                  //boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      statCardWidget(
                        context: context,
                        title: "Total Request",
                        value: "1248",
                        percentage: "0.5%",
                        icon: Icons.lock_outline,
                      ),
                      statCardWidget(
                        context: context,
                        title: "Total Request",
                        value: "1248",
                        percentage: "0.5%",
                        icon: Icons.lock_outline,
                      ),
                      statCardWidget(
                        context: context,
                        title: "Total Request",
                        value: "1248",
                        percentage: "0.5%",
                        icon: Icons.lock_outline,
                      ),
                      statCardWidget(
                        context: context,
                        title: "Total Request",
                        value: "1248",
                        percentage: "0.5%",
                        icon: Icons.lock_outline,
                      ),
                    ],
                  ),

                  //chart
              
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget statCardWidget({
  required BuildContext context,
  required String title,
  required String value,
  required String percentage,
  required IconData icon,
  bool isPositive = true,
}) {
  final textTheme = Theme.of(context).textTheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final size = MediaQuery.of(context).size;

  return Container(
    width: size.width * 0.19,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha(10),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Icon Box
        Container(
          width: 52,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(width: 16),

        // Right Text Details
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.grey : const Color(0xFF5E6C84),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : const Color(0xFF172B4D),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  isPositive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 13,
                  color: isPositive ? const Color(0xFF00875A) : Colors.red,
                ),
                const SizedBox(width: 3),
                Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? const Color(0xFF00875A) : Colors.red,
                  ),
                ),
                const SizedBox(width: 4),
                Text('from last week', style: textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
