import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/utils/responseive.dart';
import 'package:customer_care_webapp/widgets/charts/flchart.dart';
import 'package:customer_care_webapp/widgets/charts/piechart.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Controller instance
  final controller = Get.find<DashboardController>();

  // Responsive layout builder helper for stat cards
  Widget _buildStatCards(double width, List<Widget> cards) {
    if (width >= 1024) {
      return Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 16),
          Expanded(child: cards[1]),
          const SizedBox(width: 16),
          Expanded(child: cards[2]),
          const SizedBox(width: 16),
          Expanded(child: cards[3]),
        ],
      );
    } else if (width >= 480) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 16),
              Expanded(child: cards[1]),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 16),
              Expanded(child: cards[3]),
            ],
          ),
        ],
      );
    } else {
      return Column(
        children: [
          cards[0],
          const SizedBox(height: 16),
          cards[1],
          const SizedBox(height: 16),
          cards[2],
          const SizedBox(height: 16),
          cards[3],
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          // Top Bar Header
          Obx(() {
            final isDark = controller.isDarkMode.value;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              height: 70,
              width: double.infinity,
              color: Theme.of(context).cardColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Theme Toggle Button
                  InkWell(
                    onTap: controller.toggleTheme,
                    child: Icon(
                      isDark ? Icons.dark_mode : Icons.sunny,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.notifications_active_outlined),
                  const SizedBox(width: 16),

                  // User Avatar & Online Status Dot
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
                              color: isDark ? Colors.black : const Color(0xFF0D1B2A),
                              width: 1.6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),

          // Main Scrollable Area
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;

                return Obx(() {
                  final isLoading = controller.isLoading.value;

                  // 1. Error State
                  if (controller.isError.value) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Unable to load dashboard data",
                            style: TextStyle(fontSize: 16, color: Colors.red),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => controller.loadDashboardData(),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    );
                  }

                  // 2. Prepare Cards (use dummy stats while loading to prevent null errors)
                  final stats = isLoading
                      ? {
                          'total': {'value': '99', 'percentage': '12.5%', 'isPositive': true},
                          'pending': {'value': '99', 'percentage': '5.0%', 'isPositive': false},
                          'active': {'value': '99', 'percentage': '8.2%', 'isPositive': true},
                          'resolved': {'value': '99', 'percentage': '15.4%', 'isPositive': true},
                        }
                      : controller.getStats();

                  final cardsList = [
                    statCardWidget(
                      context: context,
                      title: "Total Requests",
                      value: stats['total']['value']!,
                      percentage: stats['total']['percentage']!,
                      icon: Icons.all_inbox_rounded,
                      isPositive: stats['total']['isPositive'] as bool? ?? true,
                    ),
                    statCardWidget(
                      context: context,
                      title: "Pending Requests",
                      value: stats['pending']['value']!,
                      percentage: stats['pending']['percentage']!,
                      icon: Icons.hourglass_empty_rounded,
                      isPositive: stats['pending']['isPositive'] as bool? ?? false,
                    ),
                    statCardWidget(
                      context: context,
                      title: "Active Requests",
                      value: stats['active']['value']!,
                      percentage: stats['active']['percentage']!,
                      icon: Icons.play_arrow_outlined,
                      isPositive: stats['active']['isPositive'] as bool? ?? true,
                    ),
                    statCardWidget(
                      context: context,
                      title: "Resolved Requests",
                      value: stats['resolved']['value']!,
                      percentage: stats['resolved']['percentage']!,
                      icon: Icons.check_circle_outline_rounded,
                      isPositive: stats['resolved']['isPositive'] as bool? ?? true,
                    ),
                  ];

                  final isWideScreen = screenWidth >= 900;
                  final isMobile = Responsive.isMobileScreen(context);

                  return Skeletonizer(
                    enabled: isLoading,
                    child: SingleChildScrollView(
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

                              // Screen Title Header
                              if (!isMobile) ...[
                                Text("Dashboard", style: textTheme.headlineLarge),
                                const SizedBox(height: 4),
                                Text(
                                  "Overview of all activities",
                                  style: textTheme.labelLarge,
                                ),
                                const SizedBox(height: 24),
                              ],

                              // KPI Cards Layout
                              _buildStatCards(screenWidth, cardsList)
                                  .animate()
                                  .fadeIn(duration: 500.ms)
                                  .slideY(begin: 0.1, end: 0, duration: 500.ms),
                              const SizedBox(height: 24),

                              // Charts Section
                              if (isWideScreen)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: const RequestsOverviewCard()
                                          .animate()
                                          .fadeIn(delay: 200.ms, duration: 500.ms)
                                          .slideX(begin: -0.05, end: 0, duration: 500.ms),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      flex: 4,
                                      child: const RequestsByCategoryCard()
                                          .animate()
                                          .fadeIn(delay: 400.ms, duration: 500.ms)
                                          .slideX(begin: 0.05, end: 0, duration: 500.ms),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const RequestsOverviewCard()
                                        .animate()
                                        .fadeIn(duration: 500.ms)
                                        .slideY(begin: 0.05, end: 0, duration: 500.ms),
                                    const SizedBox(height: 20),
                                    const RequestsByCategoryCard()
                                        .animate()
                                        .fadeIn(delay: 200.ms, duration: 500.ms)
                                        .slideY(begin: 0.05, end: 0, duration: 500.ms),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ));
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

// KPI Item Component
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
  final trendColor = isPositive ? const Color(0xFF00875A) : Colors.red;

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
        // Leading Icon Box
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

        // Text & Metric Values
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
                    color: trendColor,
                  ),
                  Text(
                    percentage,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: trendColor,
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