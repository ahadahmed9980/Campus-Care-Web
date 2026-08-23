import 'package:customer_care_webapp/controller/send_notification_controller.dart';
import 'package:get/get.dart';

class SendNotificationBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<SendNotificationController>()) {
      Get.find<SendNotificationController>().resetForm();
      return;
    }
    Get.lazyPut(() => SendNotificationController());
  }
}
