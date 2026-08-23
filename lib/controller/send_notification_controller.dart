import 'package:customer_care_webapp/services/push_notification_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendNotificationController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  final Rx<PushTarget> selectedTarget = PushTarget.all.obs;
  final RxString selectedTargetLabel =
      PushNotificationService.targetLabel(PushTarget.all).obs;
  final RxList<String> targetOptions = PushTarget.values
      .map(PushNotificationService.targetLabel)
      .toList()
      .obs;
  final RxBool isSending = false.obs;
  final RxString statusMessage = ''.obs;
  final RxBool isSuccess = false.obs;

  final PushNotificationService _pushService = PushNotificationService.instance;

  @override
  void onClose() {
    titleController.dispose();
    bodyController.dispose();
    super.onClose();
  }

  void setTarget(String? label) {
    if (label == null) return;
    final index = targetOptions.indexOf(label);
    if (index < 0) return;
    selectedTarget.value = PushTarget.values[index];
    selectedTargetLabel.value = label;
  }

  /// Clears title, message, and target — keeps status banners intact.
  void clearFormFields() {
    titleController.clear();
    bodyController.clear();
    selectedTarget.value = PushTarget.all;
    selectedTargetLabel.value =
        PushNotificationService.targetLabel(PushTarget.all);
    formKey.currentState?.reset();
  }

  /// Full reset: form fields, target, and any status/success messages.
  void resetForm() {
    clearFormFields();
    statusMessage.value = '';
    isSuccess.value = false;
    isSending.value = false;
  }

  Future<void> sendNotification() async {
    statusMessage.value = '';
    isSuccess.value = false;

    if (!(formKey.currentState?.validate() ?? false)) return;

    isSending.value = true;
    try {
      final result = await _pushService.sendBroadcast(
        title: titleController.text,
        body: bodyController.text,
        target: selectedTarget.value,
      );

      clearFormFields();
      isSuccess.value = true;
      statusMessage.value =
          'Notification sent to ${result.recipientCount} recipient(s) successfully.';
    } catch (e) {
      isSuccess.value = false;
      statusMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isSending.value = false;
    }
  }
}
