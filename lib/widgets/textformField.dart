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
    this.readOnly = false, this.horizontalwidth, this.verticalheigh,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null && widget.labelText!.isNotEmpty) ...[
          Text(
            widget.labelText!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: dashboardcontroller.isDarkMode.value
                  ? AppColors.darkText
                  : AppColors.lightText,
            ),
          ),
          const SizedBox(height: 5),
        ],

        SizedBox(
          width: double.infinity,
          child: TextFormField(
            controller: widget.controller,
            readOnly: widget.readOnly,
            keyboardType: widget.keyboardType,

            minLines: widget.minLines,
            maxLines: widget.maxLines,
            maxLength: widget.maxLength,

            cursorColor: Colors.black,
            cursorHeight: 18,

            style: TextStyle(
              fontSize: 13,
              color: dashboardcontroller.isDarkMode.value
                  ? AppColors.darkText
                  : AppColors.lightText,
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

              // Prefix icon null hone par bilkul extra space nahi lega
              prefixIcon: widget.prefixicon != null
                  ? Icon(widget.prefixicon, color: AppColors.grey)
                  : null,

              // Suffix icon null hone par bilkul extra space nahi lega
              suffixIcon: widget.suffixicon != null
                  ? InkWell(
                      onTap: widget.readOnly ? widget.callback : null,
                      child: Icon(widget.suffixicon, color: AppColors.grey),
                    )
                  : null,

              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.horizontalwidth ?? 16,
                vertical: widget.verticalheigh ?? 10,
              ),

              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.grey),
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.grey),
              ),

              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),

              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}
