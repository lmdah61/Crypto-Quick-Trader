import 'dart:convert';

import 'package:binance_api_dart/binance_api_dart.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

class BinanceService {
  var _binanceApi;

  final GetStorage _storage = GetStorage();

  BinanceService() {
    try {
      _binanceApi = BinanceApi(
          baseUrl: BASE_URL, apiKey: API_KEY, privateKey: API_SECRET);
    } catch (error) {
      throw Exception('Failed initializing the Binance API. Error: $error');
    }
  }

  openOrder() async {
    //await buyBTC();
    var price = await getCurrentBTCPrice();
    var quantity = await getFreeBTCQuantity();
    var targetPrice = price * 1.003;
    var stopPrice = price * 0.99;

    try {
      Map<String, String> postParameters = {};
      postParameters['recvWindow'] = '10000';
      postParameters['symbol'] = 'BTC$STABLE_COIN';
      postParameters['side'] = 'SELL';
      postParameters['quantity'] = quantity.toString();
      postParameters['price'] = targetPrice.toStringAsFixed(2);
      postParameters['stopPrice'] = stopPrice.toStringAsFixed(2);
      postParameters['stopLimitPrice'] = (stopPrice - 100.0).toStringAsFixed(2);
      postParameters['stopLimitTimeInForce'] = 'GTC';
      final result =
          await _binanceApi.postHttp('/api/v3/order/oco', postParameters);

      if (result.statusCode != 200) {
        throw Exception('Failed to open OCO order: ${result.body}');
      }

      final response = jsonDecode(result.body);

      await _storage.write(STORAGE_ORDER_ENTRY_PRICE, price.toString());
      await _storage.write(
          STORAGE_ORDER_ID, response['orderListId'].toString());

      return response['orderListId'].toString();
    } catch (error) {
      rethrow;
    }
  }

  getFreeBTCQuantity() async {
    try {
      Map<String, String> getParameters = {};
      getParameters['recvWindow'] = '10000';
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

  getFreeUSDTQuantity() async {
    try {
      Map<String, String> getParameters = {};
      getParameters['recvWindow'] = '10000';
      final result =
          await _binanceApi.getHttp('/api/v3/account', getParameters);
      if (result.statusCode == 200) {
        final response = jsonDecode(result.body);
        final balances = response['balances'];
        String freeUSDT = '0.0';
        for (var balance in balances) {
          if (balance['asset'] == STABLE_COIN) {
            freeUSDT = balance['free'];
            break;
          }
        }
        return double.parse(freeUSDT);
      } else {
        throw Exception(
            'Failed to retrieve free stable coin quantity. Response status: ${result.body}');
      }
    } catch (error) {
      rethrow;
    }
  }

  isPreviousOrderActive() async {
    String previousOrderId = _storage.read(STORAGE_ORDER_ID).toString();
    try {
      Map<String, String> getParameters = {};
      getParameters['recvWindow'] = '10000';
      final result =
          await _binanceApi.getHttp('/api/v3/openOrders', getParameters);

      if (result.statusCode == 200) {
        final response = jsonDecode(result.body);

        // loop through the response list and check if any order has the same orderListId
        for (var order in response) {
          var orderID = order['orderListId'].toString();
          print(orderID);
          print("dsklfhdskjhfdsjkfhsdjkfhsdjkhfjdkshjdf $previousOrderId");
          if (orderID == previousOrderId) {
            return true; // found an open order with the same orderListId
          }
        }
        return false; // no open order with the same orderListId
      } else {
        throw Exception(
            'Failed to get open orders ${result.body}, ${result.request}');
      }
    } catch (error) {
      rethrow;
    }
  }

  buyBTC() async {
    var quantity = await getFreeUSDTQuantity();

    try {
      Map<String, String> postParameters = {};
      postParameters['recvWindow'] = '10000';
      postParameters['symbol'] = 'BTC$STABLE_COIN';
      postParameters['quoteOrderQty'] = quantity.toStringAsFixed(8);
      postParameters['side'] = 'BUY';
      postParameters['type'] = 'MARKET';
      final result =
          await _binanceApi.postHttp('/api/v3/order', postParameters);
      if (result.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to buy BTC. ${result.body}');
      }
    } catch (error) {
      rethrow;
    }
  }

  sellAllBTC() async {
    await cancelAllOrders();
    var quantity = await getFreeBTCQuantity();

    try {
      Map<String, String> postParameters = {};
      postParameters['recvWindow'] = '10000';
      postParameters['symbol'] = 'BTC$STABLE_COIN';
      postParameters['quantity'] = quantity.toStringAsFixed(8);
      postParameters['side'] = 'SELL';
      postParameters['type'] = 'MARKET';
      final result =
          await _binanceApi.postHttp('/api/v3/order', postParameters);
      if (result.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to sell your BTC. ${result.body}');
      }
    } catch (error) {
      rethrow;
    }
  }

  cancelAllOrders() async {
    try {
      Map<String, String> deleteParameters = {};
      deleteParameters['recvWindow'] = '10000';
      deleteParameters['symbol'] = 'BTC$STABLE_COIN';
      final result =
          await _binanceApi.deleteHttp('/api/v3/openOrders', deleteParameters);
      if (result.statusCode == 200) {
        await _storage.write(STORAGE_ORDER_ID, '');
        return true;
      } else {
        throw Exception('Failed to cancel your Orders. ${result.body}');
      }
    } catch (error) {
      rethrow;
    }
  }

  getCurrentBTCPrice() async {
    var url =
        'https://api.binance.com/api/v3/ticker/price?symbol=BTC$STABLE_COIN';

    try {
      final result = await http.get(Uri.parse(url));
      if (result.statusCode == 200) {
        final data = jsonDecode(result.body);
        return double.parse(data['price']);
      } else {
        throw Exception('Failed to retrieve current price. ${result.body}');
      }
    } catch (error) {
      rethrow;
    }
  }
}
