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
            ? const Center(
                child: SizedBox(
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
                        await controller.sellEverything();
                        Get.snackbar("Notification", "All BTC Sold",
                            backgroundColor: Colors.green);
                      },
                child: const Text("Sell Coins"),
              ),
      ),
    );
  }
}
