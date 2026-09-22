import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';

class ShopCashFlowRepository {
  final APIManager _apiManager = APIManager();

  /// 1. Fetch Summary Report (KPIs, Ledger Rows, Totals)
  Future<Map<String, dynamic>> fetchSummaryReport({
    required String storeId,
    String? period,
    String? from,
    String? to,
  }) async {
    final url = ApiClient.shopFinancialSummary(
      storeId,
      period: period,
      from: from,
      to: to,
    );
    final response = await _apiManager.getWithHeaderStatus(url, {});
    return response;
  }

  /// 2. Set Morning Opening Cash Drawer
  Future<Map<String, dynamic>> setOpeningCash({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    final url = ApiClient.cashLogOpening(storeId);
    final response = await _apiManager.postJsonWithHeaderStatus(url, body, {});
    return response;
  }

  /// 3. Record Quick Cash Sale (No Cart)
  Future<Map<String, dynamic>> recordQuickCash({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    final url = ApiClient.cashLogQuickCash(storeId);
    final response = await _apiManager.postJsonWithHeaderStatus(url, body, {});
    return response;
  }

  /// 4. Add Daily Shop Expense
  Future<Map<String, dynamic>> addExpense({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    final url = ApiClient.cashLogExpense(storeId);
    final response = await _apiManager.postJsonWithHeaderStatus(url, body, {});
    return response;
  }

  /// 5. Adjust Cash Drawer (Tally Fix)
  Future<Map<String, dynamic>> adjustDrawer({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    final url = ApiClient.cashLogAdjustDrawer(storeId);
    final response = await _apiManager.postJsonWithHeaderStatus(url, body, {});
    return response;
  }
}
