import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/widgets/textformField.dart';
import 'package:flutter/material.dart';

class MainrowWidget extends StatelessWidget {
  final IconData mainicons;
  final String maintitle;
  final TextEditingController controller1;
  final TextEditingController controller2;
  final TextEditingController controller3;

  final String title1;
  final String title2;
  final String title3;

  final String hitntext1;
  final String hitntext2;
  final String hitntext3;

  // Custom validation functions (Nullable)
  final String? Function(String?)? validator1;
  final String? Function(String?)? validator2;
  final String? Function(String?)? validator3;

  final IconData? icon1;
  final IconData? icon2;
  final IconData? icon3;

  final TextInputType? input1;
  final TextInputType? input2;
  final TextInputType? input3;

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
    this.validator1,
    this.validator2,
    this.validator3,
    this.icon1,
    this.icon2,
    this.icon3,
    this.input1,
    this.input2,
    this.input3, required this.maintitle,
  });

  @override
  Widget build(BuildContext context) {
     final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Icon Badge
        Row(
          children: [
            Container(
              alignment: Alignment.center,
              height: 30,
              width: 30,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(mainicons, color: AppColors.primary, size: 15),
            ),
            const SizedBox(width: 8),
            Text(maintitle,style: textTheme.labelMedium,),
             const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 1,
                width: double.infinity,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 3 Text Fields Row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DynamicTextFormField(
                prefixicon: icon1,
                keyboardType: input1,
                labelText: title1,
                controller: controller1,
                hintText: hitntext1,
                validator: validator1,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DynamicTextFormField(
                keyboardType: input2,
                labelText: title2,
                prefixicon: icon2,
                controller: controller2,
                hintText: hitntext2,
                validator: validator2,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DynamicTextFormField(
                keyboardType: input3,
                labelText: title3,
                controller: controller3,
                prefixicon: icon3,
                hintText: hitntext3,
                validator: validator3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
