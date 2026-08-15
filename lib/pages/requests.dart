import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/controller/request_controller.dart';
import 'package:customer_care_webapp/models/request_model.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/utils/responseive.dart';
import 'package:customer_care_webapp/widgets/badges/prority_badge.dart';
import 'package:customer_care_webapp/widgets/custom_searchbar.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:customer_care_webapp/widgets/badges/status_badge.dart';

class Requests extends StatelessWidget {
  Requests({super.key});
  final requestcontroller = Get.find<RequestController>();
  // final dashboardcontroller = Get.find<DashboardController>();

  Widget _buildFilters(BuildContext context, BoxConstraints constraints) {
    final dropdown1 = customDropDownbutton(
      context: context,
      selectedValue: requestcontroller.selectedStatus,
      items: requestcontroller.status,
    );
    final dropdown2 = customDropDownbutton(
      context: context,
      selectedValue: requestcontroller.selectedStatus,
      items: requestcontroller.status,
    );
    final dropdown3 = customDropDownbutton(
      context: context,
      selectedValue: requestcontroller.selectedStatus,
      items: requestcontroller.status,
    );
    final searchbar = CustomSearchbar(
      hinttext: "Search requests",
      searchcontroller: requestcontroller.searchrbar,
    );

    if (constraints.maxWidth < 600) {
      return Column(
        children: [
          dropdown1,
          const SizedBox(height: 10),
          dropdown2,
          const SizedBox(height: 10),
          dropdown3,
          const SizedBox(height: 10),
          searchbar,
        ],
      );
    } else if (constraints.maxWidth < 1024) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: dropdown1),
              const SizedBox(width: 10),
              Expanded(child: dropdown2),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: dropdown3),
              const SizedBox(width: 10),
              Expanded(child: searchbar),
            ],
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(child: dropdown1),
          const SizedBox(width: 10),
          Expanded(child: dropdown2),
          const SizedBox(width: 10),
          Expanded(child: dropdown3),
          const SizedBox(width: 10),
          Expanded(child: searchbar),
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
                  Text("Requests", style: textTheme.headlineLarge),
                  const SizedBox(height: 15),
                  Text(
                    "Manage all students requests",
                    style: textTheme.labelLarge,
                  ),
                ],
                const SizedBox(height: 15),
                _buildFilters(context, constraints),
              ],
            ),
          );

          if (isMobile) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
            
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
                Expanded(
                  child: _buildUI(context, isMobile: false),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}

//custom reusable dropdown menu
Widget customDropDownbutton({
  required BuildContext context,
  required RxString selectedValue,
  required RxList<String> items,
}) {
  // final requestcontroller = Get.find<RequestController>();
  // final size = MediaQuery.of(context).size;
  final textTheme = Theme.of(context).textTheme;
  return Obx(
    () => Container(
      // width: 200,
      // padding: const EdgeInsets.all(10),
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

        // autofocus: true,
        value: selectedValue.value,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.grey, width: 1.5),
          ),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey),
        style: textTheme.labelMedium,
        items: items.map((status) {
          return DropdownMenuItem<String>(value: status, child: Text(status));
        }).toList(),

        onChanged: (value) {
          if (value != null) {
            selectedValue.value = value;
          }
        },
      ),
    ),
  );
}

class requestTableSource extends DataTableSource {
  final List<RequestModel> data;
  final BuildContext context;
  requestTableSource({required this.data, required this.context});
  void _goToDetails() {
    context.go('/request-details');
  }

  @override
  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final request = data[index];
    return DataRow.byIndex(
      //going to next detail page
      onSelectChanged: (selected) => {
        if (selected != null) {print("clicked"), _goToDetails()},
      },
      index: index,
      cells: [
        DataCell(Text(request.id.toString())),
        DataCell(Text(request.title.toString())),
        DataCell(Text(request.category.toString())),
        DataCell(Text(request.location.toString())),
        DataCell(StatusBadge(status: request.status)),
        DataCell(ProrityBadge(priority: request.priority)),
        DataCell(Text(request.date.toString())),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

Widget _buildUI(BuildContext context, {required bool isMobile}) {
  final dashboardcontroller = Get.find<DashboardController>();
  final requestTableSource datasource = requestTableSource(
    context: context,
    data: requestList,
  );
  final textTheme = Theme.of(context).textTheme;

  return Obx(() {
    final isDark = dashboardcontroller.isDarkMode.value;
    final borderColor = isDark ? AppColors.darkCard : AppColors.lightCard;

    final table = PaginatedDataTable2(
      fixedTopRows: 1,
      rowsPerPage: 5,
      availableRowsPerPage: const [5, 10],
      showCheckboxColumn: false,
      minWidth: isMobile ? 1000 : 600,

      border: TableBorder(
        horizontalInside: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      headingRowColor: WidgetStateProperty.all(
        isDark ? AppColors.lightText : AppColors.lightBackground,
      ),
      columns: [
        DataColumn2(
          label: Text("ID", style: textTheme.bodySmall),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text("Title", style: textTheme.bodySmall),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text("Category", style: textTheme.bodySmall),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text("Location", style: textTheme.bodySmall),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text("Status", style: textTheme.bodySmall),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text("Priority", style: textTheme.bodySmall),
          size: ColumnSize.M,
        ),
        DataColumn2(
          label: Text("Date", style: textTheme.bodySmall),
          size: ColumnSize.M,
        ),
      ],
      source: datasource,
    );

    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: 450,
          child: isMobile
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: 1000,
                    child: table,
                  ),
                )
              : table,
        ),
      ),
    );
  });
}

