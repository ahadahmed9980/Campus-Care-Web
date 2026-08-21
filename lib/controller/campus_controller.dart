import 'package:flutter/material.dart';
import 'package:get/state_manager.dart';

class CampusController extends GetxController {
  TextEditingController searchController = TextEditingController();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController websiteController = TextEditingController();
  TextEditingController buildingController = TextEditingController();
  TextEditingController floorController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  RxList<String> campusinfoCategoryList = <String>[
    "University Offices",
    "Academic Facilities",
    "Student Services",
    "Library",
    "Health & Medical",
    "IT Services",
    "Emergency Contacts",
    "Campus Facilities",
    "Transportation",
    "Food & Dining",
    "Sports & Recreation",
    "Other",
    "Hostel Office",
  ].obs;
  RxString selectedCategory = "".obs;
  @override
  void onInit() {
    super.onInit();
  }

  void clearImage() {}
  //reset form
  void _resetForm() {}
  //dispose to prtect data leakage
  @override
  void onClose() {
    searchController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    phoneController.dispose();
    websiteController.dispose();
    floorController.dispose();
    roomController.dispose();
    buildingController.dispose();

    super.onClose();
  }
}
