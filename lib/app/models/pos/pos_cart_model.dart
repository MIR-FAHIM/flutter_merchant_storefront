import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';

class PosCartModel {
  final int? id;
  final int? shopId;
  final int? staffId;
  final String? cartType;
  final String? counterName;
  final String? status;
  final String? holdCode;
  final String? holdReason;
  final String? customerName;
  final String? customerPhone;
  final int totalItems;
  final double subtotal;
  final List<PosCartItemModel> items;

  PosCartModel({
    this.id,
    this.shopId,
    this.staffId,
    this.cartType,
    this.counterName,
    this.status,
    this.holdCode,
    this.holdReason,
    this.customerName,
    this.customerPhone,
    this.totalItems = 0,
    this.subtotal = 0.0,
    this.items = const [],
  });

  factory PosCartModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'];
    List<PosCartItemModel> parsedItems = [];
    if (rawItems is List) {
      parsedItems = rawItems
          .whereType<Map>()
          .map((item) => PosCartItemModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    return PosCartModel(
      id: _toInt(json['id']),
      shopId: _toInt(json['shop_id']),
      staffId: _toInt(json['staff_id']),
      cartType: json['cart_type']?.toString(),
      counterName: json['counter_name']?.toString() ?? 'Counter 1',
      status: json['status']?.toString() ?? 'active',
      holdCode: json['hold_code']?.toString(),
      holdReason: json['hold_reason']?.toString(),
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      totalItems: _toInt(json['total_items']) ?? parsedItems.fold<int>(0, (sum, i) => sum + i.qty),
      subtotal: _toDouble(json['subtotal']) ?? parsedItems.fold<double>(0.0, (sum, i) => sum + i.lineTotal),
      items: parsedItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'staff_id': staffId,
      'cart_type': cartType,
      'counter_name': counterName,
      'status': status,
      'hold_code': holdCode,
      'hold_reason': holdReason,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'total_items': totalItems,
      'subtotal': subtotal,
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}

class PosCartItemModel {
  final int? id;
  final int? cartId;
  final int? productId;
  final int? storeProductId;
  final int? shopId;
  final int qty;
  final double unitPrice;
  final double lineTotal;
  final String? status;
  final String? note;
  final PosItemProductModel? product;

  PosCartItemModel({
    this.id,
    this.cartId,
    this.productId,
    this.storeProductId,
    this.shopId,
    this.qty = 1,
    this.unitPrice = 0.0,
    this.lineTotal = 0.0,
    this.status,
    this.note,
    this.product,
  });

  factory PosCartItemModel.fromJson(Map<String, dynamic> json) {
    return PosCartItemModel(
      id: _toInt(json['id']),
      cartId: _toInt(json['cart_id']),
      productId: _toInt(json['product_id']),
      storeProductId: _toInt(json['store_product_id']),
      shopId: _toInt(json['shop_id']),
      qty: _toInt(json['qty']) ?? 1,
      unitPrice: _toDouble(json['unit_price']) ?? 0.0,
      lineTotal: _toDouble(json['line_total']) ?? 0.0,
      status: json['status']?.toString(),
      note: json['note']?.toString(),
      product: json['product'] is Map<String, dynamic>
          ? PosItemProductModel.fromJson(Map<String, dynamic>.from(json['product']))
          : (json['product'] is Map ? PosItemProductModel.fromJson(Map<String, dynamic>.from(json['product'] as Map)) : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cart_id': cartId,
      'product_id': productId,
      'store_product_id': storeProductId,
      'shop_id': shopId,
      'qty': qty,
      'unit_price': unitPrice,
      'line_total': lineTotal,
      'status': status,
      'note': note,
      'product': product?.toJson(),
    };
  }
}

class PosItemProductModel {
  final int? id;
  final String? name;
  final String? fileName;

  PosItemProductModel({
    this.id,
    this.name,
    this.fileName,
  });

  factory PosItemProductModel.fromJson(Map<String, dynamic> json) {
    String? imgFile;
    if (json['primary_image'] is Map) {
      imgFile = json['primary_image']['file_name']?.toString();
    } else if (json['file_name'] != null) {
      imgFile = json['file_name']?.toString();
    }

    return PosItemProductModel(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      fileName: imgFile,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (fileName != null) 'primary_image': {'file_name': fileName},
    };
  }

  String imageUrl() {
    if (fileName == null || fileName!.trim().isEmpty) return '';
    final cleaned = fileName!.trim().replaceFirst(RegExp(r'^/+'), '');
    if (cleaned.startsWith('http://') || cleaned.startsWith('https://')) {
      return cleaned;
    }
    return '${CompanyData.baseUrl}/$cleaned';
  }
}

class PosHoldCartResponse {
  final String? holdCode;
  final PosCartModel? heldCart;
  final PosCartModel? newActiveCart;

  PosHoldCartResponse({
    this.holdCode,
    this.heldCart,
    this.newActiveCart,
  });

  factory PosHoldCartResponse.fromJson(Map<String, dynamic> json) {
    return PosHoldCartResponse(
      holdCode: json['hold_code']?.toString(),
      heldCart: json['held_cart'] is Map<String, dynamic>
          ? PosCartModel.fromJson(Map<String, dynamic>.from(json['held_cart']))
          : (json['held_cart'] is Map ? PosCartModel.fromJson(Map<String, dynamic>.from(json['held_cart'] as Map)) : null),
      newActiveCart: json['new_active_cart'] is Map<String, dynamic>
          ? PosCartModel.fromJson(Map<String, dynamic>.from(json['new_active_cart']))
          : (json['new_active_cart'] is Map ? PosCartModel.fromJson(Map<String, dynamic>.from(json['new_active_cart'] as Map)) : null),
    );
  }
}

class PosCheckoutResponse {
  final int? id;
  final String? orderNumber;
  final String? status;
  final String? paymentStatus;
  final double? subtotal;
  final double? total;
  final String? platform;

  PosCheckoutResponse({
    this.id,
    this.orderNumber,
    this.status,
    this.paymentStatus,
    this.subtotal,
    this.total,
    this.platform,
  });

  factory PosCheckoutResponse.fromJson(Map<String, dynamic> json) {
    return PosCheckoutResponse(
      id: _toInt(json['id']),
      orderNumber: json['order_number']?.toString(),
      status: json['status']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      subtotal: _toDouble(json['subtotal']),
      total: _toDouble(json['total']),
      platform: json['platform']?.toString(),
    );
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}
