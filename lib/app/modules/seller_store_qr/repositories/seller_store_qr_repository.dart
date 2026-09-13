import 'dart:typed_data';
import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SellerStoreQrRepository {
  final APIManager _manager = APIManager();

  Future<dynamic> getSellerStores({
    required String userId,
    int page = 1,
    int perPage = 200,
  }) async {
    final String url =
        '${ApiClient.sellerShopList}?user_id=$userId&page=$page&per_page=$perPage';

    final response = await _manager.getWithHeader(url, {});

    print('seller stores response: $response');

    return response;
  }

  Future<Uint8List?> fetchStoreQrImage({
    required String storeId,
    required String token,
  }) async {
    try {
      final String url = ApiClient.storeQrAppUrl(storeId);
      final Map<String, String> headers = {
        'Authorization': 'Bearer $token',
        'Accept': 'image/png',
      };

      print('Fetching Store QR Image: $url');
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response.bodyBytes;
      } else {
        print('fetchStoreQrImage failed with statusCode: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('fetchStoreQrImage error: $e');
    }
    return null;
  }
}
