import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../services/binance_service.dart';
import '../utils/constants.dart';

class HomeController extends GetxController {
  final _storage = GetStorage();
  final _binanceService = BinanceService();

  var isLoadingOrder = false.obs;
  var isLoadingSell = false.obs;
  var isLoadingCancel = false.obs;

  var enableOrderButton = false.obs;
  var enableSellButton = false.obs;
  var enableCancelButton = false.obs;

  var isOrderActive = false.obs;
  var activeOrderId = '';

  var initPrice = 0.0.obs;
  var targetPrice = 0.0.obs;
  var stopPrice = 0.0.obs;

  @override
  onInit() {
    super.onInit();
    Timer(const Duration(seconds: 3), () async {
      await isPreviousOrderRunning();
      enableOrderButton.value = true;
    });
  }

  openOrder() async {
    isLoadingOrder.value = true;

    await _binanceService.openOrder();

    initPrice.value = double.parse(_storage.read(STORAGE_ORDER_ENTRY_PRICE));
    targetPrice.value = initPrice.value * TARGET;
    stopPrice.value = initPrice.value * STOP_LOSS;

    isOrderActive.value = true;
    isLoadingOrder.value = false;
  }

  sellEverything() async {
    isLoadingSell.value = true;
    await _binanceService.sellAllBTC();
    isOrderActive.value = false;
    _storage.write(STORAGE_ORDER_ID, '');
    isLoadingSell.value = false;
  }

  cancelOrder() async {
    isLoadingCancel.value = true;
    await _binanceService.cancelAllOrders();
    isOrderActive.value = false;
    _storage.write(STORAGE_ORDER_ID, '');
    isLoadingCancel.value = false;
  }

  isPreviousOrderRunning() async {
    var previousOrderIsActive = await _binanceService.isPreviousOrderActive();
    if (previousOrderIsActive) {
      isOrderActive.value = true;
      activeOrderId = _storage.read(STORAGE_ORDER_ID).toString();

      initPrice.value =
          double.parse(_storage.read(STORAGE_ORDER_ENTRY_PRICE).toString());
      targetPrice.value = initPrice * TARGET;
      stopPrice.value = initPrice * STOP_LOSS;
    }
  }

  getCurrentPrice() async {
    var price = await _binanceService.getCurrentBTCPrice();
    return price;
  }
}
