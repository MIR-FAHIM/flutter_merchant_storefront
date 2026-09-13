import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';
import 'package:ecom_delivery_flutter/app/models/delivery/delivery_man_model.dart';
import 'package:flutter/material.dart';

class DeliveryManRepository {
  final APIManager _apiManager = APIManager();

  Future<DeliveryManResponseModel> addDeliveryMan({
    required DeliveryManRequestModel request,
  }) async {
    try {
      final response = await _apiManager.postJsonWithHeaderStatus(
        ApiClient.addDeliveryMan,
        request.toJson(),
        {},
      );

      final int statusCode = response['status_code'] is int ? response['status_code'] as int : 500;
      final dynamic body = response['body'];
      final Map<String, dynamic> payload =
          body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};

      if (statusCode >= 200 && statusCode < 300) {
        final model = DeliveryManResponseModel.fromJson(payload);
        return model;
      }

      final String msg = payload['message']?.toString() ??
          payload['error']?.toString() ??
          'Failed to add delivery man (Status $statusCode)';

      throw DeliveryManException(
        statusCode: statusCode,
        message: msg,
      );
    } catch (e) {
      debugPrint('DeliveryManRepository error: $e');
      if (e is DeliveryManException) rethrow;

      throw DeliveryManException(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }

  Future<DeliveryMenListResponseModel> getDeliveryMenByShop({
    required String shopId,
    String? search,
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final Map<String, String> queryParameters = {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (shopId.isNotEmpty) 'shop_id': shopId,
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
        if (status != null && status.trim().isNotEmpty && status.toLowerCase() != 'all')
          'status': status.trim().toLowerCase(),
      };

      final Uri uri = Uri.parse('${ApiClient.deliveryMenShop}$shopId')
          .replace(queryParameters: queryParameters);

      final response = await _apiManager.getWithHeaderStatus(
        uri.toString(),
        {},
      );

      final int statusCode = response['status_code'] is int ? response['status_code'] as int : 500;
      final dynamic body = response['body'];
      final Map<String, dynamic> payload =
          body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};

      if (statusCode >= 200 && statusCode < 300) {
        final model = DeliveryMenListResponseModel.fromJson(payload);
        return model;
      }

      final String msg = payload['message']?.toString() ??
          payload['error']?.toString() ??
          'Failed to load delivery men list (Status $statusCode)';

      throw DeliveryManException(
        statusCode: statusCode,
        message: msg,
      );
    } catch (e) {
      debugPrint('DeliveryManRepository getDeliveryMenByShop error: $e');
      if (e is DeliveryManException) rethrow;

      throw DeliveryManException(
        statusCode: 500,
        message: e.toString(),
      );
    }
  }
}
