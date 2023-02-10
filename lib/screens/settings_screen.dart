import 'package:crypto_quick_trader/controllers/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends GetView<SettingsController> {
  final apiKeyController = TextEditingController();
  final apiSecretController = TextEditingController();

  void loadFields() {
    apiKeyController.text = controller.apiKey.value;
    apiSecretController.text = controller.apiSecret.value;
  }

  @override
  Widget build(BuildContext context) {
    controller.loadSettings();
    loadFields();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
              ),
              onChanged: (value) => controller.apiKey.value = value,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: apiSecretController,
              decoration: const InputDecoration(
                labelText: 'API Secret',
              ),
              onChanged: (value) => controller.apiSecret.value = value,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.resolveWith(
                  (states) => states.contains(MaterialState.pressed) ||
                          controller.isThereAnOrderStillRunning()
                      ? null
                      : Colors.orange,
                ),
              ),
              onPressed: controller.isThereAnOrderStillRunning()
                  ? null
                  : () async {
                      // Cancel Order and sell the coins
                      controller.saveSettings();
                      Get.snackbar("Notification", "API data saved",);
                    },
              child: Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
