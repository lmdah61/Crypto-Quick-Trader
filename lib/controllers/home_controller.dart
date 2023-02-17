import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../services/binance_service.dart';
import '../utils/constants.dart';

class HomeController extends GetxController {
  var storage = GetStorage();
  final BinanceService _binanceService = BinanceService();

  var enableOrderButton = false.obs;
  var isOrderActive = false.obs;
  var activeOrderId = '';

  var initPrice = 0.0.obs;
  var targetPrice = 0.0.obs;
  var stopPrice = 0.0.obs;

  @override
  onInit() {
    super.onInit();
    //await isPreviousOrderRunning();
    //_binanceService.isPreviousOrderActive();
    Timer(Duration(seconds: 3), () {
      //isPreviousOrderRunning();
      enableOrderButton.value = true;
    });
    //loadOrderData();
  }

  openOrder() {
    // _binanceService.openOcoOrder();
    //
    // //set up the levelbar values
    // initPrice.value = double.parse(storage.read(STORAGE_ORDER_ENTRY_PRICE));
    // targetPrice.value = initPrice.value * TARGET;
    // stopPrice.value = initPrice.value * STOP_LOSS;
    //
    // isOrderActive.value = true;
  }

  // loadOrderData() {
  //   activeOrderId = storage.read(STORAGE_ORDER_ID) ?? '';
  //   isOrderActive.value = storage.read(STORAGE_ORDER_STATUS) ?? false;
  // }

  sellEverything() {
    _binanceService.sellAllBTC();
    isOrderActive.value = false;
    storage.write(STORAGE_ORDER_ID, '');
  }

  cancelOrder() {
    _binanceService.cancelOrder(activeOrderId);
    isOrderActive.value = false;
    storage.write(STORAGE_ORDER_ID, '');
  }

  getCurrentPrice() async {
    double price = await _binanceService.getCurrentBTCPrice();
    return price;
  }

  isPreviousOrderRunning() {
    bool previousOrderIsActive = _binanceService.isPreviousOrderActive();
    if (previousOrderIsActive) {
      isOrderActive.value = true;
      activeOrderId = storage.read(STORAGE_ORDER_ID).toString();

      initPrice.value =
          double.parse(storage.read(STORAGE_ORDER_ENTRY_PRICE).toString());
      targetPrice.value = initPrice * TARGET;
      stopPrice.value = initPrice * STOP_LOSS;
    }
  }
}
