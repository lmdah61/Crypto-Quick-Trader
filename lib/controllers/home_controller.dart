import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../services/binance_service.dart';
import '../utils/constants.dart';

class HomeController extends GetxController {
  var storage = GetStorage();
  final BinanceService _binanceService = BinanceService();

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
    bool orderIsRunning = await _binanceService.isOcoOrderActive(activeOrderId);
    if (!orderIsRunning) {
      clean();
    }
  }

  openOrder() async {
    await _binanceService.updateAPIKeys();
    double price = await _binanceService.getCurrentBTCPrice();
    double quantity = await _binanceService.getFreeBTCQuantity();
    var orderId = await _binanceService.openOcoOrder(
      symbol: 'BTCUSDT',
      quantity: quantity,
      targetPrice: price * 1.003,
      stopPrice: price * 0.99,
    );

    initPrice.value = price;
    targetValue.value = price * 1.003;
    stopValue.value = price * 0.99;

    activeOrderId = orderId;
    isOrderActive.value = true;
    storeOrderData();
  }

  storeOrderData() async {
    storage.write(ORDER_STORAGE_ID, activeOrderId);
    storage.write(ORDER_STORAGE_STATUS, isOrderActive.value);
  }

  loadOrderData() async {
    activeOrderId = storage.read(ORDER_STORAGE_ID) ?? '';
    isOrderActive.value = storage.read(ORDER_STORAGE_STATUS) ?? false;
  }

  sellEverything() async {
    await _binanceService.sellAllBTC();
    clean();
  }

  cancelOrder() async {
    await _binanceService.cancelOrder(activeOrderId);
    clean();
  }

  void clean() {
    isOrderActive.value = false;
    activeOrderId = '';
    storeOrderData();
  }

  getCurrentPrice() async {
    return await _binanceService.getCurrentBTCPrice();
  }


}
