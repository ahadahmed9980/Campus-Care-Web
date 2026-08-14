import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class RequestsByCategoryCard extends StatelessWidget {
  const RequestsByCategoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          LayoutBuilder(
            builder: (context, constraints) {
              final useVerticalLayout = constraints.maxWidth < 320;
              final pieChartWidget = SizedBox(
                width: 140,
                height: 140,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 38,
                    startDegreeOffset: -90,
                    borderData: FlBorderData(show: false),
                    sections: [
                      PieChartSectionData(
                        value: 40,
                        color: const Color(0xFF0D56B3),
                        showTitle: false,
                        radius: 30,
                      ),
                      PieChartSectionData(
                        value: 20,
                        color: const Color(0xFF139655),
                        showTitle: false,
                        radius: 30,
                      ),
                      PieChartSectionData(
                        value: 15,
                        color: const Color(0xFFEAA612),
                        showTitle: false,
                        radius: 30,
                      ),
                      PieChartSectionData(
                        value: 12,
                        color: const Color(0xFF4A90E2),
                        showTitle: false,
                        radius: 30,
                      ),
                      PieChartSectionData(
                        value: 13,
                        color: const Color(0xFFA1AAB7),
                        showTitle: false,
                        radius: 30,
                      ),
                    ],
                  ),
                ),
              );

              final legendWidget = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LegendItem(
                    color: const Color(0xFF0D56B3),
                    title: 'Maintenance',
                    stat: '28% (350)',
                    titleColor: isDark
                        ? AppColors.darkText
                        : AppColors.lightText,
                  ),
                  const SizedBox(height: 10),
                  _LegendItem(
                    color: const Color(0xFF139655),
                    title: 'Electricity',
                    stat: '20% (250)',
                    titleColor: isDark
                        ? AppColors.darkText
                        : AppColors.lightText,
                  ),
                  const SizedBox(height: 10),
                  _LegendItem(
                    color: const Color(0xFFEAA612),
                    title: 'Plumbing',
                    stat: '15% (187)',
                    titleColor: isDark
                        ? AppColors.darkText
                        : AppColors.lightText,
                  ),
                  const SizedBox(height: 10),
                  _LegendItem(
                    color: const Color(0xFF4A90E2),
                    title: 'Cleaning',
                    stat: '12% (150)',
                    titleColor: isDark
                        ? AppColors.darkText
                        : AppColors.lightText,
                  ),
                  const SizedBox(height: 10),
                  _LegendItem(
                    color: const Color(0xFFA1AAB7),
                    title: 'Other',
                    stat: '13% (163)',
                    titleColor: isDark
                        ? AppColors.darkText
                        : AppColors.lightText,
                  ),
                ],
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
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String title;
  final String stat;
  final Color? titleColor; // Naya parameter
  final Color? statColor; // Naya parameter

  const _LegendItem({
    required this.color,
    required this.title,
    required this.stat,
    this.titleColor,
    this.statColor,
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
              // Yahan text color set hoga (default black87 rahega)
              color: titleColor ?? Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          stat,
          style: TextStyle(
            fontSize: 11,
            // Yahan stat ka color set hoga
            color: statColor ?? Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
