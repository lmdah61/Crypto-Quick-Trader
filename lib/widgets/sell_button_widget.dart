import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class SellCoinsButton extends GetWidget<HomeController> {
  const SellCoinsButton({super.key});

  @override
  Widget build(BuildContext context) {
    //final isOrderActive = false;

    return Obx(
      () => SizedBox(
        width: 120,
        child: ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            backgroundColor: MaterialStateProperty.resolveWith(
              (states) => states.contains(MaterialState.pressed) ||
                      !controller.isOrderActive.value
                  ? null
                  : Colors.green,
            ),
          ),
          onPressed: !controller.isOrderActive.value
              ? null
              : () async {
                  // Cancel Order and sell the coins
                  await controller.sellEverything();
                  Get.snackbar("Notification", "Sell Order",
                      backgroundColor: Colors.green);
                },
          child: Text("Sell Order"),
        ),
      ),
    );
  }
}
