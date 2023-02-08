import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../services/binance_service.dart';
import '../utils/constants.dart';

class HomeController extends GetxController {
  var storage = GetStorage();
  late BinanceService _binanceService = BinanceService();

  var isOrderActive = false.obs;
  var activeOrderId = '';

  var initPrice = 0.0.obs;
  var targetValue = 0.0.obs;
  var stopValue = 0.0.obs;

  init() async {
    // Check if an order is already active
    isThereAnOrderStillRunning();
  }

  isThereAnOrderStillRunning() async {
    await loadOrderData();
    bool orderIsRunning = await _binanceService.isOrderActive(activeOrderId);
    if (!orderIsRunning) {
      isOrderActive.value = false;
      activeOrderId = '';
      storeOrderData();
    }
  }

  openOrder() async {
    double price = await _binanceService.getCurrentPrice();
    double quantity = await _binanceService.getFreeBitcoinQuantity();
    String orderId = await _binanceService.openOcoOrder(
      symbol: 'BTCUSDT',
      quantity: quantity,
      targetPrice: price * 1.003,
      stopPrice: price * 0.99,
    );

    activeOrderId = orderId;
    isOrderActive.value = true;
    storeOrderData();
  }

  storeOrderData() async {
    storage.write(ORDER_STORAGE_ID, activeOrderId);
    storage.write(ORDER_STORAGE_STATUS, isOrderActive);
  }

  loadOrderData() async {
    activeOrderId = storage.read(ORDER_STORAGE_ID) ?? '';
    isOrderActive.value = storage.read(ORDER_STORAGE_STATUS) ?? false;
  }

// void sellEverything() async {
//   await _binanceService.sellAsset('BTC');
// }
//
// void cancelOrder() async {
//   await _binanceService.cancelOrder(activeOrderId);
// }
//
// void cleanEverything() {
//   isOrderActive.value = false;
//   activeOrderId = '';
//   storeOrderData();
// }
}
