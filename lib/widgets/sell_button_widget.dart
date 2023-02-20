import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class SellCoinsButton extends GetWidget {
  const SellCoinsButton({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.find();

    return Obx(
          () => Container(
        width: 120,
        height: 40,
        child: controller.isLoadingSell.value
            ? Center(
              child: const SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(),
        ),
            )
            : ElevatedButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              ),
            ),
            backgroundColor: MaterialStateProperty.resolveWith(
                  (states) => states.contains(MaterialState.pressed) ||
                  !controller.isOrderActive.value ||
                      controller.isLoadingCancel.value
                  ? null
                  : Colors.green,
            ),
          ),
          onPressed: !controller.isOrderActive.value ||
              controller.isLoadingCancel.value
              ? null
              : () async {
            // Cancel Order and sell the coins
            await controller.sellEverything();
            Get.snackbar("Notification", "Sell Order",
                backgroundColor: Colors.green);
          },
          child: Text("Sell Coins"),
        ),
      ),
    );
  }
}
