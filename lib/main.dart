import 'package:flutter/material.dart';
import 'package:get/get.dart';

import './bindings.dart';
import 'routes.dart';

void main() {
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    initialBinding: HomeScreenBindings(),
    initialRoute: '/',
    getPages: Routes.pages,
  ));
}
