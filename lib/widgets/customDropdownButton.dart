import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

Widget customFormDownbutton({
  required BuildContext context,
  required RxString selectedValue,
  required RxList<String> items,
  String? hintText,
  String? labelText,
  Widget? suffixIcon,
  String? Function(String?)? validator,
  void Function(String?)? onChanged,
  bool enabled = true,
  bool isLoading = false,
}) {
  final textTheme = Theme.of(context).textTheme;
 final dashboardcontroller = Get.find<DashboardController>();

  return Obx(
    () => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // UI condition for label
        if (labelText != null) ...[
          Text(
            labelText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: dashboardcontroller.isDarkMode.value
                  ? AppColors.darkText
                  : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 5),
        ],
        Container(
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
          child: DropdownButtonFormField<String>(
            borderRadius: BorderRadius.circular(16),
            value: selectedValue.value.isEmpty ? null : selectedValue.value,
            isExpanded: true,

            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: textTheme.labelMedium?.copyWith(color: AppColors.grey),
              errorStyle: textTheme.labelMedium?.copyWith(color: AppColors.red),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.grey, ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.grey, ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.grey, ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.redAccent, ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
               
                ),
              ),
            ),
            icon: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.grey),
                    ),
                  )
                : const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.grey,
                  ),
            style: textTheme.labelMedium,
            items: items.map((status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: enabled && !isLoading
                ? (value) {
                    if (value != null) {
                      selectedValue.value = value;
                      if (onChanged != null) {
                        onChanged(value);
                      }
                    }
                  }
                : null,
            validator: validator,
          ),
        ),
              SizedBox(height: 10),
      ],
    ),
  );
}
