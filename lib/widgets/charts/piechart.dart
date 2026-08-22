import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestsByCategoryCard extends StatelessWidget {
  const RequestsByCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final categoryStats = controller.getCategoryStats();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Requests by Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (categoryStats.isEmpty)
              const SizedBox(
                height: 140,
                child: Center(
                  child: Text(
                    "No category data available",
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final useVerticalLayout = constraints.maxWidth < 320;

                  // Pie Chart sections mapping
                  final List<PieChartSectionData> sections = categoryStats.map((stat) {
                    return PieChartSectionData(
                      value: (stat['percentage'] as double),
                      color: stat['color'] as Color,
                      showTitle: false,
                      radius: 30,
                    );
                  }).toList();

                  final pieChartWidget = SizedBox(
                    width: 140,
                    height: 140,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 38,
                        startDegreeOffset: -90,
                        borderData: FlBorderData(show: false),
                        sections: sections,
                      ),
                    ),
                  );

                  // Legend items mapping
                  final legendWidget = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: categoryStats.map((stat) {
                      final percentageStr = (stat['percentage'] as double).toStringAsFixed(0);
                      final count = stat['count'] as int;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _LegendItem(
                          color: stat['color'] as Color,
                          title: stat['name'] as String,
                          stat: "$percentageStr% ($count)",
                          titleColor: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      );
                    }).toList(),
                  );

                  if (useVerticalLayout) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(child: pieChartWidget),
                        const SizedBox(height: 20),
                        legendWidget,
                      ],
                    );
                  } else {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        pieChartWidget,
                        const SizedBox(width: 20),
                        Expanded(
                          child: legendWidget,
                        ),
                      ],
                    );
                  }
                },
              ),
          ],
        ),
      );
    });
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String title;
  final String stat;
  final Color? titleColor;

  const _LegendItem({
    required this.color,
    required this.title,
    required this.stat,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: titleColor ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          stat,
          style: const TextStyle(
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
