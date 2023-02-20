import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class CancelOrderButton extends GetWidget {
  const CancelOrderButton({super.key});

  @override
  Widget build(BuildContext context) {
    HomeController controller = Get.find();

    return Obx(
      () => Container(
        width: 120,
        height: 40,
        child: controller.isLoadingCancel.value
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
                            controller.isLoadingSell.value
                        ? null
                        : Colors.red,
                  ),
                ),
                onPressed: !controller.isOrderActive.value ||
                    controller.isLoadingSell.value
                    ? null
                    : () async {
                        await controller.cancelOrder();
                        Get.snackbar("Notification", "Cancel Order",
                            backgroundColor: Colors.red);
                      },
                child: Text("Cancel Order"),
              ),
      ),
    );
  }
}
