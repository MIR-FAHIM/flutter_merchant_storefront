import 'dart:convert';
import 'dart:io';

import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';
import 'package:ecom_delivery_flutter/app/api_providers/customExceptions.dart';
import 'package:ecom_delivery_flutter/app/models/pos/pos_cart_model.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PosRepository {
  Map<String, String> _buildHeaders() {
    final token = Get.find<AuthService>().currentUser.value.data?.token ?? '';
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  dynamic _decodeBody(String bodyString) {
    if (bodyString.isEmpty) return null;
    try {
      return json.decode(bodyString);
    } catch (_) {
      return {'message': bodyString};
    }
  }

  String _extractErrorMessage(dynamic decoded, String fallback) {
    if (decoded is Map) {
      if (decoded['errors'] != null) {
        final errors = decoded['errors'];
        if (errors is Map) {
          if (errors['error'] != null &&
              errors['error'].toString().trim().isNotEmpty) {
            return errors['error'].toString().trim();
          }
          final values = errors.values
              .expand((v) => v is Iterable ? v : [v])
              .where((item) => item != null && item.toString().trim().isNotEmpty)
              .map((e) => e.toString().trim())
              .toList();
          if (values.isNotEmpty) return values.first;
        } else if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        } else if (errors is String && errors.trim().isNotEmpty) {
          return errors.trim();
        }
      }
      if (decoded['message'] != null &&
          decoded['message'].toString().trim().isNotEmpty) {
        return decoded['message'].toString().trim();
      }
    }
    return fallback;
  }

  /// A. Get Active Counter Cart
  Future<PosCartModel?> fetchActiveCart({
    required String storeId,
    required String counterName,
  }) async {
    final uri = Uri.parse(ApiClient.posCart(storeId)).replace(
      queryParameters: {'counter_name': counterName},
    );

    debugPrint('POS fetchActiveCart: $uri');

    try {
      final response = await http.get(uri, headers: _buildHeaders());
      final decoded = _decodeBody(response.body);
      debugPrint('POS fetchActiveCart response [${response.statusCode}]: $decoded');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded is Map && decoded['data'] is Map
            ? decoded['data'] as Map<String, dynamic>
            : (decoded is Map<String, dynamic> ? decoded : null);

        if (data != null) {
          return PosCartModel.fromJson(data);
        }
      }
      return null;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  /// B. Add Product to Cart
  Future<PosCartModel?> addItem({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse(ApiClient.posCartAddItem(storeId));
    debugPrint('POS addItem: $uri with body: $body');

    try {
      final response = await http.post(
        uri,
        headers: _buildHeaders(),
        body: jsonEncode(body),
      );
      final decoded = _decodeBody(response.body);
      debugPrint('POS addItem response [${response.statusCode}]: $decoded');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded is Map && decoded['data'] is Map
            ? decoded['data'] as Map<String, dynamic>
            : (decoded is Map<String, dynamic> ? decoded : null);

        if (data != null) {
          return PosCartModel.fromJson(data);
        }
      } else {
        final message = _extractErrorMessage(decoded, 'Failed to add item to POS cart');
        throw Exception(message);
      }
      return null;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  /// C. Update Cart Item Qty / Custom Price / Note
  Future<PosCartModel?> updateItem({
    required String storeId,
    required int itemId,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse(ApiClient.posCartUpdateItem(storeId, itemId));
    debugPrint('POS updateItem: $uri with body: $body');

    try {
      final response = await http.put(
        uri,
        headers: _buildHeaders(),
        body: jsonEncode(body),
      );
      final decoded = _decodeBody(response.body);
      debugPrint('POS updateItem response [${response.statusCode}]: $decoded');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded is Map && decoded['data'] is Map
            ? decoded['data'] as Map<String, dynamic>
            : (decoded is Map<String, dynamic> ? decoded : null);

        if (data != null) {
          return PosCartModel.fromJson(data);
        }
      } else {
        final message = _extractErrorMessage(decoded, 'Failed to update item');
        throw Exception(message);
      }
      return null;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  /// D. Remove Item from Cart
  Future<PosCartModel?> removeItem({
    required String storeId,
    required int itemId,
  }) async {
    final uri = Uri.parse(ApiClient.posCartRemoveItem(storeId, itemId));
    debugPrint('POS removeItem: $uri');

    try {
      final response = await http.delete(uri, headers: _buildHeaders());
      final decoded = _decodeBody(response.body);
      debugPrint('POS removeItem response [${response.statusCode}]: $decoded');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded is Map && decoded['data'] is Map
            ? decoded['data'] as Map<String, dynamic>
            : (decoded is Map<String, dynamic> ? decoded : null);

        if (data != null) {
          return PosCartModel.fromJson(data);
        }
      } else {
        final message = _extractErrorMessage(decoded, 'Failed to remove item');
        throw Exception(message);
      }
      return null;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  /// E. Park / Hold Current Cart
  Future<PosHoldCartResponse?> holdCart({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse(ApiClient.posCartHold(storeId));
    debugPrint('POS holdCart: $uri with body: $body');

    try {
      final response = await http.post(
        uri,
        headers: _buildHeaders(),
        body: jsonEncode(body),
      );
      final decoded = _decodeBody(response.body);
      debugPrint('POS holdCart response [${response.statusCode}]: $decoded');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded is Map && decoded['data'] is Map
            ? decoded['data'] as Map<String, dynamic>
            : (decoded is Map<String, dynamic> ? decoded : null);

        if (data != null) {
          return PosHoldCartResponse.fromJson(data);
        }
      } else {
        final message = _extractErrorMessage(decoded, 'Failed to hold cart');
        throw Exception(message);
      }
      return null;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  /// F. List All Parked / Held Bills
  Future<List<PosCartModel>> fetchHeldList({
    required String storeId,
  }) async {
    final uri = Uri.parse(ApiClient.posCartHeldList(storeId));
    debugPrint('POS fetchHeldList: $uri');

    try {
      final response = await http.get(uri, headers: _buildHeaders());
      final decoded = _decodeBody(response.body);
      debugPrint('POS fetchHeldList response [${response.statusCode}]: $decoded');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        dynamic rawList;
        if (decoded is List) {
          rawList = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          rawList = decoded['data'];
        }

        if (rawList is List) {
          return rawList
              .whereType<Map>()
              .map((item) => PosCartModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
      return [];
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  /// G. Resume a Parked Bill
  Future<PosCartModel?> resumeCart({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse(ApiClient.posCartResume(storeId));
    debugPrint('POS resumeCart: $uri with body: $body');

    try {
      final response = await http.post(
        uri,
        headers: _buildHeaders(),
        body: jsonEncode(body),
      );
      final decoded = _decodeBody(response.body);
      debugPrint('POS resumeCart response [${response.statusCode}]: $decoded');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded is Map && decoded['data'] is Map
            ? decoded['data'] as Map<String, dynamic>
            : (decoded is Map<String, dynamic> ? decoded : null);

        if (data != null) {
          return PosCartModel.fromJson(data);
        }
      } else {
        final message = _extractErrorMessage(decoded, 'Failed to resume bill');
        throw Exception(message);
      }
      return null;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }

  /// H. Checkout Cart
  Future<PosCheckoutResponse?> checkout({
    required String storeId,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse(ApiClient.posCartCheckout(storeId));
    debugPrint('POS checkout: $uri with body: $body');

    try {
      final response = await http.post(
        uri,
        headers: _buildHeaders(),
        body: jsonEncode(body),
      );
      final decoded = _decodeBody(response.body);
      debugPrint('POS checkout response [${response.statusCode}]: $decoded');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = decoded is Map && decoded['data'] is Map
            ? decoded['data'] as Map<String, dynamic>
            : (decoded is Map<String, dynamic> ? decoded : null);

        if (data != null) {
          return PosCheckoutResponse.fromJson(data);
        }
      } else {
        final message = _extractErrorMessage(decoded, 'Failed to complete checkout');
        throw Exception(message);
      }
      return null;
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
  }
}
