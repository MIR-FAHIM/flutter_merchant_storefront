import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';

class RootRepository {
  final APIManager _apiManager = APIManager();

  /// Fetch Pending Orders Count for shop
  /// GET /api/orders/pending-count/{shopId}
  Future<Map<String, dynamic>> fetchPendingOrderCount(dynamic shopId) async {
    final url = ApiClient.pendingOrderCount(shopId);
    final response = await _apiManager.getWithHeaderStatus(url, {});
    return response;
  }
}
