import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BinanceChart extends StatelessWidget {
  const BinanceChart({super.key});

  @override
  Widget build(BuildContext context) {

    String embeddedCode = '''

<!-- TradingView Widget BEGIN -->

<div class="tradingview-widget-container">
  <div id="tradingview_d2f23"></div>
  <div class="tradingview-widget-copyright"><a href="https://www.tradingview.com/symbols/BTCUSDT/?exchange=BINANCE" rel="noopener" target="_blank"><span class="blue-text">BTCUSDT chart</span></a> by TradingView</div>
  <script type="text/javascript" src="https://s3.tradingview.com/tv.js"></script>
  <script type="text/javascript">
  new TradingView.widget(
  {
  "autosize": true,
  "symbol": "BINANCE:BTCUSDT",
  "interval": "5",
  "timezone": "Etc/UTC",
  "theme": "dark",
  "style": "1",
  "locale": "en",
  "toolbar_bg": "#f1f3f6",
  "enable_publishing": false,
  "hide_top_toolbar": true,
  "hide_legend": true,
  "save_image": false,
  "studies": [
    "StochasticRSI@tv-basicstudies"
  ],
  "container_id": "tradingview_d2f23"
}
  );
  </script>
</div>
<!-- TradingView Widget END -->

''';

    var controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setUserAgent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36")
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
        ),
      );

    controller.loadRequest(Uri.dataFromString(embeddedCode,
        mimeType: 'text/html', encoding: Encoding.getByName('utf-8')));

    return WebViewWidget(controller: controller);
  }
}
