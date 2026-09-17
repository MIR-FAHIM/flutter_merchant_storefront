
import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:get/get.dart';

class NotificationRepository {
  Map<String, String> get _headers {
    final token = Get.find<AuthService>().currentUser.value.data?.token;
    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
    };
  }

  Future<dynamic> getNotifications({required int page, int perPage = 20}) {
    final uri = Uri.parse(ApiClient.notifications).replace(
      queryParameters: {'per_page': '$perPage', 'page': '$page'},
    );
    return APIManager().getWithHeader(uri.toString(), _headers);
  }

  Future<dynamic> getUnreadCount() =>
      APIManager().getWithHeader(ApiClient.notificationUnreadCount, _headers);

  Future<dynamic> getOrderHistory(int orderId) => APIManager().getWithHeader(
        '${ApiClient.notificationOrders}$orderId',
        _headers,
      );

  Future<dynamic> markRead(int notificationId) =>
      APIManager().postAPICallWithHeader(
        '${ApiClient.notificationRead}$notificationId/read',
        const {},
        _headers,
      );

  Future<dynamic> markAllRead() => APIManager().postAPICallWithHeader(
        ApiClient.notificationReadAll,
        const {},
        _headers,
      );
}
