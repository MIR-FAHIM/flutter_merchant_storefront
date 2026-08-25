//155 api

import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';

class ApiClient {
  static const String baseUrl = CompanyData.baseUrl;


  static const String login = '$baseUrl/api/auth/login';
  static const String changeNotificationStatus =
      '${baseUrl}/api/appapi/myNotifications/changeStatus';

  static const String getProfile = '$baseUrl/api/users/details/';



  // delivery

  static const String allDelivery = '$baseUrl/api/deliveries/all/';
  static const String completedAllDelivery = '$baseUrl/api/deliveries/completed/';
  static const String deliveredDelivery = '$baseUrl/api/deliveries/delivered/';
  static const String assignedDelivery = '$baseUrl/api/deliveries/assigned/';
  static const String reportDelivery = '$baseUrl/api/deliveries/report/';
  static const String orderDetail = '$baseUrl/api/orders/details/';
  static const String changeOrderStatus = '$baseUrl/api/orders/status/';


  //shop
  static const String shopDashboard = '$baseUrl/api/reports/shop/';
  static const String shopProductList = '$baseUrl/api/shops/products/';
  static const String shopOrderList = '$baseUrl/api/orders/shop/';

  static const String orderDetails = '$baseUrl/api/orders/details/';
}
