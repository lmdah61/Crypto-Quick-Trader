import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
class OpenOrderButton extends GetWidget {
  const OpenOrderButton({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.find();

    return Obx(
          () => Container(
        width: 120,
        height: 40,
        child: controller.isLoadingOrder.value
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
                  controller.isOrderActive.value ||
                  !controller.enableOrderButton.value
                  ? null
                  : Colors.orange,
            ),
          ),
          onPressed: controller.isOrderActive.value ||
              !controller.enableOrderButton.value
              ? null
              : () async {
            // Open main order
            await controller.openOrder();
            Get.snackbar("Notification", "Open Order",
                backgroundColor: Colors.orange);
          },
          child: const Text("Open Order"),
        ),
      ),
    );
  }
}
