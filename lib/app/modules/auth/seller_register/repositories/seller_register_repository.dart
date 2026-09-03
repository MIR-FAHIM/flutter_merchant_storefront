import 'dart:convert';
import 'dart:io';

import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';
import 'package:http/http.dart' as http;

class SellerRegisterRepository {
  Future<SellerRegisterResponse> createSeller(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(ApiClient.createSeller),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      final decoded = _decode(response.body);
      return SellerRegisterResponse(
        statusCode: response.statusCode,
        body: decoded,
      );
    } on SocketException {
      throw SellerRegisterException('No Internet connection');
    } catch (e) {
      throw SellerRegisterException(e.toString());
    }
  }

  dynamic _decode(String body) {
    if (body.trim().isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return {'message': body};
    }
  }
}

class SellerRegisterResponse {
  SellerRegisterResponse({
    required this.statusCode,
    required this.body,
  });

  final int statusCode;
  final dynamic body;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  String get message {
    if (body is Map && body['message'] != null) {
      return body['message'].toString();
    }
    if (isSuccess) return 'Seller and shop created successfully';
    return 'Registration failed. Please try again.';
  }

  Map<String, List<String>> get fieldErrors {
    if (body is! Map || body['errors'] is! Map) return {};

    final errors = <String, List<String>>{};
    (body['errors'] as Map).forEach((key, value) {
      if (value is List) {
        errors[key.toString()] = value.map((item) => item.toString()).toList();
      } else if (value != null) {
        errors[key.toString()] = [value.toString()];
      }
    });
    return errors;
  }

  Map<String, dynamic> get data {
    if (body is Map && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data']);
    }
    return {};
  }
}

class SellerRegisterException implements Exception {
  SellerRegisterException(this.message);

  final String message;

  @override
  String toString() => message;
}
