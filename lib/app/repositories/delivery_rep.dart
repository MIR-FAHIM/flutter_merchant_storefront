import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';

import 'package:ecom_delivery_flutter/app/services/auth_service.dart';

class DeliveryRepository {
  final userdata = GetStorage();

  ///User login api call
  userLogin(String phoneNumber, String pass, String fcm) async {
    Map _loginData = {
      'email': phoneNumber,
      'password': pass,
      'fcm_token': fcm,
    };

    APIManager _manager = APIManager();
    final response = await _manager.loginAPICall(ApiClient.login, _loginData);

    print('user login: ${response}');

    return response;
  }

  assignedDelivery(String userID) async {
    APIManager _manager = APIManager();
    final response = await _manager.getWithHeader(ApiClient.assignedDelivery + userID, {});

    print('assignedDelivery 34345: ${response}');

    return response;
  }
  deliveredDelivery(String userID) async {
    APIManager _manager = APIManager();
    final response = await _manager.getWithHeader(ApiClient.deliveredDelivery + userID, {});

    print('deliveredDelivery 453: ${response}');

    return response;
  }

  completedAllDelivery(String userID) async {
    APIManager _manager = APIManager();
    final response = await _manager.getWithHeader(ApiClient.completedAllDelivery + userID, {});

    print('completedAllDelivery 4332: ${response}');

    return response;
  }

  reportDelivery(String userID) async {
    APIManager _manager = APIManager();
    final response = await _manager.getWithHeader(ApiClient.reportDelivery + userID, {});

    print('reportDelivery 4334: ${response}');

    return response;
  }

  reportShopDashboard(String userID) async {
    APIManager _manager = APIManager();
    final response = await _manager.getWithHeader(ApiClient.shopDashboard + userID, {});

    print('shopDashboard 4323234: ${response}');

    return response;
  }

  Future<Map<String, dynamic>> reportShopDashboardSummary({
    required String shopID,
    required String period,
  }) async {
    final uri = Uri.parse('${ApiClient.shopDashboardSummary}$shopID/summary')
        .replace(queryParameters: {'period': period});
    final response = await APIManager().getWithHeaderStatus(uri.toString(), {});
    return response;
  }
}
