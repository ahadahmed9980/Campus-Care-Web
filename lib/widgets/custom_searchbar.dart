import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class CustomSearchbar extends StatelessWidget {
  final TextEditingController searchcontroller;
  final String hinttext;
  final ValueChanged<String>? onChanged;

  CustomSearchbar({
    super.key,
    required this.hinttext,
    required this.searchcontroller,
    this.onChanged,
  });
  final dashboardcontroller = Get.find<DashboardController>();
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: double.infinity,
      child: TextField(
        controller: searchcontroller,
        onChanged: onChanged,
        maxLines: 1,
        cursorColor: Colors.black,
        cursorHeight: 15,

        style: const TextStyle(fontSize: 16, color: Colors.black),

        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_sharp, color: AppColors.grey),
          hintText: hinttext,
          filled: true,
          fillColor: Theme.of(context).cardColor,

          hintStyle: textTheme.labelMedium,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.grey, width: 2),
          ),
        ),
      ),
    );
  }
}
