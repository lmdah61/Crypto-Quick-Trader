import 'dart:convert';

import 'package:binance_api_dart/binance_api_dart.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class BinanceService {
  late BinanceApi _binanceApi;
  bool _isInitialized = false;
  bool _isConfigured = false;

  GetStorage _storage = GetStorage();

  BinanceService() {
    try {
      _binanceApi = BinanceApi(baseUrl: BASE_URL, apiKey: '', privateKey: '');
      _isInitialized = true;
    } catch (error) {
      _isInitialized = false;
      throw Exception('Failed initializing the Binance API. Error: $error');
    }
  }

  Future<String> openOcoOrder({
    required String symbol,
    required double quantity,
    required double targetPrice,
    required double stopPrice,
  }) async {
    if (!_isInitialized || !_isConfigured) {
      throw Exception('Binance API is not properly initialized or configured');
    }

    try {
      final result = await _binanceApi.postHttp('/api/v3/order/oco', {
        'symbol': symbol,
        'side': 'SELL',
        'quantity': quantity.toString(),
        'stopPrice': stopPrice.toString(),
        'limitPrice': targetPrice.toString(),
        'stopOrderPrice': (stopPrice).toString(),
        'limitOrderPrice': (targetPrice).toString(),
      });
      if (result.statusCode == 200) {
        final response = jsonDecode(result.body);
        return response['clientOrderId'] as String;
      } else {
        throw Exception(
            'Failed to open OCO order. Response status: ${result.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  isOrderActive(String clientOrderId) async {
    try {
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
        throw Exception(
            'Failed to get order status. Response status: ${result.statusCode}');
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<double> getCurrentPrice() async {
    String url = 'https://api.binance.com/api/v3/ticker/price?symbol=BTCUSDT';
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map data = jsonDecode(response.body);
      return double.parse(data['price']);
    } else {
      throw Exception('Failed to retrieve current price');
    }
  }

  updateAPIKeys() async {
    try {
      _binanceApi.apiKey = await _storage.read(API_KEY_STORAGE_ID) ?? '';
      _binanceApi.privateKey = await _storage.read(API_SECRET_STORAGE_ID) ?? '';
      if (_binanceApi.apiKey != '' && _binanceApi.privateKey != '') {
        _isConfigured = true;
      } else {
        _isConfigured = false;
      }
    } catch (error) {
      throw Exception(
          'Failed to configure your Binance API Keys. Error: $error');
    }
  }

  Future<bool> sellAsset(String asset) async {
    if (!_isInitialized || !_isConfigured) {
      throw Exception('Binance API is not properly initialized or configured');
    }

    double quantity = await getFreeBitcoinQuantity();

    if (quantity == 0) {
      throw Exception(
          'Error selling ${asset} quantity must be greater than zero');
    }

    // set the request parameters
    Map<String, String> postParameters = {};
    postParameters['recvWindow'] = '10000';
    postParameters['symbol'] = '${asset}$TARGET_STABLE_COIN';
    postParameters['quantity'] = quantity.toStringAsFixed(8);
    postParameters['side'] = 'SELL';
    postParameters['type'] = 'MARKET';

    try {
      final sellResponse =
          await _binanceApi.postHttp('/api/v3/order', postParameters);
      if (sellResponse.statusCode != 200) {
        // parse the json error response
        var error = jsonDecode(sellResponse.body)['code'];
        var errorMessage = jsonDecode(sellResponse.body)['msg'];
        throw Exception(
            'Failed to sell ${quantity} of ${asset}. Error code: $error, Error message: $errorMessage');
      }
      return true;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> cancelOrder(String orderId) async {
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

  Future<double> getFreeBitcoinQuantity() async {
    if (!_isInitialized || !_isConfigured) {
      throw Exception('Binance API is not properly initialized or configured');
    }

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
}
