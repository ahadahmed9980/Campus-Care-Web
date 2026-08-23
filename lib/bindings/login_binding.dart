import 'package:customer_care_webapp/controller/login_controller.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController(), fenix: true);
  }
}
