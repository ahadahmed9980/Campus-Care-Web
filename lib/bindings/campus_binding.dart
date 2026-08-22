import 'package:customer_care_webapp/controller/campus_controller.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/bindings_interface.dart';
import 'package:get/get_instance/src/extension_instance.dart';

class CampusBinding extends Bindings{
    @override
  void dependencies() {
    Get.lazyPut(() => CampusController());
  }
}