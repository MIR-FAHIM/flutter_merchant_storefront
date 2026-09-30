import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';
import 'package:ecom_delivery_flutter/app/models/product/product_response_model.dart';

class ShopOrderResponseModel {
  final String? status;
  final String? message;
  final ShopOrderPagination? data;

  ShopOrderResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory ShopOrderResponseModel.fromJson(Map<String, dynamic> json) {
    return ShopOrderResponseModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? ShopOrderPagination.fromJson(Map<String, dynamic>.from(json['data']))
          : (json['data'] is Map ? ShopOrderPagination.fromJson(Map<String, dynamic>.from(json['data'] as Map)) : null),
    );
  }

  bool get isSuccess => status?.toLowerCase() == 'success';

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class ShopOrderPagination {
  final int? currentPage;
  final List<ShopOrderItem> orders;
  final List<OrderInfo> orderList;
  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  ShopOrderPagination({
    this.currentPage,
    this.orders = const [],
    this.orderList = const [],
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory ShopOrderPagination.fromJson(Map<String, dynamic> json) {
    final List<ShopOrderItem> itemsList = [];
    final List<OrderInfo> rawOrderList = [];

    if (json['data'] is List) {
      for (final e in (json['data'] as List).whereType<Map>()) {
        final map = Map<String, dynamic>.from(e);
        final bool looksLikeOrder = map.containsKey('order_number') ||
            map.containsKey('customer_name') ||
            map.containsKey('items');

        if (looksLikeOrder) {
          final order = OrderInfo.fromJson(map);
          rawOrderList.add(order);

          final firstItem = (order.items != null && order.items!.isNotEmpty)
              ? order.items!.first
              : null;
          final int count = order.items?.length ?? 0;
          final String productName;
          if (count > 1) {
            productName = '${firstItem?.productName ?? "Product"} (+$count items)';
          } else {
            productName = firstItem?.productName ??
                (order.orderNumber != null ? 'Order #${order.orderNumber}' : 'Order #${order.id ?? '-'}');
          }

          itemsList.add(
            ShopOrderItem(
              id: firstItem?.id ?? order.id,
              orderId: order.id,
              productId: firstItem?.productId,
              shopId: order.shopId ?? firstItem?.shopId,
              productName: productName,
              sku: firstItem?.sku,
              unitPrice: firstItem?.unitPrice ?? order.total,
              qty: order.totalItems ?? order.totalItemCount ?? firstItem?.qty ?? 1,
              lineTotal: order.total,
              status: order.status,
              isSettleWithSeller: firstItem?.isSettleWithSeller,
              createdAt: order.createdAt ?? firstItem?.createdAt,
              updatedAt: order.updatedAt ?? firstItem?.updatedAt,
              order: order,
              product: firstItem?.product,
            ),
          );
        } else {
          final item = ShopOrderItem.fromJson(map);
          itemsList.add(item);
          if (item.order != null) {
            rawOrderList.add(item.order!);
          }
        }
      }
    }

    return ShopOrderPagination(
      currentPage: _toInt(json['current_page']),
      orders: itemsList,
      orderList: rawOrderList,
      firstPageUrl: json['first_page_url']?.toString(),
      from: _toInt(json['from']),
      lastPage: _toInt(json['last_page']),
      lastPageUrl: json['last_page_url']?.toString(),
      nextPageUrl: json['next_page_url']?.toString(),
      path: json['path']?.toString(),
      perPage: _toInt(json['per_page']),
      prevPageUrl: json['prev_page_url']?.toString(),
      to: _toInt(json['to']),
      total: _toInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': orderList.isNotEmpty
          ? orderList.map((e) => e.toJson()).toList()
          : orders.map((e) => e.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
      'total': total,
    };
  }
}

class OrderDetailResponseModel {
  final String? status;
  final String? message;
  final ShopOrderItem? item;
  final OrderInfo? order;

  OrderDetailResponseModel({
    this.status,
    this.message,
    this.item,
    this.order,
  });

  factory OrderDetailResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];

    ShopOrderItem? parsedItem;
    OrderInfo? parsedOrder;

    if (rawData is Map) {
      final map = Map<String, dynamic>.from(rawData);
      final bool looksLikeShopItem =
          map.containsKey('order_id') || map.containsKey('product_name');

      final bool looksLikeOrder =
          map.containsKey('order_number') || map.containsKey('customer_name') || map.containsKey('items');

      if (looksLikeShopItem) {
        parsedItem = ShopOrderItem.fromJson(map);
        parsedOrder = parsedItem.order;
      } else if (map['order'] is Map) {
        parsedItem = ShopOrderItem.fromJson(map);
        parsedOrder = OrderInfo.fromJson(Map<String, dynamic>.from(map['order'] as Map));
      } else if (looksLikeOrder) {
        parsedOrder = OrderInfo.fromJson(map);
        if (parsedOrder.items != null && parsedOrder.items!.isNotEmpty) {
          parsedItem = parsedOrder.items!.first;
        }
      }
    }

    return OrderDetailResponseModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      item: parsedItem,
      order: parsedOrder,
    );
  }

  bool get isSuccess => status?.toLowerCase() == 'success';
}

class ShopOrderItem {
  final int? id;
  final int? orderId;
  final int? productId;
  final int? shopId;
  final String? productName;
  final String? sku;
  final double? unitPrice;
  final int? qty;
  final double? lineTotal;
  final String? status;
  final int? isSettleWithSeller;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final OrderInfo? order;
  final ProductData? product;
  final String? image;

  ShopOrderItem({
    this.id,
    this.orderId,
    this.productId,
    this.shopId,
    this.productName,
    this.sku,
    this.unitPrice,
    this.qty,
    this.lineTotal,
    this.status,
    this.isSettleWithSeller,
    this.createdAt,
    this.updatedAt,
    this.order,
    this.product,
    this.image,
  });

  factory ShopOrderItem.fromJson(Map<String, dynamic> json) {
    return ShopOrderItem(
      id: _toInt(json['id']),
      orderId: _toInt(json['order_id']),
      productId: _toInt(json['product_id']),
      shopId: _toInt(json['shop_id']),
      productName: json['product_name']?.toString() ??
          json['name']?.toString() ??
          (json['product'] is Map ? json['product']['name']?.toString() : null),
      sku: json['sku']?.toString() ??
          (json['product'] is Map ? json['product']['sku']?.toString() : null),
      unitPrice: _toDouble(json['unit_price'] ??
          (json['product'] is Map ? json['product']['unit_price'] : null)),
      qty: _toInt(json['qty'] ?? json['quantity']),
      lineTotal: _toDouble(json['line_total'] ??
          ((_toDouble(json['unit_price']) ?? 0) * (_toInt(json['qty']) ?? 1))),
      status: json['status']?.toString(),
      isSettleWithSeller: _toInt(json['is_settle_with_seller']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      order: json['order'] is Map
          ? OrderInfo.fromJson(Map<String, dynamic>.from(json['order'] as Map))
          : null,
      product: json['product'] is Map
          ? ProductData.fromJson(Map<String, dynamic>.from(json['product'] as Map))
          : null,
      image: json['image']?.toString() ??
          json['thumbnail_img']?.toString() ??
          (json['product'] is Map
              ? (json['product']['thumbnail_img']?.toString() ??
                  json['product']['image']?.toString())
              : null),
    );
  }

  String? get fullImageUrl {
    if (image != null && image!.isNotEmpty) {
      if (image!.startsWith('http://') || image!.startsWith('https://')) {
        return image;
      }
      return '${CompanyData.image_file_url}/$image';
    }
    if (product != null) {
      return product!.imageUrl();
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'shop_id': shopId,
      'product_name': productName,
      'sku': sku,
      'unit_price': unitPrice,
      'qty': qty,
      'line_total': lineTotal,
      'status': status,
      'is_settle_with_seller': isSettleWithSeller,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'order': order?.toJson(),
      'product': product?.toJson(),
      'image': image,
    };
  }
}

class OrderShop {
  final int? id;
  final int? userId;
  final String? name;
  final String? shopName;
  final String? slug;
  final String? code;
  final String? description;
  final String? logo;
  final String? banner;
  final String? phone;
  final String? email;
  final String? address;
  final String? zone;
  final String? district;
  final String? area;
  final double? lat;
  final double? lon;
  final String? status;
  final int? productLimit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderShop({
    this.id,
    this.userId,
    this.name,
    this.shopName,
    this.slug,
    this.code,
    this.description,
    this.logo,
    this.banner,
    this.phone,
    this.email,
    this.address,
    this.zone,
    this.district,
    this.area,
    this.lat,
    this.lon,
    this.status,
    this.productLimit,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderShop.fromJson(Map<String, dynamic> json) {
    return OrderShop(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      name: json['name']?.toString(),
      shopName: json['shop_name']?.toString(),
      slug: json['slug']?.toString(),
      code: json['code']?.toString(),
      description: _cleanText(json['description']),
      logo: json['logo']?.toString(),
      banner: json['banner']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: _cleanText(json['address']),
      zone: json['zone']?.toString(),
      district: json['district']?.toString(),
      area: json['area']?.toString(),
      lat: _toDouble(json['lat']),
      lon: _toDouble(json['lon']),
      status: json['status']?.toString(),
      productLimit: _toInt(json['product_limit']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'shop_name': shopName,
      'slug': slug,
      'code': code,
      'description': description,
      'logo': logo,
      'banner': banner,
      'phone': phone,
      'email': email,
      'address': address,
      'zone': zone,
      'district': district,
      'area': area,
      'lat': lat,
      'lon': lon,
      'status': status,
      'product_limit': productLimit,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class OrderInfo {
  final int? id;
  final int? userId;
  final String? orderNumber;
  final String? paymentGroupId;
  final String? status;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? orderType;
  final String? customerName;
  final String? customerPhone;
  final String? shippingAddress;
  final String? zone;
  final String? district;
  final String? area;
  final double? lat;
  final double? lon;
  final double? subtotal;
  final double? shippingFee;
  final double? discount;
  final double? total;
  final double? paidAmount;
  final double? dueAmount;
  final DateTime? dueDate;
  final String? note;
  final String? platform;
  final int? userAddressId;
  final int? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? shopName;
  final int? shopId;
  final OrderShop? shop;
  final int? totalItemCount;
  final int? totalItems;
  final int? itemsCount;
  final List<ShopOrderItem>? items;
  final OrderUser? user;
  final dynamic userAddress;

  OrderInfo({
    this.id,
    this.userId,
    this.orderNumber,
    this.paymentGroupId,
    this.status,
    this.paymentStatus,
    this.paymentMethod,
    this.orderType,
    this.customerName,
    this.customerPhone,
    this.shippingAddress,
    this.zone,
    this.district,
    this.area,
    this.lat,
    this.lon,
    this.subtotal,
    this.shippingFee,
    this.discount,
    this.total,
    this.paidAmount,
    this.dueAmount,
    this.dueDate,
    this.note,
    this.platform,
    this.userAddressId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.shopName,
    this.shopId,
    this.shop,
    this.totalItemCount,
    this.totalItems,
    this.itemsCount,
    this.items,
    this.user,
    this.userAddress,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      orderNumber: json['order_number']?.toString(),
      paymentGroupId: json['payment_group_id']?.toString(),
      status: json['status']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      orderType: json['order_type']?.toString(),
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      shippingAddress: _cleanText(json['shipping_address']),
      zone: _cleanObjectText(json['zone']),
      district: json['district']?.toString(),
      area: json['area']?.toString(),
      lat: _toDouble(json['lat']),
      lon: _toDouble(json['lon']),
      subtotal: _toDouble(json['subtotal']),
      shippingFee: _toDouble(json['shipping_fee']),
      discount: _toDouble(json['discount']),
      total: _toDouble(json['total']),
      paidAmount: _toDouble(json['paid_amount']),
      dueAmount: _toDouble(json['due_amount']),
      dueDate: _toDateTime(json['due_date']),
      note: _cleanText(json['note']),
      platform: json['platform']?.toString(),
      userAddressId: _toInt(json['user_address_id']),
      isActive: _toInt(json['is_active']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      shopName: json['shop_name']?.toString(),
      shopId: _toInt(json['shop_id']),
      shop: json['shop'] is Map
          ? OrderShop.fromJson(Map<String, dynamic>.from(json['shop'] as Map))
          : null,
      totalItemCount: _toInt(json['total_item_count']),
      totalItems: _toInt(json['total_items']),
      itemsCount: _toInt(json['items_count']),
      items: json['items'] is List
          ? (json['items'] as List)
              .whereType<Map>()
              .map((i) => ShopOrderItem.fromJson(Map<String, dynamic>.from(i)))
              .toList()
          : null,
      user: json['user'] is Map
          ? OrderUser.fromJson(Map<String, dynamic>.from(json['user'] as Map))
          : null,
      userAddress: json['user_address'],
    );
  }

  OrderInfo copyWith({
    int? id,
    int? userId,
    String? orderNumber,
    String? paymentGroupId,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? orderType,
    String? customerName,
    String? customerPhone,
    String? shippingAddress,
    String? zone,
    String? district,
    String? area,
    double? lat,
    double? lon,
    double? subtotal,
    double? shippingFee,
    double? discount,
    double? total,
    double? paidAmount,
    double? dueAmount,
    DateTime? dueDate,
    String? note,
    String? platform,
    int? userAddressId,
    int? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? shopName,
    int? shopId,
    OrderShop? shop,
    int? totalItemCount,
    int? totalItems,
    int? itemsCount,
    List<ShopOrderItem>? items,
    OrderUser? user,
    dynamic userAddress,
  }) {
    return OrderInfo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderNumber: orderNumber ?? this.orderNumber,
      paymentGroupId: paymentGroupId ?? this.paymentGroupId,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      orderType: orderType ?? this.orderType,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      zone: zone ?? this.zone,
      district: district ?? this.district,
      area: area ?? this.area,
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      dueDate: dueDate ?? this.dueDate,
      note: note ?? this.note,
      platform: platform ?? this.platform,
      userAddressId: userAddressId ?? this.userAddressId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      shopName: shopName ?? this.shopName,
      shopId: shopId ?? this.shopId,
      shop: shop ?? this.shop,
      totalItemCount: totalItemCount ?? this.totalItemCount,
      totalItems: totalItems ?? this.totalItems,
      itemsCount: itemsCount ?? this.itemsCount,
      items: items ?? this.items,
      user: user ?? this.user,
      userAddress: userAddress ?? this.userAddress,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'order_number': orderNumber,
      'payment_group_id': paymentGroupId,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'order_type': orderType,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'shipping_address': shippingAddress,
      'zone': zone,
      'district': district,
      'area': area,
      'lat': lat,
      'lon': lon,
      'subtotal': subtotal,
      'shipping_fee': shippingFee,
      'discount': discount,
      'total': total,
      'paid_amount': paidAmount,
      'due_amount': dueAmount,
      'due_date': dueDate?.toIso8601String(),
      'note': note,
      'platform': platform,
      'user_address_id': userAddressId,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'shop_name': shopName,
      'shop_id': shopId,
      'shop': shop?.toJson(),
      'total_item_count': totalItemCount,
      'total_items': totalItems,
      'items_count': itemsCount,
      'items': items?.map((i) => i.toJson()).toList(),
      'user': user?.toJson(),
      'user_address': userAddress,
    };
  }
}

class OrderUser {
  final int? id;
  final dynamic referredBy;
  final String? provider;
  final String? providerId;
  final String? userType;
  final String? name;
  final String? email;
  final DateTime? emailVerifiedAt;
  final String? deviceToken;
  final String? avatar;
  final String? avatarOriginal;
  final String? address;
  final int? divisionId;
  final int? districtId;
  final int? upazilaId;
  final int? areaId;
  final int? zoneId;
  final double? lat;
  final double? lon;
  final String? note;
  final String? country;
  final String? state;
  final String? city;
  final String? postalCode;
  final String? phone;
  final double? balance;
  final int? banned;
  final int? mustBuyPackage;
  final String? referralCode;
  final int? customerPackageId;
  final int? remainingUploads;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderUser({
    this.id,
    this.referredBy,
    this.provider,
    this.providerId,
    this.userType,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.deviceToken,
    this.avatar,
    this.avatarOriginal,
    this.address,
    this.divisionId,
    this.districtId,
    this.upazilaId,
    this.areaId,
    this.zoneId,
    this.lat,
    this.lon,
    this.note,
    this.country,
    this.state,
    this.city,
    this.postalCode,
    this.phone,
    this.balance,
    this.banned,
    this.mustBuyPackage,
    this.referralCode,
    this.customerPackageId,
    this.remainingUploads,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: _toInt(json['id']),
      referredBy: json['referred_by'],
      provider: json['provider']?.toString(),
      providerId: json['provider_id']?.toString(),
      userType: json['user_type']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      emailVerifiedAt: _toDateTime(json['email_verified_at']),
      deviceToken: json['device_token']?.toString(),
      avatar: json['avatar']?.toString(),
      avatarOriginal: json['avatar_original']?.toString(),
      address: _cleanText(json['address']),
      divisionId: _toInt(json['division_id']),
      districtId: _toInt(json['district_id']),
      upazilaId: _toInt(json['upazila_id']),
      areaId: _toInt(json['area_id']),
      zoneId: _toInt(json['zone_id']),
      lat: _toDouble(json['lat']),
      lon: _toDouble(json['lon']),
      note: _cleanText(json['note']),
      country: json['country']?.toString(),
      state: json['state']?.toString(),
      city: json['city']?.toString(),
      postalCode: json['postal_code']?.toString(),
      phone: json['phone']?.toString(),
      balance: _toDouble(json['balance']),
      banned: _toInt(json['banned']),
      mustBuyPackage: _toInt(json['must_buy_package']),
      referralCode: json['referral_code']?.toString(),
      customerPackageId: _toInt(json['customer_package_id']),
      remainingUploads: _toInt(json['remaining_uploads']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referred_by': referredBy,
      'provider': provider,
      'provider_id': providerId,
      'user_type': userType,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'device_token': deviceToken,
      'avatar': avatar,
      'avatar_original': avatarOriginal,
      'address': address,
      'division_id': divisionId,
      'district_id': districtId,
      'upazila_id': upazilaId,
      'area_id': areaId,
      'zone_id': zoneId,
      'lat': lat,
      'lon': lon,
      'note': note,
      'country': country,
      'state': state,
      'city': city,
      'postal_code': postalCode,
      'phone': phone,
      'balance': balance,
      'banned': banned,
      'must_buy_package': mustBuyPackage,
      'referral_code': referralCode,
      'customer_package_id': customerPackageId,
      'remaining_uploads': remainingUploads,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();

  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();

  return double.tryParse(value.toString());
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;

  final String text = value.toString().trim();

  if (text.isEmpty) return null;

  return DateTime.tryParse(text);
}

String? _cleanText(dynamic value) {
  if (value == null) return null;

  final String text = value.toString().trim();

  if (text.isEmpty) return null;

  return text.replaceAll(RegExp(r'\s+'), ' ');
}

String? _cleanObjectText(dynamic value) {
  if (value == null) return null;

  final String text = value.toString().trim();

  if (text.isEmpty || text == '[object Object]') return null;

  return text;
}