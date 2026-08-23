import 'package:customer_care_webapp/controller/send_notification_controller.dart';
import 'package:customer_care_webapp/utils/app_colors.dart';
import 'package:customer_care_webapp/widgets/custom_button.dart';
import 'package:customer_care_webapp/widgets/customDropdownButton.dart';
import 'package:customer_care_webapp/widgets/textformField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const _cardSubtitleStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  color: AppColors.grey,
  height: 1.45,
);

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<SendNotificationController>()) {
      Get.find<SendNotificationController>().resetForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SendNotificationController>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Send Notification',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create and send announcements to students and staff.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 28),
                _ComposeCard(controller: controller, isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ComposeCard extends StatelessWidget {
  const _ComposeCard({
    required this.controller,
    required this.isDark,
  });

  final SendNotificationController controller;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE6EAEF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.send_rounded,
                    color: AppColors.adaptivePrimary(context),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Compose Notification',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Write a clear title and message for your audience.',
                        style: _cardSubtitleStyle,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            DynamicTextFormField(
              labelText: 'Notification Title',
              controller: controller.titleController,
              hintText: 'Enter notification title…',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Title is required';
                }
                if (value.trim().length < 3) {
                  return 'Title must be at least 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DynamicTextFormField(
              labelText: 'Message Body',
              controller: controller.bodyController,
              hintText: 'Enter notification message…',
              minLines: 5,
              maxLines: 8,
              maxLength: 500,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Message is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            customFormDownbutton(
              context: context,
              labelText: 'Target Audience',
              hintText: 'Select audience',
              selectedValue: controller.selectedTargetLabel,
              items: controller.targetOptions,
              onChanged: controller.setTarget,
            ),
            const SizedBox(height: 24),
            Obx(() {
              final message = controller.statusMessage.value;
              if (message.isEmpty) return const SizedBox.shrink();

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: controller.isSuccess.value
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: controller.isSuccess.value
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : Colors.redAccent.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      controller.isSuccess.value
                          ? Icons.check_circle_outline
                          : Icons.error_outline,
                      size: 20,
                      color: controller.isSuccess.value
                          ? AppColors.primary
                          : Colors.redAccent,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.4,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: Obx(
                () => CustomButton(
                  title: 'Send Notification',
                  isLoading: controller.isSending.value,
                  callback: controller.sendNotification,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
