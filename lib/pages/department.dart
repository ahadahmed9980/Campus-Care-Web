import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/controller/department_controller.dart';
import 'package:customer_care_webapp/models/department_model.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';

import 'package:customer_care_webapp/widgets/custom_button.dart';
import 'package:customer_care_webapp/widgets/custom_dataTable.dart';
import 'package:customer_care_webapp/widgets/customeAppDialog.dart';
import 'package:customer_care_webapp/widgets/pageHeader.dart';
import 'package:customer_care_webapp/widgets/textformField.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/state_manager.dart';
import 'package:skeletonizer/skeletonizer.dart';

class Department extends StatelessWidget {
  const Department({super.key});

  Widget _buildFilters(BuildContext context, BoxConstraints constraints) {
    final dashboardcontroller = Get.find<DashboardController>();
    final departmentCtrl = Get.find<DepartmentController>();

    final updateStatusButton = CustomButton(
      callback: () {
        // showDialog ke andar CustomAppDialog wrap kiya gaya hai
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.3),
          builder: (dialogContext) => CustomAppDialog(
            title: "Add Department info",
            child: Form(
              key: departmentCtrl.formkey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DynamicTextFormField(
                          labelText: "Name",
                          controller: departmentCtrl.titleController,
                          hintText: "Enter name...",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter name';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DynamicTextFormField(
                          controller: departmentCtrl.codeController,
                          hintText: "Enter code...",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter code';
                            }
                            return null;
                          },
                          labelText: "Code",
                        ),
                      ),
                    ],
                  ),

                  // Description
                  DynamicTextFormField(
                    labelText: "Description",
                    controller: departmentCtrl.descriptionController,
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
                  
                  // Phone
                  DynamicTextFormField(
                    prefixicon: Icons.phone_outlined,
                    controller: departmentCtrl.phoneController,
                    hintText: "Enter phone...",
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter phone";
                      }
                      final cleanValue = value.trim();
                      if (!RegExp(r'^[0-9]{11}$').hasMatch(cleanValue)) {
                        return "Phone must be exactly 11 digits";
                      }
                      return null;
                    },
                    labelText: "Phone",
                  ),
                  
                  Row(
                    children: [
                      Expanded(
                        child: DynamicTextFormField(
                          prefixicon: Icons.email_outlined,
                          labelText: "Email",
                          controller: departmentCtrl.emailController,
                          hintText: "Enter email...",
                          validator: (value) {
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
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DynamicTextFormField(
                          prefixicon: Icons.language_outlined,
                          controller: departmentCtrl.websiteController,
                          hintText: "Website...",
                          labelText: "Website",
                        ),
                      ),
                    ],
                  ),

                  // Active status
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
                            value: departmentCtrl.isToggled.value,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.primary,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.red,
                            trackOutlineColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                            onChanged: (bool value) {
                              departmentCtrl.isToggled.value = value;
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
                            isLoading: departmentCtrl.isLoading.value,
                            callback: () async {
                              if (departmentCtrl.formkey.currentState!.validate()) {
                                await departmentCtrl.submitform(context);
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
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: updateStatusButton),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                    title: "Departments",
                    subtitle: "Manage all departments",
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

// Table source
class DepartmentTableSource extends DataTableSource {
  final departmentCtrl = Get.find<DepartmentController>();
  final List<DepartmentModel> data;
  final BuildContext context;

  DepartmentTableSource({required this.data, required this.context});

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
              child: SizedBox(width: 80, height: 15, child: Card()),
            ),
          ),
        ),
      );
    }
    final info = data[index];

    // Contact string helper
    final phone = info.phone ?? '';
    final email = info.email ?? '';
    final website = info.website ?? '';
    final contactParts = [
      if (phone.isNotEmpty) phone,
      if (email.isNotEmpty) email,
      if (website.isNotEmpty) website,
    ];
    final contactStr = contactParts.isEmpty ? '-' : contactParts.join('\n');

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(info.name ?? '-')),
        DataCell(Text(info.code ?? '-')),
        DataCell(Text(info.description ?? '-')),
        DataCell(Text(contactStr)),
        DataCell(
          Obx(
            () => Transform.scale(
              scale: 0.75,
              child: Switch(
                value: info.isActive,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.red,
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                onChanged: departmentCtrl.togglingIds.contains(info.id)
                    ? null
                    : (bool value) {
                        departmentCtrl.togglePublishStatus(info, value);
                      },
              ),
            ),
          ),
        ),
        DataCell(
          Obx(
            () => TableActions(
              isDeleting: departmentCtrl.deletingId.value == info.id,
              onDelete: () {
                departmentCtrl.deleteDepartmentInfo(info);
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
      (departmentCtrl.isLoading.value && departmentCtrl.departmentList.isEmpty)
      ? false
      : departmentCtrl.hasNextPage.value;

  @override
  int get rowCount =>
      (departmentCtrl.isLoading.value && departmentCtrl.departmentList.isEmpty)
      ? data.length
      : (departmentCtrl.hasNextPage.value ? data.length + 1 : data.length);

  @override
  int get selectedRowCount => 0;
}

// Table UI builder
Widget _buildUI(BuildContext context, {required bool isMobile}) {
  final dashboardcontroller = Get.find<DashboardController>();
  final departmentCtrl = Get.find<DepartmentController>();

  final textTheme = Theme.of(context).textTheme;

  return Obx(() {
    final isDark = dashboardcontroller.isDarkMode.value;
    final showSkeleton =
        departmentCtrl.isLoading.value && departmentCtrl.departmentList.isEmpty;
    
    final deptData = showSkeleton
        ? List.generate(
            departmentCtrl.pageSize,
            (index) => DepartmentModel(
              id: 'dummy_$index',
              name: 'Department ${index + 1}',
              code: 'DEPT${index + 1}',
              description: 'This is a description for department ${index + 1}',
              isActive: index % 2 == 0,
              createdAt: DateTime.now().subtract(Duration(days: index)),
              updatedAt: DateTime.now().subtract(Duration(days: index)),
            ),
          )
        : departmentCtrl.departmentList.toList();

    return Skeletonizer(
      enabled: showSkeleton,
      child:
          CustomPaginatedTable(
                isDarkMode: isDark,
                isMobile: isMobile,
                minWidth: 1000,
                onPageChanged: (rowIndex) {
                  if (rowIndex + departmentCtrl.pageSize >=
                      departmentCtrl.departmentList.length) {
                    departmentCtrl.fetchNextPage();
                    debugPrint("Next page fetched for row index: $rowIndex");
                  }
                },
                source: DepartmentTableSource(
                  context: context,
                  data: deptData,
                ),
                columns: [
                  DataColumn2(
                    label: Text("Name", style: textTheme.bodySmall),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Code", style: textTheme.bodySmall),
                    size: ColumnSize.S,
                  ),
                  DataColumn2(
                    label: Text("Description", style: textTheme.bodySmall),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text("Contact", style: textTheme.bodySmall),
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

// Edit and delete actions
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
