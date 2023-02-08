import 'package:crypto_quick_trader/controllers/settings_controller.dart';
import 'package:get/get.dart';

import 'controllers/home_controller.dart';

class HomeScreenBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomeController());
  }
}

class SettingsScreenBindings implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SettingsController());
  }
}
