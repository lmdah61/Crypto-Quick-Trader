import 'dart:async';

import 'package:crypto_quick_trader/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'controllers/home_controller.dart';

main() {
  runZonedGuarded(
    () {
      Get.put(HomeController());
      runApp(
        GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          home: HomeScreen(),
        ),
      );
    },
    (Object error, StackTrace stackTrace) {
      // Show an alert dialog when an error occurs
      Get.dialog(
        AlertDialog(
          title: const Text('An error occurred'),
          content: Text('The app encountered an error.\n\n$error'),
          actions: [
            TextButton(
              child: const Text('Ok'),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      );
    },
  );
}
