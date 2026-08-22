import 'package:customer_care_webapp/controller/announcement_controller.dart';
import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/models/announcement_model.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/widgets/badges/prority_badge.dart';
import 'package:customer_care_webapp/widgets/customDropdownButton.dart';
import 'package:customer_care_webapp/widgets/custom_button.dart';
import 'package:customer_care_webapp/widgets/custom_dataTable.dart';
import 'package:customer_care_webapp/widgets/custom_searchbar.dart';
import 'package:customer_care_webapp/widgets/customeAppDialog.dart';
import 'package:customer_care_webapp/widgets/textformField.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/state_manager.dart';
import 'package:intl/intl.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Announcements extends StatelessWidget {
  const Announcements({super.key});

  Widget _buildFilters(BuildContext context, BoxConstraints constraints) {
    final dashboardcontroller = Get.find<DashboardController>();
    final announcementcontroller = Get.find<AnnouncementController>();

    final searchbar = CustomSearchbar(
      hinttext: "search announcements...",
      searchcontroller: announcementcontroller.searchController,
      onChanged: (value) {
        announcementcontroller.searchAnnouncements(value);
      },
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
                                await announcementcontroller.submitform(
                                  context,
                                );
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
                Text(
                  "Announcements",
                  style: isMobile ? textTheme.headlineMedium : textTheme.headlineLarge,
                ),
                const SizedBox(height: 10),
                if (isMobile) ...[
                  Text(
                    "Managed announcements",
                    style: textTheme.labelLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildFilters(context, constraints),
                ] else ...[
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
          )
          .animate()
          .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
          .slideY(
            begin: -0.1,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          );

          if (isMobile) {
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerAndFilters,
                  const SizedBox(height: 15),
                  _buildUI(context, isMobile: true),
                ],
              ),
            );
          } else {
            return Column(
              children: [
                headerAndFilters,
                const SizedBox(height: 15),
                Expanded(child: _buildUI(context, isMobile: false)),
              ],
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

// tabels
class AnnouncementTableSource extends DataTableSource {
  final announcementcontroller = Get.find<AnnouncementController>();
  final List<AnnouncementModel> data;
  final BuildContext context;

  AnnouncementTableSource({required this.data, required this.context});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return DataRow.byIndex(
        index: index,
        cells: List.generate(
          6,
          (i) => const DataCell(
            Skeletonizer(
              enabled: true,
              child: SizedBox(
                width: 80,
                height: 15,
                child: Card(),
              ),
            ),
          ),
        ),
      );
    }
    // Current row ka specific object nikala

    final announcement = data[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(announcement.title)),
        DataCell(Text(announcement.category)),
        DataCell(ProrityBadge(priority: announcement.priority)),
        DataCell(
          Text(
            announcement.createdAt != null
                ? DateFormat('dd-MM-yyyy').format(announcement.createdAt!)
                : '-',
          ),
        ),
        DataCell(
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: announcement.isPublished,
              activeColor: Colors.white,
              activeTrackColor: AppColors.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.red,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              onChanged: (bool value) {
                //Jab Switch click ho, to pura object aur nayi value controller ko bhej di
                announcementcontroller.togglePublishStatus(announcement, value);
              },
            ),
          ),
        ),
        DataCell(
          Obx(
            () => TableActions(
              isDeleting: announcementcontroller.deletingId.value == announcement.id,
              onDelete: () {
                announcementcontroller.deleteannouncement(announcement);
                debugPrint("Delete tapped for: ${announcement.id}");
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate =>
      (announcementcontroller.isLoading.value &&
          announcementcontroller.announcementList.isEmpty)
      ? false
      : announcementcontroller.hasNextPage.value;

  @override
  int get rowCount =>
      (announcementcontroller.isLoading.value &&
          announcementcontroller.announcementList.isEmpty)
      ? data.length
      : (announcementcontroller.hasNextPage.value
            ? data.length + 1
            : data.length);

  @override
  int get selectedRowCount => 0;
}

// table builder by using custom widget
Widget _buildUI(BuildContext context, {required bool isMobile}) {
  final dashboardcontroller = Get.find<DashboardController>();
  final announcementController = Get.find<AnnouncementController>();
  final textTheme = Theme.of(context).textTheme;

  return Obx(() {
    final isDark = dashboardcontroller.isDarkMode.value;
    final showSkeleton =
        announcementController.isLoading.value &&
        announcementController.announcementList.isEmpty;
    //Agar data load ho raha hai to Dummy List, warna Firebase wali List
    final announcementData = showSkeleton
        ? List.generate(
            announcementController.pageSize,
            (index) => AnnouncementModel(
              title: 'Announcement Title ${index + 1}',
              description: 'Announcement description ${index + 1}',

              category: index % 3 == 0
                  ? 'Academic'
                  : index % 3 == 1
                  ? 'General'
                  : 'Events',
              priority: index % 3 == 0
                  ? 'High'
                  : index % 3 == 1
                  ? 'Medium'
                  : 'Low',
              imageUrl: 'https://picsum.photos/200/300?random=$index',
              isPublished: index % 2 == 0,

              createdAt: DateTime.now().subtract(Duration(days: index)),
            ),
          )
        //list in announcement controller
        : announcementController.announcementList.toList();

    return Skeletonizer(
      enabled: showSkeleton,
      child:
          CustomPaginatedTable(
                isDarkMode: isDark,
                isMobile: isMobile,
                minWidth: 1000,
                onPageChanged: (rowIndex) {
                  if (rowIndex + announcementController.pageSize >=
                      announcementController.announcementList.length) {
                    announcementController.fetchNextPage();
                    debugPrint("Next page fetched for row index: $rowIndex");
                  }
                },
                source: AnnouncementTableSource(
                  //we are passing data to the announcement table widget
                  context: context,
                  data: announcementData,
                ),
                columns: [
                  DataColumn2(
                    label: Text("Title", style: textTheme.bodySmall),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Category", style: textTheme.bodySmall),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Priority", style: textTheme.bodySmall),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text("Date", style: textTheme.bodySmall),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Status", style: textTheme.bodySmall),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Actions", style: textTheme.bodySmall),
                    size: ColumnSize.S,
                  ),
                ],
              )
              .animate(key: ValueKey(showSkeleton))
              .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
              .slideY(
                begin: 0.05,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),
    );
  });
}

//edit and delete
class TableActions extends StatelessWidget {
  final VoidCallback? onDelete;
  final bool isDeleting;

  const TableActions({super.key, this.onDelete, this.isDeleting = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //  Delete
        Tooltip(
          message: 'Delete',
          child: InkWell(
            onTap: isDeleting ? null : onDelete,
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: isDeleting
                  ? const SizedBox(
                      width: 25,
                      height: 25,
                      child: Padding(
                        padding: EdgeInsets.all(4.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF5350)),
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.delete_outline_rounded,
                      size: 25,
                      color: Color(0xFFEF5350),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
