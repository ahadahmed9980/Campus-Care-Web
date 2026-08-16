import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/utils/responseive.dart';
import 'package:customer_care_webapp/widgets/badges/prority_badge.dart';
import 'package:customer_care_webapp/widgets/badges/status_badge.dart';

import 'package:flutter/material.dart';

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
      return Row(
        children: [
          Expanded(flex: 2, child: detailcontainer),
          const SizedBox(width: 10),
          Expanded(flex: 1, child: statusContainer),
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
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          //header
          final headerAndoverview = Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!Responsive.isMobileScreen(context)) ...{
                  Text("Requests Details", style: textTheme.headlineLarge),
                  const SizedBox(height: 15),
                },
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Requests / REQ-2024-1058",
                      style: textTheme.labelLarge,
                    ),
                    //button
                    Container(
                      height: 35,
                      padding: EdgeInsets.all(10),

                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(10),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Text(
                        "Update status",
                        style: TextStyle(color: AppColors.darkText),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),
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
          style: textTheme.labelLarge,
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
  return Container(
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).cardColor,
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StatusBadge(status: "In Progress"),
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
                style: textTheme.labelLarge,
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
              style: textTheme.labelLarge,
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
  // final textTheme = Theme.of(context).textTheme;
  return Container(
    // height: 300,
    height: 588,
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: Theme.of(context).cardColor,
      
    ),
  );
}
