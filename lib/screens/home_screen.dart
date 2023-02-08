import 'package:crypto_quick_trader/widgets/cancel_button_widget.dart';
import 'package:crypto_quick_trader/widgets/sell_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../widgets/chart_widget.dart';
import '../widgets/levelbar_widget.dart';
import '../widgets/order_button_widget.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Quick Trader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Get.toNamed('/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: BinanceChart()),
          LevelBar(),
        ],
      ),
      bottomNavigationBar: Row(
        children: const [
          Spacer(),
          SellCoinsButton(),
          Spacer(),
          OpenOrderButton(),
          Spacer(),
          CancelOrderButton(),
          Spacer(),
        ],
      ),
    );
  }
}
