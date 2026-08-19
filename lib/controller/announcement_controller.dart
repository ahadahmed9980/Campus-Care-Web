import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class AnnouncementController extends GetxController {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  RxList<String> categoryList = <String>["Academic","General","Events"].obs;
  RxString selectedCategory = "".obs;
   RxList<String> priorityList = <String>["Low","Medium","High"].obs;
  RxString selectedPriority = "".obs;
  var isToggled = true.obs;


  @override
  void onInit() {
    super.onInit();
  }

  @override
  void dispose() {
    super.dispose();
    descriptionController.dispose();
    titleController.dispose();
  }
}
