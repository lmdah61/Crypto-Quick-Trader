import 'dart:convert';

import 'package:binance_api_dart/binance_api_dart.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class BinanceService {
  late BinanceApi _binanceApi;

  final GetStorage _storage = GetStorage();

  BinanceService() {
    try {
      _binanceApi = BinanceApi(
          baseUrl: 'testnet.binance.vision',
          apiKey: API_KEY,
          privateKey: API_SECRET);
    } catch (error) {
      throw Exception('Failed initializing the Binance API. Error: $error');
    }
  }

  openOcoOrder() async {
    double price = await getCurrentBTCPrice();
    double quantity = await getFreeBTCQuantity();
    double targetPrice = price * 1.003;
    double stopPrice = price * 0.99;

    try {
      final result = await _binanceApi.postHttp('/api/v3/order/oco', {
        'recvWindow': '10000',
        'symbol': 'BTCUSDT',
        'side': 'SELL',
        'quantity': quantity.toString(),
        'price': targetPrice.toStringAsFixed(2),
        'stopPrice': stopPrice.toStringAsFixed(2),
        'stopLimitPrice': (stopPrice - 100.0).toStringAsFixed(2),
        'stopLimitTimeInForce': 'GTC',
      });

      if (result.statusCode == 200) {
        final response = jsonDecode(result.body);

        await _storage.write(STORAGE_ORDER_ENTRY_PRICE, price.toString());
        await _storage.write(
            STORAGE_ORDER_ID, response['orderListId'].toString());

        return response['orderListId'].toString();
      } else {
        throw Exception('Failed to open OCO order: ${result.body}');
      }
    } catch (error) {
      rethrow;
    }
  }

  getFreeBTCQuantity() async {
    try {
      Map<String, String> getParameters = {};
      final result =
          await _binanceApi.getHttp('/api/v3/account', getParameters);
      if (result.statusCode == 200) {
        final response = jsonDecode(result.body);
        final free = response['balances']
            .firstWhere((balance) => balance['asset'] == 'BTC')['free'];
        return double.parse(free);
      } else {
        throw Exception(
            'Failed to retrieve free bitcoin quantity. Response status: ${result.body}');
      }
    } catch (error) {
      rethrow;
    }
  }

  isPreviousOrderActive() async {
    String previousOrderId = _storage.read(STORAGE_ORDER_ID).toString();

    Map<String, String> getParameters = {};
    getParameters['recvWindow'] = '10000';
    final result =
        await _binanceApi.getHttp('/api/v3/openOrders', getParameters);

    if (result.statusCode == 200) {
      final response = jsonDecode(result.body);

      // loop through the response list and check if any order has the same orderListId
      for (var order in response) {
        String orderID = order['orderListId'].toString();
        //print("ID IS ${order['orderListId']} and MY PVALUE IS $previousOrderId");
        if (orderID == previousOrderId) {
          return true; // found an open order with the same orderListId
        }
      }
      return false; // no open order with the same orderListId
    } else {
      throw Exception(
          'Failed to get open orders ${result.body}, ${result.request}');
    }
  }

  sellAllBTC() async {
    double quantity = await getFreeBTCQuantity();

    // set the request parameters
    Map<String, String> postParameters = {};
    postParameters['recvWindow'] = '10000';
    postParameters['symbol'] = 'BTC$STABLE_COIN';
    postParameters['quantity'] = quantity.toStringAsFixed(8);
    postParameters['side'] = 'SELL';
    postParameters['type'] = 'MARKET';

    try {
      final sellResponse =
          await _binanceApi.postHttp('/api/v3/order', postParameters);
      if (sellResponse.statusCode != 200) {
        throw Exception('Failed to sell your BTC. ${sellResponse.body}');
      }
      return true;
    } catch (error) {
      rethrow;
    }
  }

  cancelOrder(String orderId) async {
    // Make the API call to cancel the order
    try {
      final response = await http.delete(
        'https://api.binance.com/api/v3/order/$orderId' as Uri,
      );

      if (response.statusCode == 200) {
        // Order cancellation was successful
        print('Order cancellation successful');
      } else {
        // Handle the error case
        throw Exception('Failed to cancel order');
      }
    } catch (e) {
      // Handle exceptions thrown by the API call
      print(e);
    }
  }

  getCurrentBTCPrice() async {
    try {
      String url = 'https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT';
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map data = jsonDecode(response.body);
        return double.parse(data['price']);
      } else {
        throw Exception('Failed to retrieve current price');
      }
    } catch (error) {
      rethrow;
    }
  }
}
