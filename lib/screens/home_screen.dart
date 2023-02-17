import 'package:crypto_quick_trader/controllers/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/cancel_button_widget.dart';
import '../widgets/chart_widget.dart';
import '../widgets/levelbar_widget.dart';
import '../widgets/order_button_widget.dart';
import '../widgets/sell_button_widget.dart';

class HomeScreen extends GetView {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Quick Trader'),
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
