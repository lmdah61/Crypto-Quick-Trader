import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class OpenOrderButton extends GetWidget<HomeController> {
  const OpenOrderButton({super.key});

  @override
  Widget build(BuildContext context) {
    //final isOrderActive = controller.isOrderActive.value;

    return  Obx(()=>
       SizedBox(
         width: 120,
         child: ElevatedButton(
           style: ButtonStyle(
             backgroundColor: MaterialStateProperty.resolveWith(
                   (states) => states.contains(MaterialState.pressed) || controller.isOrderActive.value
                   ? null
                   : Colors.orange,
             ),
           ),
          onPressed: controller.isOrderActive.value
              ? null
              : () {
            Get.snackbar("Notification", "Open Order");
            controller.isOrderActive.value=true;
          },
          child: Text("Open Order"),
          //disabledElevation: 0,
          //disabledColor: Colors.grey.withOpacity(0.5),
      ),
       ),
    );
  }
}
