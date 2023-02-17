import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class OpenOrderButton extends GetWidget<HomeController> {
  const OpenOrderButton({super.key});

  @override
  Widget build(BuildContext context) {
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
                  controller.isOrderActive.value
                  ||
                  !controller.enableOrderButton.value
                  ? null
                  : Colors.orange,
            ),
          ),
          onPressed: controller.isOrderActive.value
              ||
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
