// To parse this JSON data, do
//
//     final deliveryModel = deliveryModelFromJson(jsonString);

import 'dart:convert';

DeliveryModel deliveryModelFromJson(String str) => DeliveryModel.fromJson(json.decode(str));

String deliveryModelToJson(DeliveryModel data) => json.encode(data.toJson());

class DeliveryModel {
  String? status;
  String? message;
  DataDelivery? data;

  DeliveryModel({
     this.status,
     this.message,
     this.data,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) => DeliveryModel(
    status: json["status"],
    message: json["message"],
    data: DataDelivery.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data!.toJson(),
  };
}

class DataDelivery {
  int currentPage;
  List<DatumDeOrder> data;
  String firstPageUrl;
  int from;
  int lastPage;
  String lastPageUrl;
  List<Link> links;
  dynamic nextPageUrl;
  String path;
  int perPage;
  dynamic prevPageUrl;
  int to;
  int total;

  DataDelivery({
    required this.currentPage,
    required this.data,
    required this.firstPageUrl,
    required this.from,
    required this.lastPage,
    required this.lastPageUrl,
    required this.links,
    required this.nextPageUrl,
    required this.path,
    required this.perPage,
    required this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory DataDelivery.fromJson(Map<String, dynamic> json) => DataDelivery(
    currentPage: json["current_page"],
    data: List<DatumDeOrder>.from(json["data"].map((x) => DatumDeOrder.fromJson(x))),
    firstPageUrl: json["first_page_url"],
    from: json["from"],
    lastPage: json["last_page"],
    lastPageUrl: json["last_page_url"],
    links: List<Link>.from(json["links"].map((x) => Link.fromJson(x))),
    nextPageUrl: json["next_page_url"],
    path: json["path"],
    perPage: json["per_page"],
    prevPageUrl: json["prev_page_url"],
    to: json["to"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
    "first_page_url": firstPageUrl,
    "from": from,
    "last_page": lastPage,
    "last_page_url": lastPageUrl,
    "links": List<dynamic>.from(links.map((x) => x.toJson())),
    "next_page_url": nextPageUrl,
    "path": path,
    "per_page": perPage,
    "prev_page_url": prevPageUrl,
    "to": to,
    "total": total,
  };
}

class DatumDeOrder {
  int id;
  int deliveryManId;
  int orderId;
  String status;
  dynamic note;
  DateTime createdAt;
  DateTime updatedAt;
  Order order;
  DeliveryMan deliveryMan;

  DatumDeOrder({
    required this.id,
    required this.deliveryManId,
    required this.orderId,
    required this.status,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
    required this.order,
    required this.deliveryMan,
  });

  factory DatumDeOrder.fromJson(Map<String, dynamic> json) => DatumDeOrder(
    id: json["id"],
    deliveryManId: json["delivery_man_id"],
    orderId: json["order_id"],
    status: json["status"],
    note: json["note"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    order: Order.fromJson(json["order"]),
    deliveryMan: DeliveryMan.fromJson(json["delivery_man"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "delivery_man_id": deliveryManId,
    "order_id": orderId,
    "status": status,
    "note": note,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
    "order": order.toJson(),
    "delivery_man": deliveryMan.toJson(),
  };
}

class DeliveryMan {
  int id;
  dynamic referredBy;
  dynamic provider;
  dynamic providerId;
  String userType;
  String name;
  String email;
  DateTime emailVerifiedAt;
  dynamic deviceToken;
  dynamic avatar;
  dynamic avatarOriginal;
  String address;
  String country;
  String state;
  String city;
  dynamic postalCode;
  String phone;
  int balance;
  int banned;
  dynamic referralCode;
  dynamic customerPackageId;
  int remainingUploads;
  DateTime createdAt;
  DateTime updatedAt;

  DeliveryMan({
    required this.id,
    required this.referredBy,
    required this.provider,
    required this.providerId,
    required this.userType,
    required this.name,
    required this.email,
    required this.emailVerifiedAt,
    required this.deviceToken,
    required this.avatar,
    required this.avatarOriginal,
    required this.address,
    required this.country,
    required this.state,
    required this.city,
    required this.postalCode,
    required this.phone,
    required this.balance,
    required this.banned,
    required this.referralCode,
    required this.customerPackageId,
    required this.remainingUploads,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryMan.fromJson(Map<String, dynamic> json) => DeliveryMan(
    id: json["id"],
    referredBy: json["referred_by"],
    provider: json["provider"],
    providerId: json["provider_id"],
    userType: json["user_type"],
    name: json["name"],
    email: json["email"],
    emailVerifiedAt: DateTime.parse(json["email_verified_at"]),
    deviceToken: json["device_token"],
    avatar: json["avatar"],
    avatarOriginal: json["avatar_original"],
    address: json["address"],
    country: json["country"],
    state: json["state"],
    city: json["city"],
    postalCode: json["postal_code"],
    phone: json["phone"],
    balance: json["balance"],
    banned: json["banned"],
    referralCode: json["referral_code"],
    customerPackageId: json["customer_package_id"],
    remainingUploads: json["remaining_uploads"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "referred_by": referredBy,
    "provider": provider,
    "provider_id": providerId,
    "user_type": userType,
    "name": name,
    "email": email,
    "email_verified_at": emailVerifiedAt.toIso8601String(),
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
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class Order {
  int id;
  int userId;
  String orderNumber;
  String status;
  String paymentStatus;
  String customerName;
  String customerPhone;
  String shippingAddress;
  String zone;
  dynamic district;
  dynamic area;
  dynamic lat;
  dynamic lon;
  int subtotal;
  int shippingFee;
  int discount;
  int total;
  String note;
  DateTime createdAt;
  DateTime updatedAt;

  Order({
    required this.id,
    required this.userId,
    required this.orderNumber,
    required this.status,
    required this.paymentStatus,
    required this.customerName,
    required this.customerPhone,
    required this.shippingAddress,
    required this.zone,
    required this.district,
    required this.area,
    required this.lat,
    required this.lon,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    userId: json["user_id"],
    orderNumber: json["order_number"],
    status: json["status"],
    paymentStatus: json["payment_status"],
    customerName: json["customer_name"],
    customerPhone: json["customer_phone"],
    shippingAddress: json["shipping_address"],
    zone: json["zone"],
    district: json["district"],
    area: json["area"],
    lat: json["lat"],
    lon: json["lon"],
    subtotal: json["subtotal"],
    shippingFee: json["shipping_fee"],
    discount: json["discount"],
    total: json["total"],
    note: json["note"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
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
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };
}

class Link {
  String? url;
  String label;
  bool active;

  Link({
    required this.url,
    required this.label,
    required this.active,
  });

  factory Link.fromJson(Map<String, dynamic> json) => Link(
    url: json["url"],
    label: json["label"],
    active: json["active"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
    "label": label,
    "active": active,
  };
}
