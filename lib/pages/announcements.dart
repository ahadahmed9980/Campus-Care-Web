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
import 'package:intl/intl.dart';

class Announcements extends StatelessWidget {
  const Announcements({super.key});

  Widget _buildFilters(BuildContext context, BoxConstraints constraints) {
    final dashboardcontroller = Get.find<DashboardController>();
    final announcementcontroller = Get.find<AnnouncementController>();

    final textTheme = Theme.of(context).textTheme;

    final searchbar = CustomSearchbar(
      hinttext: "search announcements...",
      searchcontroller: announcementcontroller.searchController,
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
              key: announcementcontroller.formkey,
              child: Column(
                children: [
                  DynamicTextFormField(
                    labelText: "Title",
                    controller: announcementcontroller.titleController,
                    hintText: "Enter announcement title...",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter title';
                      }

                      return null;
                    },
                  ),

                  // Description
                  DynamicTextFormField(
                    labelText: "Description",
                    controller: announcementcontroller.descriptionController,
                    hintText: "Enter description...",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }

                      return null;
                    },
                    minLines: 4,
                    maxLines: 6,
                    maxLength: 400,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: customFormDownbutton(
                          context: context,
                          hintText: "Select Category",
                          labelText: "Category",
                          selectedValue:
                              announcementcontroller.selectedCategory,
                          items: announcementcontroller.categoryList,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select category';
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: customFormDownbutton(
                          context: context,
                          hintText: "Select Priority",
                          labelText: "Priority",
                          selectedValue:
                              announcementcontroller.selectedPriority,
                          items: announcementcontroller.priorityList,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select priority';
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Image container
                  imagecontainer(context),

                  //container image finish
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Obx(() {
                          return DynamicTextFormField(
                            labelText: "Expired At",
                            controller: TextEditingController(
                              text:
                                  announcementcontroller.expireAt.value ==
                                      null // <-- Ab yeh expireAt ko check karega
                                  ? ''
                                  : DateFormat('yyyy-MM-dd HH:mm').format(
                                      announcementcontroller.expireAt.value!,
                                    ),
                            ),
                            hintText: "Select date & time",
                            readOnly: true,
                            suffixicon: Icons.calendar_today_outlined,

                            callback: () async {
                              //publish At picker function from announcement controller
                              await announcementcontroller.expireAtPicker(
                                context,
                              );
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select expire date';
                              }

                              return null;
                            },
                          );
                        }),
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
                        child: Obx(
                          () => CustomButton(
                            title: "Publish Announcement",
                            isLoading: announcementcontroller.isLoading.value,
                            callback: () async {
                              //  Form validation check
                              if (announcementcontroller.formkey.currentState!
                                  .validate()) {
                                //  Submit form call
                                final bool isSuccess =
                                    await announcementcontroller.submitform(
                                      context,
                                    );

                                //  Agar upload kamiyab ho jaye to green snackbar dikhayein
                                if (isSuccess && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Announcement published successfully!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
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

//image container widget
Widget imagecontainer(BuildContext context) {
  final announcementcontroller = Get.find<AnnouncementController>();
  final dashboardcontroller = Get.find<DashboardController>();

  final textTheme = Theme.of(context).textTheme;
  return Column(
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
      Obx(() {
        final hasImage =
            announcementcontroller.selectedImageBytes.value != null;
        return InkWell(
          onTap: () async {
            if (!hasImage) {
              await announcementcontroller.chooseImage();
            }
          },
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hasImage ? AppColors.primary : Colors.transparent,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: hasImage
                ? Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(9),
                          child: Opacity(
                            opacity: 0.8,
                            child: Image.memory(
                              announcementcontroller.selectedImageBytes.value!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(9),
                              bottomRight: Radius.circular(9),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Text(
                            announcementcontroller.selectedImageName.value ??
                                "Selected Image",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () {
                            announcementcontroller.clearImage();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cloud_upload_outlined,
                        color: Colors.green,
                        size: 30,
                      ),
                      const SizedBox(height: 4),
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
        );
      }),
      const SizedBox(height: 10),
    ],
  );
}
