import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/widgets/textformField.dart';
import 'package:flutter/material.dart';

class MainrowWidget extends StatelessWidget {
  final IconData mainicons;
  final TextEditingController controller1;
  final String title1;
  final TextInputType? input1;
  final TextInputType? input2;
  final TextInputType? input3;


  final String validate1;
  final String hitntext1;
  final IconData ?icon1;
  final String title2;

  final String hitntext2;
  final String title3;
  final String validate2;
  final IconData? icon2;

  final String hitntext3;
  final String? validate3;
  final IconData? icon3;

  final TextEditingController controller2;
  final TextEditingController controller3;
  const MainrowWidget({
    super.key,
    required this.controller1,
    required this.controller2,
    required this.controller3,
    required this.mainicons,
    required this.title1,

    required this.title2,

    required this.title3,

    required this.hitntext1,
    required this.hitntext2,
    required this.hitntext3,
    required this.validate1,
    required this.validate2,
    this.validate3,
    this.icon1,
  this.icon2,
    this.icon3, this.input1, this.input2, this.input3,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              height: 30,
              width: 30,
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(mainicons, color: AppColors.primary, size: 15),
            ),
          ],
        ),
        SizedBox(height: 5),
        Row(
          children: [
            Expanded(
              child: DynamicTextFormField(
                prefixicon: icon1,
                keyboardType: input1,
                labelText: title1,
                controller: controller1,
                hintText: hitntext1,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return validate1;
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: DynamicTextFormField(
                keyboardType: input2,
                labelText: title1,
                prefixicon: icon2,
                controller: controller2,
                hintText: hitntext3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return validate2;
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: DynamicTextFormField(
                keyboardType: input3,
                labelText: title3,
                controller: controller3,
                prefixicon: icon3,
                hintText: hitntext3,
                // validator: (value) {
                //   if (value == null || value.isEmpty) {
                //     return 'Please enter title';
                //   }

                //   return null;
                // },
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ],
    );
  }
}
