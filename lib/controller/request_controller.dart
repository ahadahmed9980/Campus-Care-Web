import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestController extends GetxController {
  TextEditingController searchrbar = TextEditingController();
  RxList<String> status = [
    "All Status",
    'Submitted',
    "In Progress",
    'Under Review',
    'Resolved',
  ].obs;
  RxString selectedStatus = "All Status".obs;
}
