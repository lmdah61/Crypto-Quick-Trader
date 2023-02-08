import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../utils/constants.dart';

// WARNING! The api data will be stored using GetStorage, not safe!
class SettingsController extends GetxController {
  final apiKey = "".obs;
  final apiSecret = "".obs;

  GetStorage box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }
  void saveSettings() {
    box.write(API_KEY_STORAGE_ID, apiKey.value);
    box.write(API_SECRET_STORAGE_ID, apiSecret.value);
  }

  void loadSettings() {
    apiKey.value = box.read(API_KEY_STORAGE_ID) ?? '';
    apiSecret.value = box.read(API_SECRET_STORAGE_ID) ?? '';
  }

}
