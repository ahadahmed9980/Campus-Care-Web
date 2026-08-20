import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback callback;
  final bool? isLoading; // Nullable bool

  const CustomButton({
    super.key,
    required this.callback,
    required this.title,
    this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final bool loading = isLoading ?? false;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: loading ? null : callback, // Loading ke doran click disable
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
        child: loading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                title,
                style: TextStyle(
                  color: AppColors.darkText,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}