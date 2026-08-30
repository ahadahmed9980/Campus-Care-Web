import 'package:customer_care_webapp/controller/requestCategory_controller.dart';
import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/models/request_Category_model.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
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

class requestCategories extends StatelessWidget {
  const requestCategories({super.key});

  Widget _buildFilters(BuildContext context, BoxConstraints constraints) {
    final dashboardcontroller = Get.find<DashboardController>();
    final requestcategorycontroller = Get.find<RequestcategoryController>();

    final searchbar = CustomSearchbar(
      hinttext: "search Categories...",
      searchcontroller: requestcategorycontroller.searchController,
      onChanged: (value) {
        requestcategorycontroller.searchCategories(value);
      },
    );

    final updateStatusButton = CustomButton(
      callback: () {
        // showDialog ke andar CustomAppDialog wrap kiya gaya hai
        showDialog(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.3),
          builder: (dialogContext) => CustomAppDialog(
            title: "Add Categories",
            child: Form(
              key: requestcategorycontroller.formkey,
              child: Column(
                children: [
                     DynamicTextFormField(
                    labelText: "Category Id",
                    controller: requestcategorycontroller.categoryIdController,
                    hintText: " Electricity...",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter Category Id';
                      }

                      return null;
                    },
                  ),
                  DynamicTextFormField(
                    labelText: "Title",
                    controller: requestcategorycontroller.titleController,
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
                    controller: requestcategorycontroller.descriptionController,
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
                            value: requestcategorycontroller.isToggled.value,
                            activeThumbColor: Colors.white,
                            activeTrackColor: AppColors.primary,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: Colors.red,
                            trackOutlineColor: WidgetStateProperty.all(
                              Colors.transparent,
                            ),
                            onChanged: (bool value) {
                              requestcategorycontroller.isToggled.value = value;
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
                            title: "Publish Category",
                            isLoading:
                                requestcategorycontroller.isLoading.value,
                            callback: () async {
                              //  Form validation check
                              if (requestcategorycontroller
                                  .formkey
                                  .currentState!
                                  .validate()) {
                                //  Submit form call
                                await requestcategorycontroller.submitform(
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
      title: "New Categories",
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

          final headerAndFilters =
              Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          " Categories",
                          style: isMobile
                              ? textTheme.headlineMedium
                              : textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 10),
                        if (isMobile) ...[
                          Text(
                            "Managed categories",
                            style: textTheme.labelLarge,
                          ),
                          const SizedBox(height: 12),
                          _buildFilters(context, constraints),
                        ] else ...[
                          Row(
                            children: [
                              Text(
                                "Managed categories",
                                style: textTheme.labelLarge,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: _buildFilters(context, constraints),
                              ),
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

// tabels
class RequestCategoryTableSource extends DataTableSource {
  final requestcategorycontroller = Get.find<RequestcategoryController>();
  final List<RequestCategoryModel> data;
  final BuildContext context;

  RequestCategoryTableSource({required this.data, required this.context});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return DataRow.byIndex(
        index: index,
        cells: List.generate(
          5,
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

    final requestCategory = data[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(requestCategory.name)),
        DataCell(Text(requestCategory.description)),

        DataCell(
          Text(
            requestCategory.createdAt != null
                ? DateFormat('dd-MM-yyyy').format(requestCategory.createdAt!)
                : '-',
          ),
        ),
        DataCell(
          Obx(
            () => Transform.scale(
              scale: 0.75,
              child: Switch(
                value: requestCategory.isActive,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.red,
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                onChanged: requestcategorycontroller.togglingIds.contains(requestCategory.id)
                    ? null
                    : (bool value) {
                        requestcategorycontroller.togglePublishStatus(
                          requestCategory,
                          value,
                        );
                      },
              ),
            ),
          ),
        ),
        DataCell(
          Obx(
            () => TableActions(
              isDeleting:
                  requestcategorycontroller.deletingId.value == requestCategory.id,
              onDelete: () {
                requestcategorycontroller.deleteCategory(requestCategory);
                debugPrint("Delete tapped for: ${requestCategory.id}");
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate =>
      (requestcategorycontroller.isLoading.value &&
          requestcategorycontroller.requestCategoryList.isEmpty)
      ? false
      : requestcategorycontroller.hasNextPage.value;

  @override
  int get rowCount =>
      (requestcategorycontroller.isLoading.value &&
          requestcategorycontroller.requestCategoryList.isEmpty)
      ? data.length
      : (requestcategorycontroller.hasNextPage.value
            ? data.length + 1
            : data.length);

  @override
  int get selectedRowCount => 0;
}

// table builder by using custom widget
Widget _buildUI(BuildContext context, {required bool isMobile}) {
  final dashboardcontroller = Get.find<DashboardController>();
  final requestcategorycontroller = Get.find<RequestcategoryController>();

  final textTheme = Theme.of(context).textTheme;

  return Obx(() {
    final isDark = dashboardcontroller.isDarkMode.value;
    final showSkeleton =
        requestcategorycontroller.isLoading.value &&
        requestcategorycontroller.requestCategoryList.isEmpty;
    //Agar data load ho raha hai to Dummy List, warna Firebase wali List
    final requestCata = showSkeleton
        ? List.generate(
            requestcategorycontroller.pageSize,
            (index) => RequestCategoryModel(
              id: 'dummy_$index',
              name: 'Category ${index + 1}',
              description: 'This is a description for category ${index + 1}',
              isActive: index % 2 == 0,
              createdAt: DateTime.now().subtract(Duration(days: index)),
              updatedAt: DateTime.now().subtract(Duration(days: index)),
            ),
          )
        //list in announcement controller
        : requestcategorycontroller.requestCategoryList.toList();

    return Skeletonizer(
      enabled: showSkeleton,
      child:
          CustomPaginatedTable(
                isDarkMode: isDark,
                isMobile: isMobile,
                minWidth: 1000,
                onPageChanged: (rowIndex) {
                  if (rowIndex + requestcategorycontroller.pageSize >=
                      requestcategorycontroller.requestCategoryList.length) {
                    requestcategorycontroller.fetchNextPage();
                    debugPrint("Next page fetched for row index: $rowIndex");
                  }
                },
                source: RequestCategoryTableSource(
                  //we are passing data to the announcement table widget
                  context: context,
                  data: requestCata,
                ),
                columns: [
                  DataColumn2(
                    label: Text("Category Name", style: textTheme.bodySmall),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Description", style: textTheme.bodySmall),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Created At", style: textTheme.bodySmall),
                    size: ColumnSize.L,
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
