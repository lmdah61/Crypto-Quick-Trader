import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class SellCoinsButton extends GetWidget<HomeController> {
  const SellCoinsButton({super.key});

  @override
  Widget build(BuildContext context) {
    //final isOrderActive = false;

    return  Obx(()=>
        SizedBox(
          width: 120,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith(
                    (states) => states.contains(MaterialState.pressed) || !controller.isOrderActive.value
                    ? null
                    : Colors.green,
              ),
            ),
            onPressed: !controller.isOrderActive.value
                ? null
                : () {
              Get.snackbar("Notification", "Sell Order");
              controller.isOrderActive.value=false;
              // Open sell order
            },
            child: Text("Sell Order"),
            //disabledElevation: 0,
            //disabledColor: Colors.grey.withOpacity(0.5),
          ),
        ),
    );
  }
}
