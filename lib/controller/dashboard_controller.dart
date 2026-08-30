import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer_care_webapp/models/request_Category_model.dart';
import 'package:customer_care_webapp/models/request_model.dart';
import 'package:customer_care_webapp/services/fetch_request_service.dart';
import 'package:customer_care_webapp/services/request_Categories_Service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardController extends GetxController {
  // Theme state
  final isDarkMode = false.obs;

  // Selected filter (days)
  var selectedTimeframe = 7.obs;
  final selectedTimeframeString = "7 Days".obs;
  final timeframeOptions = ["7 Days", "14 Days", "30 Days"].obs;

  // Screen states
  var isLoading = false.obs;
  var isError = false.obs;

  // Data lists
  RxList<RequestModel> allRequests = <RequestModel>[].obs;
  RxList<RequestCategoryModel> categories = <RequestCategoryModel>[].obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _requestsSub;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
    selectedTimeframeString.listen((val) {
      final days = int.parse(val.split(' ')[0]);
      selectedTimeframe.value = days;
    });
    _listenToRequests();
    loadDashboardData();
  }

  @override
  void onClose() {
    _requestsSub?.cancel();
    super.onClose();
  }

  void _listenToRequests() {
    _requestsSub?.cancel();
    _requestsSub = FetchRequestService().watchAllRequests().listen(
      (snapshot) {
        allRequests.assignAll(
          snapshot.docs.map(
            (doc) => RequestModel.fromMap(doc.data(), doc.id),
          ),
        );
        isLoading.value = false;
        isError.value = false;
      },
      onError: (e) {
        debugPrint("Error listening to requests: $e");
        isError.value = true;
        isLoading.value = false;
      },
    );
  }

  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      isDarkMode.value = prefs.getBool('isDarkMode') ?? false;
    } catch (e) {
      debugPrint("Error loading theme from prefs: $e");
    }
  }

  // Toggle dark/light theme
  Future<void> toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', isDarkMode.value);
    } catch (e) {
      debugPrint("Error saving theme to prefs: $e");
    }
  }

  // Fetch categories (requests stream updates live via _listenToRequests)
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;
      isError.value = false;

      final categoriesSnapshot =
          await RequestCategoriesService().fetchAllCategories();
      final List<RequestCategoryModel> tempCats = [];
      for (var doc in categoriesSnapshot.docs) {
        tempCats.add(RequestCategoryModel.fromMap(doc.data(), docId: doc.id));
      }

      categories.assignAll(tempCats);
    } catch (e) {
      debugPrint("Error loading dashboard data: $e");
      isError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // Date range helpers
  DateTime get currentPeriodStart {
    final days = selectedTimeframe.value;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.subtract(Duration(days: days - 1));
  }

  DateTime get currentPeriodEnd {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  DateTime get previousPeriodStart {
    final days = selectedTimeframe.value;
    return currentPeriodStart.subtract(Duration(days: days));
  }

  DateTime get previousPeriodEnd {
    return currentPeriodStart.subtract(const Duration(seconds: 1));
  }

  // Filter requests for active range
  List<RequestModel> get currentRequests {
    final start = currentPeriodStart;
    final end = currentPeriodEnd;

    final List<RequestModel> list = [];
    for (var r in allRequests) {
      if (r.createdAt != null) {
        final date = r.createdAt!.toDate();
        if (date.isAfter(start) && date.isBefore(end)) {
          list.add(r);
        }
      }
    }
    return list;
  }

  // Filter requests for previous comparison range
  List<RequestModel> get previousRequests {
    final start = previousPeriodStart;
    final end = previousPeriodEnd;

    final List<RequestModel> list = [];
    for (var r in allRequests) {
      if (r.createdAt != null) {
        final date = r.createdAt!.toDate();
        if (date.isAfter(start) && date.isBefore(end)) {
          list.add(r);
        }
      }
    }
    return list;
  }

  // Percentage change calculator
  double _calculateGrowth(int current, int previous) {
    if (previous == 0) {
      return current > 0 ? 100.0 : 0.0;
    }
    return ((current - previous) / previous) * 100;
  }

  // Calculate card numbers and badges
  Map<String, dynamic> getStats() {
    final cur = currentRequests;
    final prev = previousRequests;

    int curTotal = cur.length;
    int prevTotal = prev.length;

    int curPending = 0;
    int prevPending = 0;

    int curActive = 0;
    int prevActive = 0;

    int curResolved = 0;
    int prevResolved = 0;

    // Count current
    for (var item in cur) {
      final statusLower = item.status.trim().toLowerCase();
      if (statusLower == 'submitted' || statusLower == 'under review') {
        curPending++;
      } else if (statusLower == 'in progress') {
        curActive++;
      } else if (statusLower == 'resolved') {
        curResolved++;
      }
    }

    // Count previous
    for (var item in prev) {
      final statusLower = item.status.trim().toLowerCase();
      if (statusLower == 'submitted' || statusLower == 'under review') {
        prevPending++;
      } else if (statusLower == 'in progress') {
        prevActive++;
      } else if (statusLower == 'resolved') {
        prevResolved++;
      }
    }

    return {
      'total': {
        'value': '$curTotal',
        'percentage': '${_calculateGrowth(curTotal, prevTotal).toStringAsFixed(1)}%',
        'isPositive': curTotal >= prevTotal,
      },
      'pending': {
        'value': '$curPending',
        'percentage': '${_calculateGrowth(curPending, prevPending).toStringAsFixed(1)}%',
        'isPositive': curPending >= prevPending,
      },
      'active': {
        'value': '$curActive',
        'percentage': '${_calculateGrowth(curActive, prevActive).toStringAsFixed(1)}%',
        'isPositive': curActive >= prevActive,
      },
      'resolved': {
        'value': '$curResolved',
        'percentage': '${_calculateGrowth(curResolved, prevResolved).toStringAsFixed(1)}%',
        'isPositive': curResolved >= prevResolved,
      },
    };
  }

  // Line chart spots mapping
  List<FlSpot> getLineChartSpots() {
    final days = selectedTimeframe.value;
    final start = currentPeriodStart;
    final cur = currentRequests;

    List<FlSpot> spots = [];

    for (int i = 0; i < days; i++) {
      final targetDate = start.add(Duration(days: i));
      int dailyCount = 0;

      for (var r in cur) {
        if (r.createdAt != null) {
          final date = r.createdAt!.toDate();
          if (date.year == targetDate.year &&
              date.month == targetDate.month &&
              date.day == targetDate.day) {
            dailyCount++;
          }
        }
      }
      spots.add(FlSpot(i.toDouble(), dailyCount.toDouble()));
    }
    return spots;
  }

  // Bottom labels for chart
  String getLineChartLabel(double value) {
    final days = selectedTimeframe.value;
    final index = value.toInt();

    if (index < 0 || index >= days) return '';

    // Interval spacing based on selected timeframe
    if (days == 14 && index % 2 != 0) return '';
    if (days == 30 && index % 5 != 0) return '';

    final labelDate = currentPeriodStart.add(Duration(days: index));
    return DateFormat('MMM dd').format(labelDate);
  }

  // Max Y value calculation
  double getLineChartMaxY() {
    final spots = getLineChartSpots();
    if (spots.isEmpty) return 10.0;

    double max = 0.0;
    for (var spot in spots) {
      if (spot.y > max) {
        max = spot.y;
      }
    }
    return max < 5.0 ? 5.0 : (max * 1.25);
  }

  // Category stats for pie chart
  List<Map<String, dynamic>> getCategoryStats() {
    final cur = currentRequests;
    if (cur.isEmpty) return [];

    final Map<String, int> catCounts = {};

    for (var r in cur) {
      String key = r.categoryId.isEmpty ? 'unknown' : r.categoryId;
      catCounts[key] = (catCounts[key] ?? 0) + 1;
    }

    final total = cur.length;
    final List<Map<String, dynamic>> result = [];
    int index = 0;

    catCounts.forEach((id, count) {
      String title = 'Unknown Category';

      if (id != 'unknown') {
        for (var c in categories) {
          if (c.id == id) {
            title = c.name;
            break;
          }
        }
      }

      result.add({
        'name': title,
        'count': count,
        'percentage': (count / total) * 100,
        'color': _getColor(index),
      });
      index++;
    });

    // Sort descending
    result.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));
    return result;
  }

  // Color palette helper
  Color _getColor(int index) {
    const colors = [
      Color(0xFF0D56B3),
      Color(0xFF139655),
      Color(0xFFEAA612),
      Color(0xFF4A90E2),
      Color(0xFF9B59B6),
      Color(0xFFE67E22),
      Color(0xFF1ABC9C),
      Color(0xFFE74C3C),
      Color(0xFFA1AAB7),
    ];
    return colors[index % colors.length];
  }
}