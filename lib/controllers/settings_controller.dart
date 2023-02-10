import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../services/binance_service.dart';
import '../utils/constants.dart';

// WARNING! The api data will be stored using GetStorage, not safe!
class SettingsController extends GetxController {
  final apiKey = "".obs;
  final apiSecret = "".obs;

  GetStorage storage = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }
  void saveSettings() {
    storage.write(API_KEY_STORAGE_ID, apiKey.value);
    storage.write(API_SECRET_STORAGE_ID, apiSecret.value);
  }

  void loadSettings() {
    apiKey.value = storage.read(API_KEY_STORAGE_ID) ?? '';
    apiSecret.value = storage.read(API_SECRET_STORAGE_ID) ?? '';
  }

  isThereAnOrderStillRunning() {
    return storage.read(ORDER_STORAGE_STATUS) ?? false;
  }

}
