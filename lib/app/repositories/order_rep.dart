
import 'dart:convert';

import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class OrderRepository {
  Future<dynamic> shopOrderList({
    required String shopId,
    required int page,
    int perPage = 40,
  }) async {
    final APIManager manager = APIManager();

    final String url =
        '${ApiClient.shopOrderList}$shopId?page=$page&per_page=$perPage';

    final response = await manager.getWithHeader(url, {});

    return response;
  }

  Future<dynamic> orderDetails({
    required String orderId,
  }) async {
    final APIManager manager = APIManager();

    final String url = ApiClient.orderDetails + orderId;

    final response = await manager.getWithHeader(url, {});

    return response;
  }

  Future<Map<String, dynamic>> fetchOrderStatuses() async {
    final APIManager manager = APIManager();
    final String url = ApiClient.orderStatusList;
    return manager.getWithHeaderStatus(url, {});
  }

  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final String token = Get.find<AuthService>().currentUser.value.data!.token!;
    final String url = '${ApiClient.changeOrderStatus}$orderId?status=$status';

    final http.MultipartRequest request = http.MultipartRequest(
      'PATCH',
      Uri.parse(url),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields['status'] = status;

    final http.StreamedResponse streamedResponse = await request.send();
    final http.Response response = await http.Response.fromStream(streamedResponse);
    final dynamic decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);

    return {
      'status_code': response.statusCode,
      'body': decoded is Map<String, dynamic>
          ? decoded
          : <String, dynamic>{'message': response.body},
    };
  }
}