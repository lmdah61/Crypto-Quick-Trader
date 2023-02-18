import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class LevelBar extends GetWidget {
  final _currentPrice = 0.0.obs;

  HomeController controller = Get.find();

  getDisplayText() {
    double currentPercentage =
        (_currentPrice / controller.initPrice.value - 1) * 100;
    return ' USDT ' + currentPercentage.toStringAsFixed(2) + '%';
  }

  progressColor() {
    double currentPercentage =
        (_currentPrice.value - controller.initPrice.value) /
            controller.initPrice.value *
            100;
    return currentPercentage >= 0 ? Colors.green : Colors.red;
  }

  _getCurrentPrice() async {
    _currentPrice.value = await controller.getCurrentPrice();
    Future.delayed( Duration(seconds: 1), _getCurrentPrice);
  }

  @override
  Widget build(BuildContext context) {
    _getCurrentPrice();

    return Obx(
      () => controller.isOrderActive.value
          ? Column(
              children: [
                Row(
                  children: [
                    Text(
                      controller.stopPrice.value.toStringAsFixed(2),
                      style: const TextStyle(color: Colors.red),
                    ),
                    const Spacer(),
                    Text(
                      controller.initPrice.value.toStringAsFixed(2),
                      style: TextStyle(color: progressColor()),
                    ),
                    const Spacer(),
                    Text(
                      controller.targetPrice.value.toStringAsFixed(2),
                      style: const TextStyle(color: Colors.green),
                    ),
                  ],
                ),
                FAProgressBar(
                  maxValue:
                      controller.targetPrice.value - controller.stopPrice.value,
                  currentValue:
                      (_currentPrice.value - controller.stopPrice.value),
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
