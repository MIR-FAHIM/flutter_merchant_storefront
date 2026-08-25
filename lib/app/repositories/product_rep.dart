import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';

class ProductRepository {
  Future<dynamic> shopProductList({
    required String shopId,
    required int page,
    int perPage = 24,
  }) async {
    final APIManager manager = APIManager();

    final String url =
        '${ApiClient.shopProductList}$shopId?page=$page&per_page=$perPage';

    final response = await manager.getWithHeader(url, {});

    print('shopProductList response: $response');

    return response;
  }
}