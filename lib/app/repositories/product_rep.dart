import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';
import 'package:image_picker/image_picker.dart';

import '../models/store_category_model.dart';

class ProductRepository {
  Future<dynamic> shopProductList({
    required String shopId,
    required int page,
    int perPage = 24,
    String? search,
    int? categoryId,
    bool? isActive,
  }) async {
    final APIManager manager = APIManager();

    final uri = Uri.parse('${ApiClient.shopProductList}$shopId').replace(
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (isActive != null) 'is_active': isActive.toString(),
      },
    );

    final response = await manager.getWithHeader(uri.toString(), {});

    return response;
  }

  Future<dynamic> storeProductList({
    required String storeId,
    required int page,
    int perPage = 12,
    String? search,
    int? categoryId,
    bool? isActive,
  }) async {
    final APIManager manager = APIManager();

    final uri = Uri.parse('${ApiClient.sellerStoreProductList}$storeId/products')
        .replace(
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (search != null && search.trim().isNotEmpty)
          'search': search.trim(),
        if (categoryId != null) 'category_id': categoryId.toString(),
        if (isActive != null) 'is_active': isActive.toString(),
      },
    );

    final response = await manager.getWithHeader(uri.toString(), {});

    return response;
  }

  Future<Map<String, dynamic>> fetchProductLimitReport({
    required String shopId,
  }) async {
    final APIManager manager = APIManager();
    final String url =
        '${ApiClient.shopProductLimitReport}$shopId/product-limit-report';
    return manager.getWithHeaderStatus(url, {});
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

    return manager.getStatus(url, {});
  }

  Future<List<StoreCategoryModel>> parsePublicStoreCategories({
    required String storeSlug,
  }) async {
    final response = await fetchPublicStoreCategories(storeSlug: storeSlug);
    final statusCode =
        response['status_code'] is int ? response['status_code'] as int : 500;
    final body = response['body'];

    if (statusCode < 200 || statusCode >= 300) {
      return const <StoreCategoryModel>[];
    }

    final payload =
        body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
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
      if (categoryId != null && categoryId.isNotEmpty)
        'category_id=${Uri.encodeComponent(categoryId)}',
      if (categorySlug != null && categorySlug.isNotEmpty)
        'category_slug=${Uri.encodeComponent(categorySlug)}',
      'page=$page',
      'per_page=$perPage',
    ].join('&');

    final String url = '${ApiClient.publicStoreProducts}?$queryParams';
    final APIManager manager = APIManager();
    return manager.getStatus(url, {});
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
    final String url = '${ApiClient.productUpdate}$productId';
    final APIManager manager = APIManager();
    return manager.multipartPostWithHeaderStatus(
      url,
      fields: fields,
    );
  }

  Future<Map<String, dynamic>> createProduct({
    required Map<String, String> fields,
    required List<XFile> images,
  }) async {
    final APIManager manager = APIManager();
    return manager.multipartPostWithHeaderStatus(
      ApiClient.productCreate,
      fields: fields,
    );
  }

  Future<Map<String, dynamic>> uploadProductImages({
    required int productId,
    required List<XFile> images,
  }) async {
    final files = <APIUploadFile>[];
    final fields = <String, String>{
      'type': 'image',
    };
    for (int i = 0; i < images.length; i++) {
      final XFile image = images[i];
      final List<int> bytes = await image.readAsBytes();
      final String fileName = _uploadFileName(image);
      final String contentType = _uploadContentType(fileName);
      files.add(
        APIUploadFile(
          fieldName: 'images[$i][image]',
          bytes: bytes,
          fileName: fileName,
          contentType: contentType,
        ),
      );
      fields['images[$i][is_primary]'] = i == 0 ? '1' : '0';
      fields['images[$i][type]'] = 'image';
    }

    final APIManager manager = APIManager();
    final url = '${ApiClient.productImagesUpload}$productId';
    final payloadLog = {
      'fields': fields,
      'files': files
          .map(
            (file) => {
              'fieldName': file.fieldName,
              'fileName': file.fileName,
              'contentType': file.contentType,
              'bytes': file.bytes.length,
            },
          )
          .toList(),
    };
    print('uploadProductImages url: $url');
    print('uploadProductImages payload: $payloadLog');
    final response = await manager.multipartPostWithHeaderStatus(
      url,
      fields: fields,
      files: files,
    );
    print('uploadProductImages response: $response');

    return response;
  }

  String _uploadFileName(XFile image) {
    final name = image.name.trim();
    if (name.isNotEmpty) return name;

    final pathParts = image.path.split(RegExp(r'[\\/]'));
    final pathName = pathParts.isEmpty ? '' : pathParts.last.trim();
    return pathName.isNotEmpty ? pathName : 'product-image.jpg';
  }

  String _uploadContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }
}
