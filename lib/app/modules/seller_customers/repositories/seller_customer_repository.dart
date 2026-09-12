import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';
import 'package:ecom_delivery_flutter/app/models/seller_customer_list_model.dart';
import 'package:ecom_delivery_flutter/app/models/seller_customer_model.dart';

class SellerCustomerRepository {
  final APIManager _manager = APIManager();

  Future<SellerCustomerAddResult> addCustomer({
    required Map<String, dynamic> payload,
  }) async {
    final response = await _manager.postJsonWithHeaderStatus(
      '${ApiClient.sellerCustomerPreferences}/add-customer-preference',
      payload,
      {},
    );

    final statusCode =
    response['status_code'] is int ? response['status_code'] as int : 500;
    final body = response['body'];
    final data = body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};

    if (statusCode < 200 || statusCode >= 300) {
      throw SellerCustomerException(
        _messageFromPayload(data, fallback: 'Unable to add customer.'),
        statusCode: statusCode,
      );
    }

    if (data['status']?.toString().toLowerCase() == 'error') {
      throw SellerCustomerException(
        _messageFromPayload(data, fallback: 'Unable to add customer.'),
        statusCode: statusCode,
      );
    }

    return SellerCustomerAddResult.fromJson(data);
  }

  /// Fetches the paginated list of preferred customers for a seller.
  /// GET {sellerCustomerPreferences}/customers-by-seller/{sellerId}
  ///
  /// Returns the raw `data` map from the response; the caller (controller)
  /// is responsible for parsing it into a model.
  Future<Map<String, dynamic>> getPreferredCustomers({
    required int sellerId,
  }) async {
    final response = await _manager.getWithHeaderStatus(
      '${ApiClient.sellerCustomerPreferences}/customers-by-seller/$sellerId',
      {},
    );

    final statusCode =
    response['status_code'] is int ? response['status_code'] as int : 500;
    final body = response['body'];
    final data = body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};

    if (statusCode < 200 || statusCode >= 300) {
      throw SellerCustomerException(
        _messageFromPayload(data, fallback: 'Unable to fetch preferred customers.'),
        statusCode: statusCode,
      );
    }

    if (data['status']?.toString().toLowerCase() == 'error') {
      throw SellerCustomerException(
        _messageFromPayload(data, fallback: 'Unable to fetch preferred customers.'),
        statusCode: statusCode,
      );
    }

    final result = data['data'];
    return result is Map ? Map<String, dynamic>.from(result) : <String, dynamic>{};
  }

  Future<SellerCustomerOrderPage> getCustomerOrdersByShop({
    required int shopId,
    required int userId,
    int page = 1,
  }) async {
    final uri = Uri.parse(ApiClient.shopUserOrders).replace(
      queryParameters: {
        'shop_id': shopId.toString(),
        'user_id': userId.toString(),
        'page': page.toString(),
      },
    );
    final response = await _manager.getWithHeaderStatus(uri.toString(), {});

    final statusCode =
        response['status_code'] is int ? response['status_code'] as int : 500;
    final body = response['body'];
    final data = body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};

    if (statusCode < 200 || statusCode >= 300) {
      throw SellerCustomerException(
        _messageFromPayload(data, fallback: 'Unable to fetch customer orders.'),
        statusCode: statusCode,
      );
    }

    if (data['status']?.toString().toLowerCase() == 'error') {
      throw SellerCustomerException(
        _messageFromPayload(data, fallback: 'Unable to fetch customer orders.'),
        statusCode: statusCode,
      );
    }

    final result = data['data'];
    return SellerCustomerOrderPage.fromJson(
      result is Map ? Map<String, dynamic>.from(result) : <String, dynamic>{},
    );
  }

  String _messageFromPayload(
      Map<String, dynamic> payload, {
        required String fallback,
      }) {
    final errors = payload['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final values = errors.values
          .whereType<List>()
          .expand((items) => items)
          .where((item) => item.toString().trim().isNotEmpty)
          .toList();
      if (values.isNotEmpty) return values.first.toString();
    }

    final message = payload['message']?.toString().trim();
    return message?.isNotEmpty == true ? message! : fallback;
  }
}

class SellerCustomerException implements Exception {
  const SellerCustomerException(
      this.message, {
        required this.statusCode,
      });

  final String message;
  final int statusCode;

  @override
  String toString() => message;
}
