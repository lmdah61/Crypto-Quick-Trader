import 'dart:async';

import 'package:crypto_quick_trader/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'bindings.dart';

void main() {
  runZonedGuarded(
    () {
      runApp(
        GetMaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          initialBinding: HomeScreenBindings(),
          initialRoute: '/',
          getPages: Routes.pages,
        ),
      );
    },
    (Object error, StackTrace stackTrace) {
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
