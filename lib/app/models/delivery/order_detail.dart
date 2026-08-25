// To parse this JSON data, do
//
// final orderDetailsModel = orderDetailsModelFromJson(jsonString);

import 'dart:convert';

OrderDetailsModel orderDetailsModelFromJson(String str) =>
    OrderDetailsModel.fromJson(json.decode(str) as Map<String, dynamic>);

String orderDetailsModelToJson(OrderDetailsModel data) =>
    json.encode(data.toJson());

class OrderDetailsModel {
  final String? status;
  final String? message;
  final OrderDetailsData? data;

  const OrderDetailsModel({
    this.status,
    this.message,
    this.data,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailsModel(
        status: json["status"] as String?,
        message: json["message"] as String?,
        data: json["data"] == null
            ? null
            : OrderDetailsData.fromJson(json["data"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class OrderDetailsData {
  final int? id;
  final int? userId;
  final String? orderNumber;
  final String? status;
  final String? paymentStatus;
  final String? customerName;
  final String? customerPhone;
  final String? shippingAddress;
  final String? zone;
  final dynamic district;
  final dynamic area;
  final dynamic lat;
  final dynamic lon;
  final int? subtotal;
  final int? shippingFee;
  final int? discount;
  final int? total;
  final String? note;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final List<OrderItem> items;
  final AssignedDeliveryManWrapper? deliveryMan;

  const OrderDetailsData({
    this.id,
    this.userId,
    this.orderNumber,
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
    this.createdAt,
    this.updatedAt,
    required this.items,
    this.deliveryMan,
  });

  factory OrderDetailsData.fromJson(Map<String, dynamic> json) =>
      OrderDetailsData(
        id: _asInt(json["id"]),
        userId: _asInt(json["user_id"]),
        orderNumber: json["order_number"] as String?,
        status: json["status"] as String?,
        paymentStatus: json["payment_status"] as String?,
        customerName: json["customer_name"] as String?,
        customerPhone: json["customer_phone"] as String?,
        shippingAddress: json["shipping_address"] as String?,
        zone: json["zone"] as String?,
        district: json["district"],
        area: json["area"],
        lat: json["lat"],
        lon: json["lon"],
        subtotal: _asInt(json["subtotal"]),
        shippingFee: _asInt(json["shipping_fee"]),
        discount: _asInt(json["discount"]),
        total: _asInt(json["total"]),
        note: json["note"] as String?,
        createdAt: _asDate(json["created_at"]),
        updatedAt: _asDate(json["updated_at"]),
        items: (json["items"] is List)
            ? (json["items"] as List)
            .map((x) => OrderItem.fromJson(x as Map<String, dynamic>))
            .toList()
            : <OrderItem>[],
        deliveryMan: json["delivery_man"] == null
            ? null
            : AssignedDeliveryManWrapper.fromJson(
          json["delivery_man"] as Map<String, dynamic>,
        ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "order_number": orderNumber,
    "status": status,
    "payment_status": paymentStatus,
    "customer_name": customerName,
    "customer_phone": customerPhone,
    "shipping_address": shippingAddress,
    "zone": zone,
    "district": district,
    "area": area,
    "lat": lat,
    "lon": lon,
    "subtotal": subtotal,
    "shipping_fee": shippingFee,
    "discount": discount,
    "total": total,
    "note": note,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "items": items.map((x) => x.toJson()).toList(),
    "delivery_man": deliveryMan?.toJson(),
  };
}

class OrderItem {
  final int? id;
  final int? orderId;
  final int? productId;
  final dynamic shopId;
  final String? productName;
  final dynamic sku;
  final int? unitPrice;
  final int? qty;
  final int? lineTotal;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OrderItem({
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
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: _asInt(json["id"]),
    orderId: _asInt(json["order_id"]),
    productId: _asInt(json["product_id"]),
    shopId: json["shop_id"],
    productName: json["product_name"] as String?,
    sku: json["sku"],
    unitPrice: _asInt(json["unit_price"]),
    qty: _asInt(json["qty"]),
    lineTotal: _asInt(json["line_total"]),
    status: json["status"] as String?,
    createdAt: _asDate(json["created_at"]),
    updatedAt: _asDate(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_id": orderId,
    "product_id": productId,
    "shop_id": shopId,
    "product_name": productName,
    "sku": sku,
    "unit_price": unitPrice,
    "qty": qty,
    "line_total": lineTotal,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

/// delivery_man wrapper in your JSON:
/// "delivery_man": { id, delivery_man_id, order_id, status, note, created_at, updated_at, delivery_man: { ...profile... } }
class AssignedDeliveryManWrapper {
  final int? id;
  final int? deliveryManId;
  final int? orderId;
  final String? status;
  final dynamic note;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DeliveryManProfile? deliveryMan;

  const AssignedDeliveryManWrapper({
    this.id,
    this.deliveryManId,
    this.orderId,
    this.status,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.deliveryMan,
  });

  factory AssignedDeliveryManWrapper.fromJson(Map<String, dynamic> json) =>
      AssignedDeliveryManWrapper(
        id: _asInt(json["id"]),
        deliveryManId: _asInt(json["delivery_man_id"]),
        orderId: _asInt(json["order_id"]),
        status: json["status"] as String?,
        note: json["note"],
        createdAt: _asDate(json["created_at"]),
        updatedAt: _asDate(json["updated_at"]),
        deliveryMan: json["delivery_man"] == null
            ? null
            : DeliveryManProfile.fromJson(
          json["delivery_man"] as Map<String, dynamic>,
        ),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "delivery_man_id": deliveryManId,
    "order_id": orderId,
    "status": status,
    "note": note,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "delivery_man": deliveryMan?.toJson(),
  };
}

/// Reuse your ProfileData structure but named clearly here
class DeliveryManProfile {
  final int? id;
  final dynamic referredBy;
  final dynamic provider;
  final dynamic providerId;
  final String? userType;
  final String? name;
  final String? email;
  final DateTime? emailVerifiedAt;
  final dynamic deviceToken;
  final dynamic avatar;
  final dynamic avatarOriginal;
  final String? address;
  final String? country;
  final String? state;
  final String? city;
  final dynamic postalCode;
  final String? phone;
  final int? balance;
  final int? banned;
  final dynamic referralCode;
  final dynamic customerPackageId;
  final int? remainingUploads;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DeliveryManProfile({
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

  factory DeliveryManProfile.fromJson(Map<String, dynamic> json) =>
      DeliveryManProfile(
        id: _asInt(json["id"]),
        referredBy: json["referred_by"],
        provider: json["provider"],
        providerId: json["provider_id"],
        userType: json["user_type"] as String?,
        name: json["name"] as String?,
        email: json["email"] as String?,
        emailVerifiedAt: _asDate(json["email_verified_at"]),
        deviceToken: json["device_token"],
        avatar: json["avatar"],
        avatarOriginal: json["avatar_original"],
        address: json["address"] as String?,
        country: json["country"] as String?,
        state: json["state"] as String?,
        city: json["city"] as String?,
        postalCode: json["postal_code"],
        phone: json["phone"] as String?,
        balance: _asInt(json["balance"]),
        banned: _asInt(json["banned"]),
        referralCode: json["referral_code"],
        customerPackageId: json["customer_package_id"],
        remainingUploads: _asInt(json["remaining_uploads"]),
        createdAt: _asDate(json["created_at"]),
        updatedAt: _asDate(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "referred_by": referredBy,
    "provider": provider,
    "provider_id": providerId,
    "user_type": userType,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt?.toIso8601String(),
    "device_token": deviceToken,
    "avatar": avatar,
    "avatar_original": avatarOriginal,
    "address": address,
    "country": country,
    "state": state,
    "city": city,
    "postal_code": postalCode,
    "phone": phone,
    "balance": balance,
    "banned": banned,
    "referral_code": referralCode,
    "customer_package_id": customerPackageId,
    "remaining_uploads": remainingUploads,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

/// Helpers

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) return DateTime.tryParse(v);
  return null;
}
