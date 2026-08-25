import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';

import 'package:ecom_delivery_flutter/app/services/auth_service.dart';

class AuthRepository {
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

  getProfile(String userID) async {
    APIManager _manager = APIManager();
    final response = await _manager.getWithHeader(ApiClient.getProfile + userID, {});

    print('user profile: ${response}');

    return response;
  }
}
