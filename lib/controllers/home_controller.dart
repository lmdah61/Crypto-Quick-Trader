import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../services/binance_service.dart';
import '../utils/constants.dart';

class HomeController extends GetxController {
  var storage = GetStorage();
  late BinanceService _binanceService = BinanceService();

  //var disableOrderButton = true.obs;
  var isOrderActive = false.obs;
  var activeOrderId = '';

  var initPrice = 0.0.obs;
  var targetPrice = 0.0.obs;
  var stopPrice = 0.0.obs;

  @override
  onInit() async {
    super.onInit();
    //_binanceService.isPreviousOrderActive();
    Timer(Duration(seconds: 3), () {
      print("This line is printed after 3 seconds");
      isPreviousOrderRunning();
    });
    //loadOrderData();
  }

  openOrder() async {
    var orderId = await _binanceService.openOcoOrder();

    //set up the levelbar values
    initPrice.value = await storage.read(ORDER_ENTRY_PRICE);
    targetPrice.value = initPrice.value * TARGET;
    stopPrice.value = initPrice.value * STOP_LOSS;

    isOrderActive.value = true;
  }

  loadOrderData() async {
    activeOrderId = storage.read(ORDER_STORAGE_ID) ?? '';
    isOrderActive.value = storage.read(ORDER_STORAGE_STATUS) ?? false;
  }

  sellEverything() async {
    await _binanceService.sellAllBTC();
    isOrderActive.value = false;
    storage.write(ORDER_STORAGE_ID,'');
  }

  cancelOrder() async {
    await _binanceService.cancelOrder(activeOrderId);
    isOrderActive.value = false;
    storage.write(ORDER_STORAGE_ID,'');
  }

  getCurrentPrice() async {
    return await _binanceService.getCurrentBTCPrice();
  }

  isPreviousOrderRunning() async {
    bool previousOrderIsActive = await _binanceService.isPreviousOrderActive();
    if (previousOrderIsActive) {
      isOrderActive.value = true;
      activeOrderId = storage.read(ORDER_STORAGE_ID) ?? '';

      initPrice.value = double.parse(storage.read(ORDER_ENTRY_PRICE).toString());
      targetPrice.value = initPrice * TARGET;
      stopPrice.value = initPrice * STOP_LOSS;
    }
  }
}
