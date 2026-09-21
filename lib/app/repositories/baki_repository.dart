import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';

class BakiRepository {
  final APIManager _apiManager = APIManager();

  /// A. Fetch Store Baki Summary & Customer Search
  Future<Map<String, dynamic>> fetchBakiSummary({
    required String storeId,
    String? search,
  }) async {
    final url = ApiClient.bakiSummary(storeId, search: search);
    final response = await _apiManager.getWithHeaderStatus(url, {});
    return response;
  }

  /// B. Fetch Customer Ledger Timeline
  Future<Map<String, dynamic>> fetchCustomerLedger({
    required String storeId,
    required int customerId,
    int page = 1,
  }) async {
    final url = ApiClient.customerLedger(storeId, customerId, page: page);
    final response = await _apiManager.getWithHeaderStatus(url, {});
    return response;
  }

  /// C. Collect Baki Payment
  Future<Map<String, dynamic>> collectPayment({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    final url = ApiClient.bakiCollect(storeId);
    final response = await _apiManager.postJsonWithHeaderStatus(url, body, {});
    return response;
  }

  /// D. Quick Add Baki
  Future<Map<String, dynamic>> quickAddBaki({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    final url = ApiClient.bakiQuickAdd(storeId);
    final response = await _apiManager.postJsonWithHeaderStatus(url, body, {});
    return response;
  }
}
