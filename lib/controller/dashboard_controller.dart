import 'package:get/state_manager.dart';

class DashboardController extends GetxController {
  final isDarkMode = false.obs;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }
}