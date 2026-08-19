import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final title;
  final VoidCallback callback;
  const CustomButton({super.key, required this.callback, required this.title});

  @override
  Widget build(BuildContext context) {
    return InkWell(onTap: callback,
      child: Container(
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
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
        child: Text(title, style: TextStyle(color: AppColors.darkText)),
      ),
    );
  }
}
