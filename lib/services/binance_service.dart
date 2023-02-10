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
      _binanceApi = BinanceApi(baseUrl: BASE_URL, apiKey: '', privateKey: '');
    } catch (error) {
      throw Exception('Failed initializing the Binance API. Error: $error');
    }
  }

  openOcoOrder({
    required String symbol,
    required double quantity,
    required double targetPrice,
    required double stopPrice,
  }) async {
    await updateAPIKeys();

    try {
      final result = await _binanceApi.postHttp('/api/v3/order/oco', {
        'symbol': symbol,
        'side': 'SELL',
        'quantity': quantity.toStringAsFixed(2),
        'price': targetPrice.toStringAsFixed(2),
        'stopPrice': stopPrice.toStringAsFixed(2),
        'stopLimitPrice': (stopPrice - 1.0).toStringAsFixed(2),
        'stopLimitTimeInForce': 'GTC',
      });

      if (result.statusCode == 200) {
        final response = jsonDecode(result.body);
        return response['clientOrderId'].toString();
      } else {
        throw Exception('Failed to open OCO order: ${result.body}');
      }
    } catch (error) {
      rethrow;
    }
  }

  getFreeBTCQuantity() async {
    try {
      final result = await _binanceApi.getHttp('/api/v3/account', {});
      if (result.statusCode == 200) {
        final response = jsonDecode(result.body);
        final free = response['balances']
            .firstWhere((balance) => balance['asset'] == 'BTC')['free'];
        return double.parse(free);
      } else {
        throw Exception(
            'Failed to retrieve free bitcoin quantity. Response status: ${result.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  getCurrentBTCPrice() async {
    String url = 'https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      return double.parse(data['price']);
    } else {
      throw Exception('Failed to retrieve current price');
    }
  }

  isOcoOrderActive(String clientOrderId) async {
    Map<String, String> getParameters = {};
    getParameters['recvWindow'] = '10000';
    getParameters['symbol'] = '';
    getParameters['orderId'] = '';
    getParameters['origClientOrderId'] = clientOrderId;

    final result = await _binanceApi.getHttp('/api/v3/order', getParameters);
    if (result.statusCode == 200) {
      final response = jsonDecode(result.body);
      final status = response['status'] as String;
      if (status == 'FILLED' || status == 'CANCELED' || status == 'EXPIRED') {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  updateAPIKeys() async {
    try {
      _binanceApi.apiKey = _storage.read(API_KEY_STORAGE_ID) ?? '';
      _binanceApi.privateKey = _storage.read(API_SECRET_STORAGE_ID) ?? '';
    } catch (error) {
      throw Exception(
          'Failed to configure your Binance API Keys. Error: $error');
    }
  }

  sellAllBTC() async {
    double quantity = await getFreeBTCQuantity();

    // set the request parameters
    Map<String, String> postParameters = {};
    postParameters['recvWindow'] = '10000';
    postParameters['symbol'] = 'BTC$TARGET_STABLE_COIN';
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

  buyBTC() async {
    // set the request parameters
    Map<String, String> postParameters = {};
    postParameters['recvWindow'] = '10000';
    postParameters['symbol'] = 'BTC$TARGET_STABLE_COIN';
    postParameters['quantity'] = 'all';
    postParameters['side'] = 'BUY';
    postParameters['type'] = 'MARKET';

    try {
      final buyResponse =
          await _binanceApi.postHttp('/api/v3/order', postParameters);
      if (buyResponse.statusCode != 200) {
        throw Exception('Failed to buy BTC. ${buyResponse.body}');
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
}
