import 'dart:convert';

import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/store_category_model.dart';

class ProductRepository {
  Future<dynamic> shopProductList({
    required String shopId,
    required int page,
    int perPage = 24,
  }) async {
    final APIManager manager = APIManager();

    final String url =
        '${ApiClient.shopProductList}$shopId?page=$page&per_page=$perPage';

    final response = await manager.getWithHeader(url, {});

    return response;
  }

  Future<dynamic> storeProductList({
    required String storeId,
    required int page,
    int perPage = 12,
  }) async {
    final APIManager manager = APIManager();

    final String url =
        '${ApiClient.sellerStoreProductList}$storeId/products?page=$page&per_page=$perPage';

    final response = await manager.getWithHeader(url, {});

    return response;
  }

  Future<Map<String, dynamic>> fetchSellerShops() async {
    final APIManager manager = APIManager();
    final String url = '${ApiClient.sellerShopList}?page=1&per_page=100';
    return manager.getWithHeaderStatus(url, {});
  }

  Future<Map<String, dynamic>> fetchStoreCategories({
    required String storeId,
  }) async {
    final APIManager manager = APIManager();
    final String url =
        '${ApiClient.sellerStoreCategories}$storeId/categories/marketplace';
    return manager.getWithHeaderStatus(url, {});
  }

  Future<Map<String, dynamic>> syncStoreCategories({
    required String storeId,
    required List<int> categoryIds,
  }) async {
    final APIManager manager = APIManager();
    final String url =
        '${ApiClient.sellerStoreCategories}$storeId/categories/sync';

    return manager.postJsonWithHeaderStatus(
      url,
      {
        'category_ids': categoryIds,
      },
      {},
    );
  }

  Future<Map<String, dynamic>> fetchPublicStoreCategories({
    required String storeSlug,
  }) async {
    final APIManager manager = APIManager();
    final String url = '${ApiClient.publicStoreCategories}$storeSlug/categories';

    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      final dynamic decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);

      return {
        'status_code': response.statusCode,
        'body': decoded is Map<String, dynamic>
            ? decoded
            : <String, dynamic>{'message': response.body},
      };
    } catch (_) {
      return {
        'status_code': 500,
        'body': {'message': 'Could not load store categories. Please try again.'},
      };
    }
  }

  Future<List<StoreCategoryModel>> parsePublicStoreCategories({
    required String storeSlug,
  }) async {
    final response = await fetchPublicStoreCategories(storeSlug: storeSlug);
    final statusCode = response['status_code'] is int ? response['status_code'] as int : 500;
    final body = response['body'];

    if (statusCode < 200 || statusCode >= 300) {
      return const <StoreCategoryModel>[];
    }

    final payload = body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
    final data = payload['data'];
    return StoreCategoryModel.fromList(data);
  }

  Future<Map<String, dynamic>> fetchPublicStoreProducts({
    required String storeSlug,
    String? categoryId,
    String? categorySlug,
    int page = 1,
    int perPage = 20,
  }) async {
    final String queryParams = <String>[
      'store_slug=${Uri.encodeComponent(storeSlug)}',
      if (categoryId != null && categoryId.isNotEmpty) 'category_id=${Uri.encodeComponent(categoryId)}',
      if (categorySlug != null && categorySlug.isNotEmpty) 'category_slug=${Uri.encodeComponent(categorySlug)}',
      'page=$page',
      'per_page=$perPage',
    ].join('&');

    final String url = '${ApiClient.publicStoreProducts}?$queryParams';
    final Map<String, String> headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      final dynamic decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);

      return {
        'status_code': response.statusCode,
        'body': decoded is Map<String, dynamic>
            ? decoded
            : <String, dynamic>{'message': response.body},
      };
    } catch (_) {
      return {
        'status_code': 500,
        'body': {'message': 'Could not load products for this store.'},
      };
    }
  }

  Future<Map<String, dynamic>> fetchBrands() async {
    final APIManager manager = APIManager();
    final String url = ApiClient.brandsList;
    return manager.getWithHeaderStatus(url, {});
  }

  Future<Map<String, dynamic>> fetchProductDetails({
    required int productId,
  }) async {
    final APIManager manager = APIManager();
    final String url = '${ApiClient.productDetails}$productId';
    return manager.getWithHeaderStatus(url, {});
  }

  Future<Map<String, dynamic>> updateProduct({
    required int productId,
    required Map<String, String> fields,
  }) async {
    final String token = Get.find<AuthService>().currentUser.value.data!.token!;
    final String url = '${ApiClient.productUpdate}$productId';

    final http.MultipartRequest request = http.MultipartRequest(
      'POST',
      Uri.parse(url),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields.addAll(fields);

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

  Future<Map<String, dynamic>> createProduct({
    required Map<String, String> fields,
    required List<XFile> images,
  }) async {
    final String token = Get.find<AuthService>().currentUser.value.data!.token!;
    final http.MultipartRequest request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiClient.productCreate),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields.addAll(fields);

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

  Future<Map<String, dynamic>> uploadProductImages({
    required int productId,
    required List<XFile> images,
  }) async {
    final String token = Get.find<AuthService>().currentUser.value.data!.token!;
    final http.MultipartRequest request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiClient.productImagesUpload}$productId'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    for (int i = 0; i < images.length; i++) {
      final XFile image = images[i];
      final List<int> bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'images[$i][image]',
          bytes,
          filename: image.name,
        ),
      );
      request.fields['images[$i][is_primary]'] = i == 0 ? '1' : '0';
    }

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
