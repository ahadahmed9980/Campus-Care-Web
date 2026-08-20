import 'package:customer_care_webapp/controller/forgot_password_controller.dart';
import 'package:get/get.dart';

class ForgotPasswordBinding extends Bindings {
  ForgotPasswordBinding({this.initialEmail});

  final String? initialEmail;

  @override
  void dependencies() {
    if (Get.isRegistered<ForgotPasswordController>()) {
      Get.delete<ForgotPasswordController>();
    }
    Get.put(ForgotPasswordController(initialEmail: initialEmail));
  }
}
