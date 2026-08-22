import 'package:customer_care_webapp/controller/dashboard_controller.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class DynamicTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String? labelText;
  final double? horizontalwidth;
  final double? verticalheigh;

  final String hintText;
  final VoidCallback? callback;

  final IconData? suffixicon;
  final IconData? prefixicon;

  final String? Function(String?)? validator;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final bool readOnly;

  final TextInputType? keyboardType;
  final bool hasShadow;
  final double? borderRadius;
  final bool isLoading;

  const DynamicTextFormField({
    super.key,
    required this.controller,
    this.labelText,
    required this.hintText,
    this.callback,
    this.validator,
    this.prefixicon,
    this.suffixicon,
    this.keyboardType,
    this.minLines,
    this.maxLines,
    this.maxLength,
    this.readOnly = false,
    this.horizontalwidth,
    this.verticalheigh,
    this.hasShadow = false,
    this.borderRadius,
    this.isLoading = false,
  });

  @override
  State<DynamicTextFormField> createState() => _DynamicTextFormFieldState();
}

class _DynamicTextFormFieldState extends State<DynamicTextFormField> {
  bool isObscured = true;
  final dashboardcontroller = Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = dashboardcontroller.isDarkMode.value;
    final activeRadius = widget.borderRadius ?? (widget.hasShadow ? 16.0 : 10.0);

    Widget formField = TextFormField(
      controller: widget.controller,
      readOnly: widget.isLoading || widget.readOnly,
      keyboardType: widget.keyboardType,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      maxLength: widget.maxLength,
      cursorColor: isDark ? Colors.white : Colors.black,
      cursorHeight: 18,
      style: TextStyle(
        fontSize: 13,
        color: isDark ? AppColors.darkText : AppColors.lightText,
      ),
      validator: widget.validator,
      decoration: InputDecoration(
        isDense: true,
        hintText: widget.hintText,
        hintStyle: textTheme.labelMedium?.copyWith(color: AppColors.grey),
        errorStyle: textTheme.labelMedium?.copyWith(color: AppColors.red),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        counterStyle: textTheme.labelSmall,
        prefixIcon: widget.prefixicon != null
            ? Icon(widget.prefixicon, color: AppColors.grey)
            : null,
        suffixIcon: widget.suffixicon != null
            ? (widget.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.grey),
                      ),
                    ),
                  )
                : InkWell(
                    onTap: widget.callback,
                    child: Icon(widget.suffixicon, color: AppColors.grey),
                  ))
            : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.horizontalwidth ?? 16,
          vertical: widget.verticalheigh ?? 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(activeRadius),
          borderSide: widget.hasShadow ? BorderSide.none : const BorderSide(color: AppColors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(activeRadius),
          borderSide: widget.hasShadow ? BorderSide.none : const BorderSide(color: AppColors.grey),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(activeRadius),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(activeRadius),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );

    if (widget.hasShadow) {
      formField = Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(activeRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: formField,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.labelText != null && widget.labelText!.isNotEmpty) ...[
          Text(
            widget.labelText!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 5),
        ],
        SizedBox(
          width: double.infinity,
          child: formField,
        ),
        if (widget.labelText != null && widget.labelText!.isNotEmpty)
          const SizedBox(height: 10),
      ],
    );
  }
}
