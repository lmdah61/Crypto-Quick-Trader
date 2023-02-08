import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../controllers/home_controller.dart';

class LevelBar extends GetWidget<HomeController> {
  final _currentPrice = 0.0.obs;

  String getDisplayText() {
    double currentPercentage =
        (_currentPrice / controller.initPrice.value - 1) * 100;
    return ' USDT ' + currentPercentage.toStringAsFixed(2) + '%';
  }

  Color progressColor() {
    double currentPercentage =
        (_currentPrice.value - controller.initPrice.value) /
            controller.initPrice.value *
            100;
    return currentPercentage >= 0 ? Colors.green : Colors.red;
  }

  void _getCurrentPrice() async {
    String url = 'https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      _currentPrice.value = double.parse(data['price']);
    } else {
      // handle the error
    }

    Future.delayed(const Duration(seconds: 2), _getCurrentPrice);
  }

  void _setStopAndTarget() async {
    String url = 'https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);

      controller.initPrice.value = double.parse(data['price']);
      controller.targetValue.value = controller.initPrice.value * 1.003;
      controller.stopValue.value = controller.initPrice.value * 0.99;
    } else {
      // handle the error
    }
  }

  @override
  Widget build(BuildContext context) {

    _setStopAndTarget();
    _getCurrentPrice();

    return Obx(
      () => controller.isOrderActive.value
          ? Column(
              children: [
                Row(
                  children: [
                    Text(
                      controller.stopValue.value.toStringAsFixed(2),
                      style: const TextStyle(color: Colors.red),
                    ),
                    const Spacer(),
                    Text(
                      _currentPrice.toStringAsFixed(2),
                      style: TextStyle(color: progressColor()),
                    ),
                    const Spacer(),
                    Text(
                      controller.targetValue.value.toStringAsFixed(2),
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                FAProgressBar(
                  maxValue:
                      controller.targetValue.value - controller.stopValue.value,
                  currentValue:
                      (_currentPrice.value - controller.stopValue.value),
                  animatedDuration: const Duration(milliseconds: 500),
                  displayText: getDisplayText(),
                  progressColor: progressColor(),
                  //displayCurrentValue: false,
                ),
              ],
            )
          : SizedBox(),
    );
  }
}
