import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class LevelBar extends GetWidget<HomeController> {

  final _currentPrice = 0.0.obs;

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
    await controller.isThereAnOrderStillRunning();
    _currentPrice.value = await controller.getCurrentPrice();
    Future.delayed(const Duration(seconds: 3), _getCurrentPrice);
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
          : const SizedBox(),
    );
  }
}
