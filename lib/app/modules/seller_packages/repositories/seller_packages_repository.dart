import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:get/get.dart';

class SellerPackagesRepository {
  final APIManager _manager = APIManager();

  Future<Map<String, dynamic>> fetchSellerStores({
    required String userId,
    int page = 1,
    int perPage = 200,
  }) async {
    final String url =
        '${ApiClient.sellerShopList}?user_id=$userId&page=$page&per_page=$perPage';

    var response = await _manager.getWithHeaderStatus(url, {});
    print("data return fetchSellerStores $response");
    return response;
  }

  Future<Map<String, dynamic>> fetchSellerProfile({
    required String userId,
  }) async {
    var response = await _manager.getWithHeaderStatus(
        ApiClient.sellerProfile + userId, {});
    print("data return fetchSellerProfile $response");
    return response;
  }

  Future<Map<String, dynamic>> fetchSubscriptionPackages() async {
    const String url = '${ApiClient.subscriptionPackages}?status=active&all=1';

    var response = await _manager.getWithHeaderStatus(url, {});
    print("data return fetchSubscriptionPackages $response");
    return response;
  }

  Future<Map<String, dynamic>> fetchStoreSubscription({
    required String storeId,
  }) async {
    final String url = '${ApiClient.stores}$storeId/subscription';

    var response = await _manager.getWithHeaderStatus(url, {});
    print("data return fetchStoreSubscription $response");
    return response;
  }

  Future subscribeToPackage({
    required String storeId,
    required int packageId,
    required String billingCycle,
  }) async {
    final String url = '${ApiClient.stores}$storeId/subscription/subscribe';

    var response = await _manager.postAPICallWithHeader(
      url,
      {
        'subscription_package_id': packageId.toString(),
        'billing_cycle': billingCycle,
      },
      {
        'Authorization':
            "Bearer ${Get.find<AuthService>().currentUser.value.data!.token!}",
      },
    );
    print("data return subscribeToPackage $response");
    return response;
  }
}
