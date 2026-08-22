import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/widgets/customDropdownButton.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestsOverviewCard extends StatelessWidget {
  const RequestsOverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.find<DashboardController>();

    return Obx(() {
      final spots = controller.getLineChartSpots();
      final timeframe = controller.selectedTimeframe.value;
      final maxY = controller.getLineChartMaxY();

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
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Requests Overview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                ),
                // Timeframe Selector Dropdown
                SizedBox(
                  width: 140,
                  child: customFormDownbutton(
                    context: context,
                    selectedValue: controller.selectedTimeframeString,
                    items: controller.timeframeOptions,
                    onChanged: (value) {
                      if (value != null) {
                        final days = int.parse(value.split(' ')[0]);
                        controller.selectedTimeframe.value = days;
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Chart / Empty State handling
            if (spots.isEmpty || controller.currentRequests.isEmpty)
              SizedBox(
                height: size.height / 2.5,
                child: Center(
                  child: Text(
                    "No requests available",
                    style: TextStyle(
                      color: isDark ? AppColors.grey : Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: 220,
                  maxHeight: 350,
                ),
                child: SizedBox(
                  height: size.height / 2.5,
                  child: LineChart(
                    LineChartData(
                      minX: 0,
                      maxX: (timeframe - 1).toDouble(),
                      minY: 0,
                      maxY: maxY,
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            interval: (maxY / 4) > 0 ? (maxY / 4) : 1,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 11,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                            interval: timeframe == 7 ? 1 : (timeframe == 14 ? 2 : 5),
                            getTitlesWidget: (value, meta) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  controller.getLineChartLabel(value),
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          curveSmoothness: 0.35,
                          color: const Color(0xFF0F8A5F),
                          barWidth: 2.5,
                          isStrokeCapRound: true,
                          // Points / Dots
                          dotData: FlDotData(
                            show: timeframe <= 14, // Hide dots on 30 days to avoid clutter
                            getDotPainter: (spot, percent, barData, index) {
                              return FlDotCirclePainter(
                                radius: 3.5,
                                color: const Color(0xFF0F8A5F),
                                strokeWidth: 0,
                              );
                            },
                          ),
                          // Gradient under line
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                const Color(0xFF0F8A5F).withValues(alpha: 0.18),
                                const Color(0xFF0F8A5F).withValues(alpha: 0.01),
                              ],
                            ),
                          ),
                          spots: spots,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}
