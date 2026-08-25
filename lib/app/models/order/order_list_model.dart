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
          : null,
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
    return ShopOrderPagination(
      currentPage: _toInt(json['current_page']),
      orders: json['data'] is List
          ? (json['data'] as List)
          .whereType<Map>()
          .map((e) => ShopOrderItem.fromJson(Map<String, dynamic>.from(e)))
          .toList()
          : [],
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
      'data': orders.map((e) => e.toJson()).toList(),
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

    if (rawData is Map<String, dynamic>) {
      final bool looksLikeShopItem =
          rawData.containsKey('order_id') || rawData.containsKey('product_name');

      final bool looksLikeOrder =
          rawData.containsKey('order_number') || rawData.containsKey('customer_name');

      if (looksLikeShopItem) {
        parsedItem = ShopOrderItem.fromJson(rawData);
        parsedOrder = parsedItem.order;
      } else if (rawData['order'] is Map<String, dynamic>) {
        parsedItem = ShopOrderItem.fromJson(rawData);
        parsedOrder = OrderInfo.fromJson(Map<String, dynamic>.from(rawData['order']));
      } else if (looksLikeOrder) {
        parsedOrder = OrderInfo.fromJson(rawData);
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
  });

  factory ShopOrderItem.fromJson(Map<String, dynamic> json) {
    return ShopOrderItem(
      id: _toInt(json['id']),
      orderId: _toInt(json['order_id']),
      productId: _toInt(json['product_id']),
      shopId: _toInt(json['shop_id']),
      productName: json['product_name']?.toString(),
      sku: json['sku']?.toString(),
      unitPrice: _toDouble(json['unit_price']),
      qty: _toInt(json['qty']),
      lineTotal: _toDouble(json['line_total']),
      status: json['status']?.toString(),
      isSettleWithSeller: _toInt(json['is_settle_with_seller']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      order: json['order'] is Map<String, dynamic>
          ? OrderInfo.fromJson(Map<String, dynamic>.from(json['order']))
          : null,
    );
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
  final String? note;
  final String? platform;
  final int? userAddressId;
  final int? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final OrderUser? user;

  OrderInfo({
    this.id,
    this.userId,
    this.orderNumber,
    this.paymentGroupId,
    this.status,
    this.paymentStatus,
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
    this.note,
    this.platform,
    this.userAddressId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  factory OrderInfo.fromJson(Map<String, dynamic> json) {
    return OrderInfo(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      orderNumber: json['order_number']?.toString(),
      paymentGroupId: json['payment_group_id']?.toString(),
      status: json['status']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
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
      note: _cleanText(json['note']),
      platform: json['platform']?.toString(),
      userAddressId: _toInt(json['user_address_id']),
      isActive: _toInt(json['is_active']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      user: json['user'] is Map<String, dynamic>
          ? OrderUser.fromJson(Map<String, dynamic>.from(json['user']))
          : null,
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
      'note': note,
      'platform': platform,
      'user_address_id': userAddressId,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'user': user?.toJson(),
    };
  }
}

class OrderUser {
  final int? id;
  final String? userType;
  final String? name;
  final String? email;
  final DateTime? emailVerifiedAt;
  final String? deviceToken;
  final String? avatar;
  final String? avatarOriginal;
  final String? address;
  final String? country;
  final String? state;
  final String? city;
  final String? postalCode;
  final String? phone;
  final double? balance;
  final int? banned;
  final String? referralCode;
  final int? customerPackageId;
  final int? remainingUploads;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderUser({
    this.id,
    this.userType,
    this.name,
    this.email,
    this.emailVerifiedAt,
    this.deviceToken,
    this.avatar,
    this.avatarOriginal,
    this.address,
    this.country,
    this.state,
    this.city,
    this.postalCode,
    this.phone,
    this.balance,
    this.banned,
    this.referralCode,
    this.customerPackageId,
    this.remainingUploads,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderUser.fromJson(Map<String, dynamic> json) {
    return OrderUser(
      id: _toInt(json['id']),
      userType: json['user_type']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      emailVerifiedAt: _toDateTime(json['email_verified_at']),
      deviceToken: json['device_token']?.toString(),
      avatar: json['avatar']?.toString(),
      avatarOriginal: json['avatar_original']?.toString(),
      address: _cleanText(json['address']),
      country: json['country']?.toString(),
      state: json['state']?.toString(),
      city: json['city']?.toString(),
      postalCode: json['postal_code']?.toString(),
      phone: json['phone']?.toString(),
      balance: _toDouble(json['balance']),
      banned: _toInt(json['banned']),
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
      'user_type': userType,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'device_token': deviceToken,
      'avatar': avatar,
      'avatar_original': avatarOriginal,
      'address': address,
      'country': country,
      'state': state,
      'city': city,
      'postal_code': postalCode,
      'phone': phone,
      'balance': balance,
      'banned': banned,
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