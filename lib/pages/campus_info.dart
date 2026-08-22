import 'package:customer_care_webapp/controller/campus_controller.dart';
import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/models/campusinfo_model.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/widgets/charts/mainrow_widget.dart';
import 'package:customer_care_webapp/widgets/customDropdownButton.dart';
import 'package:customer_care_webapp/widgets/custom_button.dart';
import 'package:customer_care_webapp/widgets/custom_dataTable.dart';
import 'package:customer_care_webapp/widgets/customeAppDialog.dart';
import 'package:customer_care_webapp/widgets/pageHeader.dart';
import 'package:customer_care_webapp/widgets/textformField.dart';
import 'package:customer_care_webapp/widgets/timing_sectio_widget.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/state_manager.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CampusInfo extends StatelessWidget {
  const CampusInfo({super.key});

  Widget _buildFilters(BuildContext context, BoxConstraints constraints) {
    final dashboardcontroller = Get.find<DashboardController>();
    final campusinfoCtrl = Get.find<CampusController>();

    final updateStatusButton = CustomButton(
      callback: () {
        // showDialog ke andar CustomAppDialog wrap kiya gaya hai
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.3),
          builder: (dialogContext) => CustomAppDialog(
            title: "Add Campus info",
            child: Form(
              key: campusinfoCtrl.formkey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DynamicTextFormField(
                          labelText: "Title",
                          controller: campusinfoCtrl.titleController,
                          hintText: "Enter  title...",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter title';
                            }

                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: customFormDownbutton(
                          context: context,
                          hintText: "Select Category",
                          labelText: "Category",
                          selectedValue: campusinfoCtrl.selectedCategory,
                          items: campusinfoCtrl.campusinfoCategoryList,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select category';
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  // Description
                  DynamicTextFormField(
                    labelText: "Description",
                    controller: campusinfoCtrl.descriptionController,
                    hintText: "Enter description...",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter description';
                      }

                      return null;
                    },
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 200,
                  ),
                  //icon
                  MainrowWidget(
                    maintitle: "Contact info",
                    controller1: campusinfoCtrl.phoneController,
                    controller2: campusinfoCtrl.emailController,
                    controller3: campusinfoCtrl.websiteController,
                    mainicons: Icons.contacts_outlined,
                    title1: "Phone",
                    title2: "Email",
                    title3: "Website",
                    hitntext1: "phone..",
                    hitntext2: "email..",
                    hitntext3: "website..",
                    icon1: Icons.phone_outlined,
                    icon2: Icons.email_outlined,
                    icon3: Icons.language_outlined,
                    input1: TextInputType.phone,
                    input2: TextInputType.emailAddress,
                    input3: TextInputType.url,
                    // Phone validation (11 digits)
                    validator1: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter phone";
                      }
                      final cleanValue = value.trim();
                      if (!RegExp(r'^[0-9]{11}$').hasMatch(cleanValue)) {
                        return "Phone must be exactly 11 digits";
                      }
                      return null;
                    },
                    // Email validation
                    validator2: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter email";
                      }
                      final emailRegex = RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      );
                      if (!emailRegex.hasMatch(value.trim())) {
                        return "Please enter a valid email";
                      }
                      return null;
                    },
                    // Website: No validation (Optional)
                    validator3: null,
                  ),

                  const SizedBox(height: 10),

                  MainrowWidget(
                    controller1: campusinfoCtrl.buildingController,
                    controller2: campusinfoCtrl.floorController,
                    controller3: campusinfoCtrl.roomController,
                    mainicons: Icons.location_on_outlined,
                    maintitle: "Location",
                    title1: "Building",
                    title2: "Floor",
                    title3: "Room",
                    hitntext1: "Enter building",
                    hitntext2: "Enter floor",
                    hitntext3: "Enter room",
                    input1: TextInputType.text,
                    input2: TextInputType.text,
                    input3: TextInputType.text,
                    // Building validation (Required)
                    validator1: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter building";
                      }
                      return null;
                    },
                    // Floor validation (Required)
                    validator2: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter floor";
                      }
                      return null;
                    },
                    // Room: No validation (Optional)
                    validator3: null,
                  ),

                  const SizedBox(height: 8),
                  //timing section
                  timingSection(context),

                  //main column
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Active",
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
                            value: campusinfoCtrl.isToggled.value,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.primary,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.red,
                            trackOutlineColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                            onChanged: (bool value) {
                              campusinfoCtrl.isToggled.value = value;
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
                            title: "Save Information",
                            isLoading: campusinfoCtrl.isLoading.value,
                            callback: () async {
                              //  Form validation check
                              if (campusinfoCtrl.formkey.currentState!
                                  .validate()) {
                                //  Submit form call
                                await campusinfoCtrl.submitform(context);
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
      title: "Add Information",
    );

    if (constraints.maxWidth < 600) {
      return Column(
        children: [
          // searchbar,
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: updateStatusButton),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Expanded(child: searchbar),
          const SizedBox(width: 10),
          updateStatusButton,
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;

          final headerAndFilters =
              PageHeader(
                    title: "Campus Information",
                    subtitle: "Manage all Campus info",
                    widget: _buildFilters(context, constraints),
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

// tabels
// tabels
class CampusInfoTableSource extends DataTableSource {
  final campusinfoCtrl = Get.find<CampusController>();
  final List<CampusInformationModel> data;
  final BuildContext context;

  CampusInfoTableSource({required this.data, required this.context});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return DataRow.byIndex(
        index: index,
        cells: List.generate(
          8,
          (i) => const DataCell(
            Skeletonizer(
              enabled: true,
              child: SizedBox(width: 80, height: 15, child: Card()),
            ),
          ),
        ),
      );
    }
    // Current row ka specific object nikala
    final info = data[index];

    // Location string helper
    final building = info.building ?? '';
    final floor = info.floor ?? '';
    final room = info.room ?? '';
    final locationParts = [
      if (building.isNotEmpty) building,
      if (floor.isNotEmpty || room.isNotEmpty)
        '${floor.isNotEmpty ? 'Floor $floor' : ''}${floor.isNotEmpty && room.isNotEmpty ? ', ' : ''}${room.isNotEmpty ? 'R-$room' : ''}',
    ];
    final locationStr = locationParts.isEmpty ? '-' : locationParts.join('\n');

    // Contact string helper
    final phone = info.phone ?? '';
    final email = info.email ?? '';
    final contactParts = [
      if (phone.isNotEmpty) phone,
      if (email.isNotEmpty) email,
    ];
    final contactStr = contactParts.isEmpty ? '-' : contactParts.join('\n');

    // Timings formatter
    List<String> timingList = [];
    final daysOrder = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
    ];
    final dayAbbr = {
      'monday': 'Mon',
      'tuesday': 'Tue',
      'wednesday': 'Wed',
      'thursday': 'Thu',
      'friday': 'Fri',
      'saturday': 'Sat',
    };
    if (info.timings != null) {
      for (final day in daysOrder) {
        final dayData = info.timings![day];
        if (dayData != null && dayData['isOpen'] == true) {
          final open = dayData['open'] ?? '';
          final close = dayData['close'] ?? '';
          if (open.isNotEmpty && close.isNotEmpty) {
            timingList.add('${dayAbbr[day]} $open-$close');
          }
        }
      }
    }
    final timingsStr = timingList.isEmpty ? 'Closed' : timingList.join('\n');

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(info.title ?? '-')),
        DataCell(Text(info.description ?? '-')),
        DataCell(Text(info.category ?? '-')),
        DataCell(Text(contactStr)),
        DataCell(Text(locationStr)),
        DataCell(Text(timingsStr)),
        DataCell(
          Transform.scale(
            scale: 0.75,
            child: Switch(
              value: info.isActive,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.red,
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              onChanged: (bool value) {
                campusinfoCtrl.togglePublishStatus(info, value);
              },
            ),
          ),
        ),
        DataCell(
          Obx(
            () => TableActions(
              isDeleting: campusinfoCtrl.deletingId.value == info.id,
              onDelete: () {
                campusinfoCtrl.deleteCampusInfo(info);
                debugPrint("Delete tapped for: ${info.id}");
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate =>
      (campusinfoCtrl.isLoading.value && campusinfoCtrl.campusInfoList.isEmpty)
      ? false
      : campusinfoCtrl.hasNextPage.value;

  @override
  int get rowCount =>
      (campusinfoCtrl.isLoading.value && campusinfoCtrl.campusInfoList.isEmpty)
      ? data.length
      : (campusinfoCtrl.hasNextPage.value ? data.length + 1 : data.length);

  @override
  int get selectedRowCount => 0;
}

// table builder by using custom widget
Widget _buildUI(BuildContext context, {required bool isMobile}) {
  final dashboardcontroller = Get.find<DashboardController>();
  final campusinfoCtrl = Get.find<CampusController>();

  final textTheme = Theme.of(context).textTheme;

  return Obx(() {
    final isDark = dashboardcontroller.isDarkMode.value;
    final showSkeleton =
        campusinfoCtrl.isLoading.value && campusinfoCtrl.campusInfoList.isEmpty;
    //Agar data load ho raha hai to Dummy List, warna Firebase wali List
    final campusData = showSkeleton
        ? List.generate(
            campusinfoCtrl.pageSize,
            (index) => CampusInformationModel(
              id: 'dummy_$index',
              title: 'Campus Info ${index + 1}',
              description: 'This is a description for campus info ${index + 1}',
              category: 'Other',
              isActive: index % 2 == 0,
              createdAt: DateTime.now().subtract(Duration(days: index)),
              updatedAt: DateTime.now().subtract(Duration(days: index)),
            ),
          )
        : campusinfoCtrl.campusInfoList.toList();

    return Skeletonizer(
      enabled: showSkeleton,
      child:
          CustomPaginatedTable(
                isDarkMode: isDark,
                isMobile: isMobile,
                minWidth: 1000,
                onPageChanged: (rowIndex) {
                  if (rowIndex + campusinfoCtrl.pageSize >=
                      campusinfoCtrl.campusInfoList.length) {
                    campusinfoCtrl.fetchNextPage();
                    debugPrint("Next page fetched for row index: $rowIndex");
                  }
                },
                source: CampusInfoTableSource(
                  context: context,
                  data: campusData,
                ),
                columns: [
                  DataColumn2(
                    label: Text("Title", style: textTheme.bodySmall),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Description", style: textTheme.bodySmall),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text("Category", style: textTheme.bodySmall),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Contact", style: textTheme.bodySmall),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Location", style: textTheme.bodySmall),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Timings", style: textTheme.bodySmall),
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
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFFEF5350),
                          ),
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
