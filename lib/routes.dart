import 'package:crypto_quick_trader/screens/home_screen.dart';
import 'package:crypto_quick_trader/screens/settings_screen.dart';
import 'package:get/get.dart';

import 'bindings.dart';

class Routes {
  static final pages = [
    GetPage(
      name: '/',
      page: () => HomeScreen(),
      binding: HomeScreenBindings(),
    ),
    GetPage(
      name: '/settings',
      page: () => SettingsScreen(),
      binding: SettingsScreenBindings(),
    ),
  ];
}
