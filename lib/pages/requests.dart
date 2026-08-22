import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/controller/request_controller.dart';
import 'package:customer_care_webapp/models/request_model.dart';
import 'package:customer_care_webapp/utils/responseive.dart';
import 'package:customer_care_webapp/widgets/badges/prority_badge.dart';
import 'package:customer_care_webapp/widgets/custom_dataTable.dart';
import 'package:customer_care_webapp/widgets/custom_searchbar.dart';
import 'package:customer_care_webapp/widgets/customDropdownButton.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:customer_care_webapp/widgets/badges/status_badge.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Requests extends StatelessWidget {
  Requests({super.key});
  final requestcontroller = Get.find<RequestController>();

  Widget _buildFilters(BuildContext context, BoxConstraints constraints) {
    final dropdown1 = customFormDownbutton(
      context: context,
      selectedValue: requestcontroller.selectedStatus,
      items: requestcontroller.status,
    );
    final dropdown2 = customFormDownbutton(
      context: context,
      selectedValue: requestcontroller.selectedCategory,
      items: requestcontroller.categories,
    );
    final dropdown3 = customFormDownbutton(
      context: context,
      selectedValue: requestcontroller.selectedPriority,
      items: requestcontroller.priority,
    );
    final searchbar = CustomSearchbar(
      hinttext: "Search requests",
      searchcontroller: requestcontroller.searchrbar,
      onChanged: (value) {
        requestcontroller.searchRequests(value);
      },
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



class RequestTableSource extends DataTableSource {
  final requestcontroller = Get.find<RequestController>();
  final List<RequestModel> data;
  final BuildContext context;
  RequestTableSource({required this.data, required this.context});
  void _goToDetails(String requestId) {
    context.go('/request/$requestId');
  }

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) {
      return DataRow.byIndex(
        index: index,
        cells: List.generate(
          7,
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
    final request = data[index];
    return DataRow.byIndex(
      onSelectChanged: (selected) => {
        if (selected != null) {
          debugPrint("clicked"),
          _goToDetails(request.id),
        },
      },
      index: index,
      cells: [
        DataCell(Text(request.id.toString(),)),
        DataCell(Text(request.title.toString())),
        DataCell(Text(request.categoryId.toString())),
        DataCell(Text(request.location.toString())),
        DataCell(StatusBadge(status: request.status)),
        DataCell(ProrityBadge(priority: request.priority)),
        DataCell(Text(request.createdAt?.toDate().toString() ?? '')),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => (requestcontroller.isLoading.value && requestcontroller.requestList.isEmpty)
      ? false
      : requestcontroller.hasNextPage.value;

  @override
  int get rowCount => (requestcontroller.isLoading.value && requestcontroller.requestList.isEmpty)
      ? data.length
      : (requestcontroller.hasNextPage.value ? data.length + 1 : data.length);

  @override
  int get selectedRowCount => 0;
}

Widget _buildUI(BuildContext context, {required bool isMobile}) {
  final dashboardcontroller = Get.find<DashboardController>();
  final requestcontroller = Get.find<RequestController>();
  final textTheme = Theme.of(context).textTheme;

  return Obx(() {
    final isDark = dashboardcontroller.isDarkMode.value;
    final showSkeleton = requestcontroller.isLoading.value && requestcontroller.requestList.isEmpty;

    final requestsData = showSkeleton
        ? List.generate(
            requestcontroller.pageSize,
            (index) => RequestModel(
              id: 'mock_$index',
              userId: 'user_$index',
              title: 'Request Title $index',
              description: 'Mock Description $index',
              categoryId: 'Category $index',
              location: 'Block A Room $index',
              status: 'Submitted',
              priority: 'High',
              imageUrl: '',
              assignedDepartmentId: 'dept_$index',
              resolutionInfo: '',
              resolvedBy: '',
              createdAt: Timestamp.now(),
            ),
          )
        : requestcontroller.requestList.toList();

    return Skeletonizer(
      enabled: showSkeleton,
      child: CustomPaginatedTable(
        isDarkMode: isDark,
        isMobile: isMobile,
        onPageChanged: (rowIndex) {
          if (rowIndex + requestcontroller.pageSize >= requestcontroller.requestList.length) {
            requestcontroller.fetchNextPage(); 
            debugPrint("Next page fetched for row index: $rowIndex");
          }
        },
        source: RequestTableSource(
          context: context,
          data: requestsData,
        ),
        columns: [
          DataColumn2(label: Text("ID", style: textTheme.bodySmall), size: ColumnSize.M),
          DataColumn2(label: Text("Title", style: textTheme.bodySmall), size: ColumnSize.M),
          DataColumn2(label: Text("Category", style: textTheme.bodySmall), size: ColumnSize.M),
          DataColumn2(label: Text("Location", style: textTheme.bodySmall), size: ColumnSize.M),
          DataColumn2(label: Text("Status", style: textTheme.bodySmall), size: ColumnSize.M),
          DataColumn2(label: Text("Priority", style: textTheme.bodySmall), size: ColumnSize.M),
          DataColumn2(label: Text("Date", style: textTheme.bodySmall), size: ColumnSize.M),
        ],
      )
          .animate(key: ValueKey(showSkeleton))
          .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
          .slideY(begin: 0.05, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
    );
  });
}