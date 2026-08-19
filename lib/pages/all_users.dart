import 'package:customer_care_webapp/controller/all_usersController.dart';
import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/models/user_model.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/utils/responseive.dart';
import 'package:customer_care_webapp/widgets/custom_button.dart';
import 'package:customer_care_webapp/widgets/custom_dataTable.dart';
import 'package:customer_care_webapp/widgets/custom_searchbar.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AllUsers extends StatelessWidget {
  const AllUsers({super.key});

  Widget _buildFilters(BuildContext context, BoxConstraints constraints) {
    final allusercontroller = Get.find<AllUserscontroller>();
    final searchbar = CustomSearchbar(
      hinttext: "search users",
      searchcontroller: allusercontroller.searchcontroller,
    );

    final updateStatusButton = CustomButton(
      callback: () {},
      title: "Update status",
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
                  Text("Users", style: textTheme.headlineLarge),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Text(
                        "Managed registered students",
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

class UsersTableSource extends DataTableSource {
  final AllUserscontroller allusercontroller = Get.find<AllUserscontroller>();
  final List<UserModel> data;
  final BuildContext context;

  UsersTableSource({required this.data, required this.context});

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final user = data[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(user.name ?? '')),
        DataCell(Text(user.studentId ?? '')),
        DataCell(Text(user.email ?? '')),
        DataCell(Text(user.department ?? '')),
        DataCell(Text(user.semester?.toString() ?? '')),
        DataCell(
          TableActions(
            onDelete: () {
              debugPrint("Delete tapped for: ${user.id}");
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate =>
      (allusercontroller.isLoading.value && allusercontroller.userList.isEmpty)
      ? false
      : allusercontroller.hasNextPage.value;

  @override
  int get rowCount =>
      (allusercontroller.isLoading.value && allusercontroller.userList.isEmpty)
      ? data.length
      : (allusercontroller.hasNextPage.value ? data.length + 1 : data.length);

  @override
  int get selectedRowCount => 0;
}

// table builder by using custom widget
Widget _buildUI(BuildContext context, {required bool isMobile}) {
  final dashboardcontroller = Get.find<DashboardController>();
  final allusercontroller = Get.find<AllUserscontroller>();
  final textTheme = Theme.of(context).textTheme;

  return Obx(() {
    final isDark = dashboardcontroller.isDarkMode.value;
    final showSkeleton =
        allusercontroller.isLoading.value && allusercontroller.userList.isEmpty;

    final usersData = showSkeleton
        ? List.generate(
            allusercontroller.pageSize,
            (index) => UserModel(
              id: 'mock_$index',
              name: 'Student Name $index',
              studentId: '22-SE-$index',
              email: 'student$index@example.com',
              department: 'Software Engineering',
              semester: 4,
            ),
          )
        : allusercontroller.userList.toList();

    return Skeletonizer(
      enabled: showSkeleton,
      child:
          CustomPaginatedTable(
                isDarkMode: isDark,
                isMobile: isMobile,
                minWidth: 1000,
                onPageChanged: (rowIndex) {
                  if (rowIndex + allusercontroller.pageSize >=
                      allusercontroller.userList.length) {
                    allusercontroller.fetchNextPage();
                    debugPrint("Next page fetched for row index: $rowIndex");
                  }
                },
                source: UsersTableSource(context: context, data: usersData),
                columns: [
                  DataColumn2(
                    label: Text("Name", style: textTheme.bodySmall),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Student ID", style: textTheme.bodySmall),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Email", style: textTheme.bodySmall),
                    size: ColumnSize.L,
                  ),
                  DataColumn2(
                    label: Text("Department", style: textTheme.bodySmall),
                    size: ColumnSize.M,
                  ),
                  DataColumn2(
                    label: Text("Semester", style: textTheme.bodySmall),
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

  const TableActions({super.key, this.onDelete});

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
            onTap: onDelete,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.all(4.0),
              child: Icon(
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
