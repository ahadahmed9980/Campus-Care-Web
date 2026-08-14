import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/widgets/charts/flchart.dart';
import 'package:customer_care_webapp/widgets/charts/piechart.dart';
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
    final textTheme = Theme.of(context).textTheme;
    final controller = Get.find<DashboardController>();

    return Scaffold(
      body: Column(
        children: [
          //notification row
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              height: 70,
              width: double.infinity,
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
                  const SizedBox(width: 16),
                  const Icon(Icons.notifications_active_outlined),
                  const SizedBox(width: 16),
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                // Card widgets definitions
                final totalRequestCard = statCardWidget(
                  context: context,
                  title: "Total Request",
                  value: "1248",
                  percentage: "0.5%",
                  icon: Icons.lock_outline,
                );
                final request2Card = statCardWidget(
                  context: context,
                  title: "Total Request",
                  value: "1248",
                  percentage: "0.5%",
                  icon: Icons.lock_outline,
                );
                final request3Card = statCardWidget(
                  context: context,
                  title: "Total Request",
                  value: "1248",
                  percentage: "0.5%",
                  icon: Icons.lock_outline,
                );
                final request4Card = statCardWidget(
                  context: context,
                  title: "Total Request",
                  value: "1248",
                  percentage: "0.5%",
                  icon: Icons.lock_outline,
                );

                // Determine stat cards layout based on parent constraints width
                Widget statCardsLayout;
                if (width >= 1024) {
                  statCardsLayout = Row(
                    children: [
                      Expanded(child: totalRequestCard),
                      const SizedBox(width: 16),
                      Expanded(child: request2Card),
                      const SizedBox(width: 16),
                      Expanded(child: request3Card),
                      const SizedBox(width: 16),
                      Expanded(child: request4Card),
                    ],
                  );
                } else if (width >= 480) {
                  statCardsLayout = Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: totalRequestCard),
                          const SizedBox(width: 16),
                          Expanded(child: request2Card),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: request3Card),
                          const SizedBox(width: 16),
                          Expanded(child: request4Card),
                        ],
                      ),
                    ],
                  );
                } else {
                  statCardsLayout = Column(
                    children: [
                      totalRequestCard,
                      const SizedBox(height: 16),
                      request2Card,
                      const SizedBox(height: 16),
                      request3Card,
                      const SizedBox(height: 16),
                      request4Card,
                    ],
                  );
                }

                // Determine charts layout
                final showChartsSideBySide = width >= 900;
                final chartsLayout = showChartsSideBySide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 6, child: RequestsOverviewCard()),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 4,
                            child: RequestsByCategoryCard(),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          RequestsOverviewCard(),
                          const SizedBox(height: 20),
                          RequestsByCategoryCard(),
                        ],
                      );

                return SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1600),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            // dashboard view of all activities header
                            Text("Dashboard", style: textTheme.headlineLarge),
                            const SizedBox(height: 4),
                            Text(
                              "Overview of all activities",
                              style: textTheme.labelLarge,
                            ),
                            const SizedBox(height: 24),
                            // responsive boxes
                            statCardsLayout,
                            const SizedBox(height: 24),
                            // chart
                            chartsLayout,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
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

  return Container(
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
        Expanded(
          child: Column(
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 4,
                runSpacing: 2,
                children: [
                  Icon(
                    isPositive
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    size: 13,
                    color: isPositive ? const Color(0xFF00875A) : Colors.red,
                  ),
                  Text(
                    percentage,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPositive ? const Color(0xFF00875A) : Colors.red,
                    ),
                  ),
                  Text(
                    'from last week',
                    style: textTheme.labelSmall?.copyWith(fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
