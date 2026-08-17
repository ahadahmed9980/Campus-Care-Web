import 'dart:ui';

import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class RequestDetailController extends GetxController {
  RxList<String> status = [
    'Under Review',
    "In Progress",
    'Resolved',
    'Closed',
  ].obs;
  var selectedStatus = "".obs;

  // helper color status
  Color getStepColor(
    String stepName,
    String? currentStatus,
    Color activeColor,
  ) {
    if (currentStatus == null) return AppColors.grey;

    int currentIndex = status.indexOf(currentStatus);
    int stepIndex = status.indexOf(stepName);

    // Agar current status step tak pohanch gaya ya guzar chuka hai toh color show ho
    if (stepIndex <= currentIndex && currentIndex != -1) {
      return activeColor;
    }
    return AppColors.grey;
  }








  //line color
  Color getLineColor(String stepName, String? currentStatus, Color activeColor) {


  int currentIndex = status.indexOf(currentStatus);
  int stepIndex = status.indexOf(stepName);

  // Line tab active hogi jab current status agle stage par pohanch chuka ho
  if (stepIndex < currentIndex && currentIndex != -1) {
    return activeColor;
  }
  return Colors.transparent; // Next steps ki line gayab ho jayegi
}
}
