import 'package:customer_care_webapp/controller/request_detail_controller.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/utils/responseive.dart';
import 'package:customer_care_webapp/widgets/badges/prority_badge.dart';
import 'package:customer_care_webapp/widgets/badges/status_badge.dart';

import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class RequestDetail extends StatelessWidget {
  const RequestDetail({super.key});

  Widget _buildContainers(BuildContext context, BoxConstraints constraints) {
    final detailcontainer = container1(context);
    final statusContainer = container2(context);
    if (constraints.maxWidth < 600) {
      return Column(
        children: [
          detailcontainer,
          const SizedBox(height: 10),

          statusContainer,
        ],
      );
    } else if (constraints.maxWidth < 1024) {
      return Column(
        children: [
          detailcontainer,
          const SizedBox(height: 10),

          statusContainer,
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(flex: 2, child: detailcontainer),
          const SizedBox(width: 10),
          Expanded(flex: 1, child: statusContainer),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    final requestDetailcontroller = Get.find<RequestDetailController>();

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isTablet = constraints.maxWidth < 1024;

          //header
          final headerAndoverview = Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!Responsive.isMobileScreen(context)) ...{
                  Text("Requests Details", style: textTheme.headlineLarge),
                  const SizedBox(height: 10),
                },
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Requests / REQ-2024-1058",
                      style: textTheme.labelLarge,
                    ),
                    //button
                    // update status
                    Obx(() {
                      // applying logic if controller value == is closed then admin is not able to change its value

                      final currentVal =
                          requestDetailcontroller.selectedStatus.value;
                      final isClosed = currentVal == "Closed";
                      return SizedBox(
                        width: 200,

                        child: DropdownButtonFormField<String>(
                          borderRadius: BorderRadius.circular(16),

                          // autofocus: true,
                          // Agar current value list mai exist krti hai to wahi value pass ho, warna strictly NULL
                          value:
                              requestDetailcontroller.status.contains(
                                currentVal,
                              )
                              ? currentVal
                              : null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Theme.of(context).cardColor,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
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
                              borderSide: BorderSide(
                                color: AppColors.grey,
                                width: 1.5,
                              ),
                            ),
                          ),
                          // Jab closed ho to arrow icon hide ya grey kar sakte hain
                          icon: isClosed
                              ? const SizedBox.shrink()
                              : const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.grey,
                                ),
                          style: textTheme.labelMedium,
                          items: requestDetailcontroller.status.map((status) {
                            return DropdownMenuItem<String>(
                              value: status,
                              child: Text(status),
                            );
                          }).toList(),

                          onChanged: isClosed
                              ? null
                              : (value) {
                                  if (value != null) {
                                    requestDetailcontroller
                                            .selectedStatus
                                            .value =
                                        value;
                                    print(
                                      "the value of selected status is ${requestDetailcontroller.selectedStatus} ",
                                    );
                                  }
                                },
                        ),
                      );
                    }),
                  ],
                ),

                // const SizedBox(height: 10),
              ],
            ),
          );

          if (isMobile) {
            return Column(
              children: [
                headerAndoverview,
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [_buildContainers(context, constraints)],
                    ),
                  ),
                ),
              ],
            );
          } else if (isTablet) {
            return Column(
              children: [
                headerAndoverview,
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [_buildContainers(context, constraints)],
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                headerAndoverview,
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: _buildContainers(context, constraints),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
//detail row

Widget detailRows(BuildContext context, String name, String detail) {
  final textTheme = Theme.of(context).textTheme;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Left Title (Flex 2)
      Expanded(
        flex: 2,
        child: Text(
          name,
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      // Right Value (Flex 3)
      Expanded(
        flex: 3,
        child: Text(
          detail,
          style: textTheme.labelLarge,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

// container 1 detail container

Widget container1(BuildContext context) {
  final size = MediaQuery.of(context).size;
  final textTheme = Theme.of(context).textTheme;
  final requestDetailcontroller = Get.find<RequestDetailController>();
  return Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).cardColor,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          return StatusBadge(
            status: requestDetailcontroller.selectedStatus.value,
          );
        }),
        SizedBox(height: 10),
        detailRows(context, "Category", "Electricity"),
        SizedBox(height: 10),
        detailRows(context, "Location", "Block A Room 203"),
        SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                "Priority",
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ProrityBadge(priority: "High"),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        detailRows(context, "Submitted by", "Ahad Ahmed (22-SE-1015)"),

        SizedBox(height: 10),
        detailRows(context, "Date Submitted", "16 August - 10:30 AM"),
        SizedBox(height: 10),

        detailRows(
          context,
          "Description",
          "The celing fan of room no 203 is not working kindly fix it ",
        ),
        SizedBox(height: 10),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Image",
              style: textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),

            Spacer(),
            Container(
              width: size.width * 0.2,

              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Image.network(
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQqtugtgfaFtEMMDCJyhFrvVC--JhdRcQ_IeYj2BMn39ICsxli5DEXAg2bBVsRmbltJFcIkruJAoEW5_cuRpsMjcclU2aoWaGqoEnAe&s&ec=121924562",
              ),
            ),

            Spacer(),
          ],
        ),

        // category
      ],
    ),
  );
}

//container 2
Widget container2(BuildContext context) {
  // final size = MediaQuery.of(context).size;
  final textTheme = Theme.of(context).textTheme;
  final requestDetailcontroller = Get.find<RequestDetailController>();
  return Obx(() {
    //using this to set color
    final currentStatus = requestDetailcontroller.selectedStatus.value;
    return Container(
      // height: 300,
      // height: 588,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).cardColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Status TimeLine",
            style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          //main row
          Column(
            children: [
              //row with complete timeline and text
              statusTimeline(
                context,
                "Submitted",
                "12 May 2024 - 10:30 AM",
                "Request submitted by student",
                requestDetailcontroller.getStepColor(
                  "Submitted",
                  currentStatus,
                  AppColors.primary,
                ),
                requestDetailcontroller.getLineColor(
                  "Submitted",
                  currentStatus,
                  AppColors.primary,
                ),
              ),
              statusTimeline(
                context,
                "Under review",
                "12 May 2024 - 10:30 AM",
                "Request is under review",
                requestDetailcontroller.getStepColor(
                  "Under review",
                  currentStatus,
                  AppColors.blue,
                ),
                requestDetailcontroller.getLineColor(
                  "Under review",
                  currentStatus,
                  AppColors.primary,
                ),
              ),
              statusTimeline(
                context,
                "In Progress",
                "12 May 2024 - 10:30 AM",
                "Work has benn assigned",
                requestDetailcontroller.getStepColor(
                  "In Progress",
                  currentStatus,
                  AppColors.orange,
                ),
                requestDetailcontroller.getLineColor(
                  "In Progress",
                  currentStatus,
                  AppColors.orange,
                ),
              ),
              statusTimeline(
                context,
                "Resolved",
                "",
                "",
                requestDetailcontroller.getStepColor(
                  "Resolved",
                  currentStatus,
                  Colors.green,
                ),
                requestDetailcontroller.getLineColor(
                  "Resolved",
                  currentStatus,
                  Colors.green,
                ),
              ),
              statusTimeline(
                context,
                "Closed",
                "",
                "",
                requestDetailcontroller.getStepColor(
                  "Closed",
                  currentStatus,
                  Colors.teal,
                ),
                requestDetailcontroller.getLineColor(
                  "Closed",
                  currentStatus,
                  Colors.teal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  });
}

// status time line widget
Widget statusTimeline(
  BuildContext context,
  String name,
  String time,
  String description,
  Color color,
  Color lineColor, {
  bool isLast = false,
}) {
  final textTheme = Theme.of(context).textTheme;

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Timeline Dot & Line
      Column(
        children: [
          Container(
            height: 15,
            width: 15,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          if (!isLast) Container(height: 60, width: 1.5, color: lineColor),
        ],
      ),
      const SizedBox(width: 20),

      // Text Details
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            if (!isLast)
              Text(
                time,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            const SizedBox(height: 5),
            if (!isLast)
              Text(
                description,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey,
                ),
              ),
          ],
        ),
      ),
    ],
  );
}
