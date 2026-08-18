import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';

class CustomPaginatedTable extends StatelessWidget {
  final List<DataColumn2> columns;
  final DataTableSource source;
  final bool isDarkMode;
  final bool isMobile;
  final int rowsPerPage;
  final List<int> availableRowsPerPage;
  final double minWidth;
  final double height;
  final ValueChanged<int>? onPageChanged; // changing page value 

  const CustomPaginatedTable({
    super.key,
    required this.columns,
    required this.source,
    required this.isDarkMode,
    required this.isMobile,
    this.rowsPerPage = 5,
    this.availableRowsPerPage = const [5, 10],
    this.minWidth = 1000,
    this.height = 450,
    this.onPageChanged, 
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDarkMode ? AppColors.darkCard : AppColors.lightCard;

    final table = PaginatedDataTable2(
      fixedTopRows: 1,
      rowsPerPage: rowsPerPage,
      availableRowsPerPage: availableRowsPerPage,
      showCheckboxColumn: false,
      onPageChanged: onPageChanged, // <-- 3. PaginatedDataTable2 ko pass kar dein
      minWidth: isMobile ? minWidth : 600,
      border: TableBorder(
        horizontalInside: BorderSide(
          color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      headingRowColor: WidgetStateProperty.all(
        isDarkMode ? AppColors.lightText : AppColors.lightBackground,
      ),
      columns: columns,
      source: source,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: height,
          child: isMobile
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(width: minWidth, child: table),
                )
              : table,
        ),
      ),
    );
  }
}