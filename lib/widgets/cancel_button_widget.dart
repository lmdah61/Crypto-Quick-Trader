import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class CancelOrderButton extends GetWidget<HomeController> {
  const CancelOrderButton({super.key});

  @override
  Widget build(BuildContext context) {
    //final isOrderActive = controller.isOrderActive.value;

    return Obx(
      () => SizedBox(
        width: 120,
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith(
                  (states) => states.contains(MaterialState.pressed) || !controller.isOrderActive.value
                  ? null
                  : Colors.red,
            ),
          ),
          onPressed: !controller.isOrderActive.value
              ? null
              : () {
                  Get.snackbar("Notification", "Cancel Order");
                  controller.isOrderActive.value=false;
                  // Open sell order
                },
          child: Text("Cancel Order"),

          //disabledElevation: 0,
          //disabledColor: Colors.grey.withOpacity(0.5),
        ),
      ),
    );
  }
}
