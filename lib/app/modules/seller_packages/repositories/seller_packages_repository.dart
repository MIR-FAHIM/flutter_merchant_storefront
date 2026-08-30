import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';

class SellerPackagesRepository {
  final APIManager _manager = APIManager();

  Future<Map<String, dynamic>> fetchSellerStores({
    required String userId,
    int page = 1,
    int perPage = 200,
  }) async {
    final String url =
        '${ApiClient.sellerShopList}?user_id=$userId&page=$page&per_page=$perPage';

    return _manager.getWithHeaderStatus(url, {});
  }

  Future<Map<String, dynamic>> fetchSubscriptionPackages() async {
    const String url = '${ApiClient.subscriptionPackages}?status=active&all=1';

    return _manager.getWithHeaderStatus(url, {});
  }

  Future<Map<String, dynamic>> fetchStoreSubscription({
    required String storeId,
  }) async {
    final String url = '${ApiClient.stores}$storeId/subscription';

    return _manager.getWithHeaderStatus(url, {});
  }

  Future<Map<String, dynamic>> subscribeToPackage({
    required String storeId,
    required int packageId,
    required String billingCycle,
  }) async {
    final String url = '${ApiClient.stores}$storeId/subscription/subscribe';

    return _manager.postJsonWithHeaderStatus(
      url,
      {
        'subscription_package_id': packageId,
        'billing_cycle': billingCycle,
      },
      {},
    );
  }
}
