import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../services/binance_service.dart';
import '../utils/constants.dart';

class HomeController extends GetxController {
  GetStorage box = GetStorage();
  late BinanceService _binanceService;

  var isOrderActive = false.obs;
  late String activeOrderId = '';

  var initPrice = 0.0.obs;
  var targetValue = 0.0.obs;
  var stopValue = 0.0.obs;

  Future<void> init() async {
    // Get previous order data from storage
    loadOrderData();
    // Check if an order is already active
    if (!isThereAnOrderStillRunning()) {
      isOrderActive = false.obs;
      activeOrderId = '';
      storeOrderData();
    }
  }

  void openOrder() async {
    cleanEverything();
    double price = await _binanceService.getCurrentPrice();
    double quantity = await _binanceService.getFreeBitcoinQuantity();
    String orderId = await _binanceService.openOcoOrder(
        symbol: 'BTCUSDT',
        quantity: quantity,
        targetPrice: price * 1.003,
        stopPrice: price * 0.99);

    if (orderId != null) {
      activeOrderId = orderId;
      isOrderActive.value = true;
      storeOrderData();
    } else {
      throw Exception("Order Failed");
    }
  }

  void sellEverything() async {
    await _binanceService.sellAsset('BTC');
  }

  void cancelOrder() async {
    await _binanceService.cancelOrder(activeOrderId);
  }

  void cleanEverything() {
    isOrderActive.value = false;
    activeOrderId = '';
    storeOrderData();
  }

  void storeOrderData() {
    box.write(ORDER_STORAGE_ID, activeOrderId);
    box.write(ORDER_STORAGE_STATUS, isOrderActive);
  }

  void loadOrderData() {
    activeOrderId = box.read(ORDER_STORAGE_ID) ?? '';
    isOrderActive.value = box.read(ORDER_STORAGE_STATUS) ?? false;
  }

  isThereAnOrderStillRunning() async {
    bool isOrderActive = await _binanceService.isOrderActive(activeOrderId);
    return isOrderActive;
  }
}
