import 'package:customer_care_webapp/controller/request_detail_controller.dart';
import 'package:customer_care_webapp/models/request_model.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/utils/responseive.dart';
import 'package:customer_care_webapp/widgets/badges/prority_badge.dart';
import 'package:customer_care_webapp/widgets/badges/status_badge.dart';
import 'package:customer_care_webapp/widgets/customDropdownButton.dart';
import 'package:customer_care_webapp/widgets/custom_button.dart';
import 'package:customer_care_webapp/widgets/textformField.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestDetail extends StatelessWidget {
  final String requestId;
  const RequestDetail({super.key, required this.requestId});

  Widget _buildContainers(
    BuildContext context,
    BoxConstraints constraints,
    RequestModel requestModel,
  ) {
    if (constraints.maxWidth < 600) {
      final detailcontainer = container1(context, requestModel)
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.05, end: 0, duration: 400.ms);
      final statusContainer = container2(context, requestModel)
          .animate()
          .fadeIn(delay: 150.ms, duration: 400.ms)
          .slideY(begin: 0.05, end: 0, duration: 400.ms);

      return Column(
        children: [
          detailcontainer,
          const SizedBox(height: 10),
          statusContainer,
        ],
      );
    } else if (constraints.maxWidth < 1024) {
      final detailcontainer = container1(context, requestModel)
          .animate()
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.05, end: 0, duration: 400.ms);
      final statusContainer = container2(context, requestModel)
          .animate()
          .fadeIn(delay: 150.ms, duration: 400.ms)
          .slideY(begin: 0.05, end: 0, duration: 400.ms);

      return Column(
        children: [
          detailcontainer,
          const SizedBox(height: 10),
          statusContainer,
        ],
      );
    } else {
      final detailcontainer = container1(context, requestModel)
          .animate()
          .fadeIn(duration: 400.ms)
          .slideX(begin: -0.05, end: 0, duration: 400.ms);
      final statusContainer = container2(context, requestModel)
          .animate()
          .fadeIn(delay: 200.ms, duration: 400.ms)
          .slideX(begin: 0.05, end: 0, duration: 400.ms);

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
    final textTheme = Theme.of(context).textTheme;
    final requestDetailcontroller = Get.find<RequestDetailController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestDetailcontroller.fetchRequestDetails(requestId);
    });

    return Scaffold(
      body: Obx(() {
        final showSkeleton = requestDetailcontroller.isLoading.value &&
            requestDetailcontroller.request.value == null;

        if (requestDetailcontroller.isError.value ||
            (!showSkeleton && requestDetailcontroller.request.value == null)) {
          return const Center(child: Text("Error loading request details."));
        }

        final requestModel = showSkeleton
            ? RequestModel(
                id: '12345',
                userId: 'user_123',
                title: 'Water leakage in Block B Room 102',
                description: 'Mock Description about leakage in the bathroom washbasin area. Requires plumbing repair.',
                categoryId: 'Plumbing',
                location: 'Block B Room 102',
                status: 'Under Review',
                priority: 'High',
                imageUrl: '',
                assignedDepartmentId: 'dept_123',
                resolutionInfo: '',
                resolvedBy: '',
                createdAt: Timestamp.now(),
              )
            : requestDetailcontroller.request.value!;

        final isClosed = !showSkeleton && requestModel.status.trim().toLowerCase() == "closed";

        return Skeletonizer(
          enabled: showSkeleton,
          child: LayoutBuilder(
            builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isTablet = constraints.maxWidth < 1024;

            Widget buildHeaderControls(bool isMobileScreen) {
              final remarksField = DynamicTextFormField(
                controller: requestDetailcontroller.resolutionInfo,
                hintText: "Enter remarks",
                labelText: "Remarks",
                suffixicon: Icons.send_outlined,
                isLoading: requestDetailcontroller.isRemarksLoading.value,
                callback: () {
                  requestDetailcontroller.updateResolutionInfo();
                },
              );

              final deptDropdown = customFormDownbutton(
                context: context,
                selectedValue: requestDetailcontroller.selectedDepartmentName,
                items: requestDetailcontroller.departmentNames,
                enabled: !isClosed,
                hintText: "Assign Department",
                labelText: "Department",
                isLoading: requestDetailcontroller.isDepartmentLoading.value,
                onChanged: (value) {
                  if (value != null) {
                    requestDetailcontroller.updateAssignedDepartment(value);
                  }
                },
              );

              final statusDropdown = customFormDownbutton(
                context: context,
                selectedValue: requestDetailcontroller.selectedStatus,
                items: requestDetailcontroller.status,
                enabled: !isClosed,
                hintText: "Select status",
                labelText: "Status",
                isLoading: requestDetailcontroller.isStatusLoading.value,
              );

              final statusUpdateButton = CustomButton(
                title: "Update Status",
                isLoading: requestDetailcontroller.isStatusLoading.value,
                callback: isClosed
                    ? () {}
                    : () {
                        requestDetailcontroller.applyPendingStatusUpdate();
                      },
              );

              if (isMobileScreen) {
                return Column(
                  children: [
                    remarksField,
                    const SizedBox(height: 10),
                    deptDropdown,
                    const SizedBox(height: 10),
                    statusDropdown,
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: statusUpdateButton,
                    ),
                  ],
                );
              } else {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: remarksField),
                    const SizedBox(width: 10),
                    Expanded(child: deptDropdown),
                    const SizedBox(width: 10),
                    Expanded(child: statusDropdown),
                    const SizedBox(width: 10),
                    statusUpdateButton,
                  ],
                );
              }
            }

            final headerAndoverview = Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!Responsive.isMobileScreen(context)) ...{
                    Text("Request Details", style: textTheme.headlineLarge),
                    const SizedBox(height: 10),
                  },
                  if (constraints.maxWidth >= 1024)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Requests / ${requestModel.id}",
                          style: textTheme.labelLarge,
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 700),
                              child: buildHeaderControls(false),
                            ),
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Requests / ${requestModel.id}",
                          style: textTheme.labelLarge,
                        ),
                        const SizedBox(height: 10),
                        buildHeaderControls(isMobile),
                      ],
                    ),
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
                        children: [
                          _buildContainers(context, constraints, requestModel),
                        ],
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
                        children: [
                          _buildContainers(context, constraints, requestModel),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  headerAndoverview,
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: _buildContainers(
                          context,
                          constraints,
                          requestModel,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      );
    }),
    );
  }
}

Widget detailRows(BuildContext context, String name, String detail) {
  final textTheme = Theme.of(context).textTheme;
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 2,
        child: Text(
          name,
          style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Expanded(
        flex: 3,
        child: Text(
          detail,
          style: textTheme.labelLarge,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

Widget container1(BuildContext context, RequestModel requestModel) {
  final size = MediaQuery.of(context).size;
  final textTheme = Theme.of(context).textTheme;
  final requestDetailcontroller = Get.find<RequestDetailController>();

  final dateStr = requestModel.createdAt != null
      ? DateFormat(
          'dd MMMM yyyy - hh:mm a',
        ).format(requestModel.createdAt!.toDate())
      : '';

  final resolvedDateStr = requestModel.resolvedAt != null
      ? DateFormat(
          'dd MMMM yyyy - hh:mm a',
        ).format(requestModel.resolvedAt!.toDate())
      : '';

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).cardColor,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusBadge(status: requestModel.status),
        const SizedBox(height: 10),
        detailRows(context, "Title", requestModel.title),
        const SizedBox(height: 10),
        detailRows(
          context,
          "Category",
          requestDetailcontroller.categoryName.value,
        ),
        const SizedBox(height: 10),
        detailRows(context, "Location", requestModel.location),
        const SizedBox(height: 10),
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
                child: ProrityBadge(priority: requestModel.priority),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        detailRows(
          context,
          "Submitted by",
          requestDetailcontroller.userName.value,
        ),
        const SizedBox(height: 10),
        detailRows(context, "Date Submitted", dateStr),
        const SizedBox(height: 10),
        detailRows(context, "Description", requestModel.description),
        const SizedBox(height: 10),
        detailRows(
          context,
          "Assigned Department",
          requestDetailcontroller.departmentName.value,
        ),

        if (requestModel.status.trim().toLowerCase() == 'resolved' ||
            requestModel.resolutionInfo.isNotEmpty) ...[
          const SizedBox(height: 10),
          detailRows(
            context,
            "Resolution Info",
            requestModel.resolutionInfo.isEmpty
                ? 'No info'
                : requestModel.resolutionInfo,
          ),
          const SizedBox(height: 10),
          detailRows(
            context,
            "Resolved By",
            requestModel.resolvedBy.isEmpty ? 'N/A' : requestModel.resolvedBy,
          ),
          const SizedBox(height: 10),
          detailRows(
            context,
            "Date Resolved",
            resolvedDateStr.isEmpty ? 'N/A' : resolvedDateStr,
          ),
        ],

        if (requestModel.imageUrl.isNotEmpty) ...[
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "Image",
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: size.width * 0.2,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.network(
                      requestModel.imageUrl,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.broken_image, size: 50);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget container2(BuildContext context, RequestModel requestModel) {
  final textTheme = Theme.of(context).textTheme;
  final requestDetailcontroller = Get.find<RequestDetailController>();

  return Container(
    padding: const EdgeInsets.all(16),
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
        const SizedBox(height: 10),
        Column(
          children: requestDetailcontroller.statusHistory.isEmpty
              ? [
                  statusTimeline(
                    context,
                    requestModel.status,
                    requestModel.createdAt != null
                        ? DateFormat(
                            'dd MMM yyyy - hh:mm a',
                          ).format(requestModel.createdAt!.toDate())
                        : '',
                    'Request status is currently ${requestModel.status}',
                    AppColors.primary,
                    Colors.transparent,
                    isLast: true,
                  ),
                ]
              : requestDetailcontroller.statusHistory.asMap().entries.map((
                  entry,
                ) {
                  final index = entry.key;
                  final history = entry.value;
                  final isLast =
                      index == requestDetailcontroller.statusHistory.length - 1;

                  final timeStr = history.createdAt != null
                      ? DateFormat(
                          'dd MMM yyyy - hh:mm a',
                        ).format(history.createdAt!.toDate())
                      : '';

                  final statusColor = switch (history.status.toLowerCase()) {
                    'submitted' => AppColors.primary,
                    'under review' => AppColors.blue,
                    'in progress' => AppColors.orange,
                    'resolved' => Colors.green,
                    'closed' => Colors.teal,
                    _ => AppColors.grey,
                  };

                  return statusTimeline(
                    context,
                    history.status,
                    timeStr,
                    history.message,
                    statusColor,
                    isLast ? Colors.transparent : AppColors.grey,
                    isLast: isLast,
                  );
                }).toList(),
        ),
      ],
    ),
  );
}

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

  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Column(
          children: [
            Container(
              height: 15,
              width: 15,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            if (!isLast)
              Expanded(child: Container(width: 1.5, color: lineColor)),
          ],
        ),
        const SizedBox(width: 20),
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
              Text(
                time,
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ],
    ),
  );
}
