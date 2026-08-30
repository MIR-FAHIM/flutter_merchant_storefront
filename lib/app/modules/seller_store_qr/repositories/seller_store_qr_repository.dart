import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';

class SellerStoreQrRepository {
  final APIManager _manager = APIManager();

  Future<dynamic> getSellerStores({
    required String userId,
    int page = 1,
    int perPage = 200,
  }) async {
    final String url =
        '${ApiClient.sellerShopList}?user_id=$userId&page=$page&per_page=$perPage';

    final response = await _manager.getWithHeader(url, {});

    print('seller stores response: $response');

    return response;
  }
}
