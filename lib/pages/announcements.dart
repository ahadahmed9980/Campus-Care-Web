import 'dart:ui';
import 'package:customer_care_webapp/controller/announcement_controller.dart';
import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/utils/responseive.dart';
import 'package:customer_care_webapp/widgets/customDropdownButton.dart';
import 'package:customer_care_webapp/widgets/custom_button.dart';
import 'package:customer_care_webapp/widgets/custom_searchbar.dart';
import 'package:customer_care_webapp/widgets/customeAppDialog.dart';
import 'package:customer_care_webapp/widgets/textformField.dart';
import 'package:flutter/material.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/state_manager.dart';
import 'package:date_format/date_format.dart';

class Announcements extends StatelessWidget {
  const Announcements({super.key});

  Widget _buildFilters(BuildContext context, BoxConstraints constraints) {
    final dashboardcontroller = Get.find<DashboardController>();
    final announcementcontroller = Get.find<AnnouncementController>();
    TextEditingController searchController = TextEditingController();
    final textTheme = Theme.of(context).textTheme;

    final searchbar = CustomSearchbar(
      hinttext: "search announcements...",
      searchcontroller: searchController,
    );

    final updateStatusButton = CustomButton(
      callback: () {
        // showDialog ke andar CustomAppDialog wrap kiya gaya hai
        showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.3),
          builder: (dialogContext) => CustomAppDialog(
            title: "Announcement",
            child: Form(
              child: Column(
                children: [
                  DynamicTextFormField(
                    labelText: "Title",
                    controller: announcementcontroller.titleController,
                    hintText: "Enter announcement title",
                  ),

                  // Description
                  DynamicTextFormField(
                    labelText: "Description",
                    controller: announcementcontroller.descriptionController,
                    hintText: "Enter description",
                    minLines: 4,
                    maxLines: 6,
                    maxLength: 400,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: customFormDownbutton(
                          context: context,
                          labelText: "Category",
                          selectedValue:
                              announcementcontroller.selectedCategory,
                          items: announcementcontroller.categoryList,
                        ),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: customFormDownbutton(
                          context: context,
                          labelText: "Priority",
                          selectedValue:
                              announcementcontroller.selectedPriority,
                          items: announcementcontroller.priorityList,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Image container
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Image (Optional)",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: dashboardcontroller.isDarkMode.value
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 5),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          height: 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(10),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.cloud_upload_outlined,
                                color: Colors.green,
                                size: 30,
                              ),
                              Text(
                                "Click to upload",
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                "PNG , JPG up to 5Mb",
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: DynamicTextFormField(
                          labelText: "Published At",
                          controller:
                              announcementcontroller.descriptionController,
                          hintText: "Select date & time",
                          readOnly: true,
                          suffixicon: Icons.calendar_today_outlined,
                          callback: () async {
                            DateTime? time = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2030),
                            );
                            builder:
                            (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.light(
                                    primary:
                                        Colors.blue, // Selected circle color
                                    onPrimary:
                                        Colors.white, // Selected text color
                                    surface: Colors.white, // Background color
                                    onSurface: Colors
                                        .black, // Dates Text Color (Black)
                                  ),
                                ),
                                child: child!,
                              );
                            };
                                              if (time != null) {
                    // print(DateFormat.yMMMd().format(time));
                  }

                          },
                        ),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: DynamicTextFormField(
                          labelText: "Expire At",
                          controller: announcementcontroller.titleController,
                          hintText: "Select date & time",
                          readOnly: true,
                          suffixicon: Icons.calendar_today_outlined,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Published",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: dashboardcontroller.isDarkMode.value
                              ? AppColors.darkText
                              : AppColors.lightText,
                        ),
                      ),
                      Transform.scale(
                        scale: 0.75,
                        child: Obx(
                          () => Switch(
                            value: announcementcontroller.isToggled.value,
                            activeColor: Colors.white,
                            activeTrackColor: AppColors.primary,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.red,
                            trackOutlineColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                            onChanged: (bool value) {
                              announcementcontroller.isToggled.value = value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: CustomButton(
                          callback: () {},
                          title: "Publish Announcement",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      title: "New announcement",
    );

    if (constraints.maxWidth < 600) {
      return Column(
        children: [
          searchbar,
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: updateStatusButton),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: searchbar),
          const SizedBox(width: 10),
          updateStatusButton,
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          final headerAndFilters = Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!Responsive.isMobileScreen(context)) ...[
                  Text("Announcements", style: textTheme.headlineLarge),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Text(
                        "Managed announcements",
                        style: textTheme.labelLarge,
                      ),
                      const SizedBox(width: 15),
                      Expanded(child: _buildFilters(context, constraints)),
                    ],
                  ),
                ],
              ],
            ),
          );

          if (isMobile) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [headerAndFilters, const SizedBox(height: 15)],
              ),
            );
          } else {
            return Column(
              children: [headerAndFilters, const SizedBox(height: 15)],
            );
          }
        },
      ),
    );
  }
}
