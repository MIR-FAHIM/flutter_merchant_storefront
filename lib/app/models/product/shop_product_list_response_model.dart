import 'package:ecom_delivery_flutter/app/models/product/product_response_model.dart';

class ShopProductListResponseModel {
  final String? status;
  final String? message;
  final ShopProductPagination? data;

  const ShopProductListResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory ShopProductListResponseModel.fromJson(Map<String, dynamic> json) {
    return ShopProductListResponseModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] is Map
          ? ShopProductPagination.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
    );
  }

  bool get isSuccess => status?.toLowerCase() == 'success';
}

class ShopProductPagination {
  final int currentPage;
  final List<ProductData> products;
  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final String? lastPageUrl;
  final List<ProductPaginationLink> links;
  final String? nextPageUrl;
  final String? path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  const ShopProductPagination({
    required this.currentPage,
    required this.products,
    this.firstPageUrl,
    this.from,
    required this.lastPage,
    this.lastPageUrl,
    this.links = const [],
    this.nextPageUrl,
    this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory ShopProductPagination.fromJson(Map<String, dynamic> json) {
    return ShopProductPagination(
      currentPage: _toInt(json['current_page']) ?? 1,
      products: json['data'] is List
          ? (json['data'] as List)
              .whereType<Map>()
              .map(
                (item) => ProductData.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const <ProductData>[],
      firstPageUrl: json['first_page_url']?.toString(),
      from: _toInt(json['from']),
      lastPage: _toInt(json['last_page']) ?? 1,
      lastPageUrl: json['last_page_url']?.toString(),
      links: json['links'] is List
          ? (json['links'] as List)
              .whereType<Map>()
              .map(
                (item) => ProductPaginationLink.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList()
          : const <ProductPaginationLink>[],
      nextPageUrl: json['next_page_url']?.toString(),
      path: json['path']?.toString(),
      perPage: _toInt(json['per_page']) ?? 0,
      prevPageUrl: json['prev_page_url']?.toString(),
      to: _toInt(json['to']),
      total: _toInt(json['total']) ?? 0,
    );
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();

  return int.tryParse(value.toString());
}
