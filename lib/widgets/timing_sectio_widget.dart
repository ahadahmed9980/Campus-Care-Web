import 'package:customer_care_webapp/controller/campus_controller.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/widgets/textformField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Widget timingSection(BuildContext context) {
  final textTheme = Theme.of(context).textTheme;
  final campusinfoCtrl = Get.find<CampusController>();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Header Section
      Row(
        children: [
          Container(
            alignment: Alignment.center,
            height: 30,
            width: 30,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.watch_later_outlined,
              color: AppColors.primary,
              size: 15,
            ),
          ),
          const SizedBox(width: 8),
          Text("Timings", style: textTheme.labelMedium),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 1,
              width: double.infinity,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),

      // Timing Cards Grid
      Obx(() {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: campusinfoCtrl.timings.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisExtent: 255,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final day = campusinfoCtrl.timings[index];

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checkbox Header (Wrapped in Material to fix warning)
                  Material(
                    color: Colors.transparent,
                    child: SizedBox(
                      height: 35,
                      child: CheckboxListTile(
                        title: Text(
                          day.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        value: day.isOpen,
                        onChanged: (value) {
                          day.isOpen = value ?? false;
                          campusinfoCtrl.timings.refresh();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Open & Close Fields Column
                  Column(
                    children: [
                      // Open Time Field
                      DynamicTextFormField(
                        key: ValueKey("open_${day.name}_${day.open}"),
                        labelText: "Open",
                        controller: TextEditingController(
                          text: day.open == null
                              ? ''
                              : day.open!.format(context),
                        ),
                        hintText: "Time",
                        readOnly: true,
                        suffixicon: Icons.access_time,
                        callback: () async {
                          await campusinfoCtrl.openTimePicker(context, index);
                        },
                        validator: (value) {
                          if (day.isOpen && (value == null || value.isEmpty)) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),

                      // Close Time Field
                      DynamicTextFormField(
                        key: ValueKey("close_${day.name}_${day.close}"),
                        labelText: "Close",
                        controller: TextEditingController(
                          text: day.close == null
                              ? ''
                              : day.close!.format(context),
                        ),
                        hintText: "Time",
                        readOnly: true,
                        suffixicon: Icons.access_time,
                        callback: () async {
                          await campusinfoCtrl.closeTimePicker(context, index);
                        },
                        validator: (value) {
                          if (day.isOpen && (value == null || value.isEmpty)) {
                            return 'Required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      }),
    ],
  );
}