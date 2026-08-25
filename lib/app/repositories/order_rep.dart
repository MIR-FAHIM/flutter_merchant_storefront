
import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';

class OrderRepository {
  Future<dynamic> shopOrderList({
    required String shopId,
    required int page,
    int perPage = 20,
  }) async {
    final APIManager manager = APIManager();

    final String url =
        '${ApiClient.shopOrderList}$shopId?page=$page&per_page=$perPage';

    final response = await manager.getWithHeader(url, {});

    print('shopOrderList response: $response');

    return response;
  }

  Future<dynamic> orderDetails({
    required String orderId,
  }) async {
    final APIManager manager = APIManager();

    final String url = ApiClient.orderDetails + orderId;

    final response = await manager.getWithHeader(url, {});

    print('orderDetails response: $response');

    return response;
  }
}