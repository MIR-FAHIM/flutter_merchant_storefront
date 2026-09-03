//155 api

import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';

class ApiClient {
  static const String baseUrl = CompanyData.baseUrl;


  static const String login = '$baseUrl/api/auth/login-seller';
  static const String sellerLogin = '$baseUrl/api/auth/login-seller';
  static const String createSeller = '$baseUrl/api/users/create-seller';
  static const String changeNotificationStatus =
      '$baseUrl/api/appapi/myNotifications/changeStatus';

  static const String getProfile = '$baseUrl/api/users/details/';
  static const String sellerProfile = '$baseUrl/api/users/seller-profile/';


  // delivery

  static const String allDelivery = '$baseUrl/api/deliveries/all/';
  static const String completedAllDelivery = '$baseUrl/api/deliveries/completed/';
  static const String deliveredDelivery = '$baseUrl/api/deliveries/delivered/';
  static const String assignedDelivery = '$baseUrl/api/deliveries/assigned/';
  static const String reportDelivery = '$baseUrl/api/deliveries/report/';
  static const String orderDetail = '$baseUrl/api/orders/details/';
  static const String orderStatusList = '$baseUrl/api/orders/orderstatus';
  static const String changeOrderStatus = '$baseUrl/api/orders/status/';


  //shop
  static const String shopDashboard = '$baseUrl/api/reports/shop/';
  static const String shopDashboardSummary = shopDashboard;
  static const String sellerShopList = '$baseUrl/api/shops/list';
  static const String shopProductList = '$baseUrl/api/shops/products/';
  static const String sellerStoreProductList = '$baseUrl/api/seller/stores/';
  static const String sellerStoreCategories = '$baseUrl/api/seller/stores/';
  static const String brandsList = '$baseUrl/api/brands/list';
  static const String productCreate = '$baseUrl/api/products/create';
  static const String productImagesUpload =
      '$baseUrl/api/products/images/upload/';
  static const String productDetails = '$baseUrl/api/products/details/';
  static const String productUpdate = '$baseUrl/api/products/update/';
  static const String publicStoreCategories = '$baseUrl/api/public/stores/';
  static const String publicStoreProducts = '$baseUrl/api/products/list';
  static const String publicStoreFeaturedProducts = '$baseUrl/api/products/list/featured';
  static const String publicStoreTodayDealProducts = '$baseUrl/api/products/list/today-deal';
  static const String shopOrderList = '$baseUrl/api/orders/shop/';
  static const String subscriptionPackages =
      '$baseUrl/api/subscription-packages';
  static const String stores = '$baseUrl/api/stores/';

  static const String orderDetails = '$baseUrl/api/orders/details/';
  static const String chatBase = '$baseUrl/api/chat';
  static const String chatConversations = '$chatBase/conversations';
    static const String chatUnreadCount = '$chatBase/unread-count';
  static const String chatMessages = '$chatBase/messages/';
  static const String messageReadBase = '$chatBase/messages/';
  static const String conversationReadBase = '$chatBase/conversations/';
}
