// To parse this JSON data, do
//
//     final profileModel = profileModelFromJson(jsonString);

import 'dart:convert';

ProfileModel profileModelFromJson(String str) =>
    ProfileModel.fromJson(json.decode(str) as Map<String, dynamic>);

String profileModelToJson(ProfileModel data) => json.encode(data.toJson());

class ProfileModel {
  final String? status;
  final String? message;
  final ProfileData? data;

  const ProfileModel({
    this.status,
    this.message,
    this.data,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    status: json["status"] as String?,
    message: json["message"] as String?,
    data: json["data"] == null
        ? null
        : ProfileData.fromJson(json["data"] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class ProfileData {
  final int? id;
  final dynamic referredBy;
  final dynamic provider;
  final dynamic providerId;
  final String? userType;
  final String? name;
  final String? email;

  // Make nullable, because backend often returns null
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

  // Also nullable
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SellerShop? shop;

  const ProfileData({
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
    this.shop,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
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
    shop: json["shop"] is Map<String, dynamic>
        ? SellerShop.fromJson(json["shop"] as Map<String, dynamic>)
        : null,
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
    "shop": shop?.toJson(),
  };
}

class SellerShopFile {
  final int? id;
  final String? fileOriginalName;
  final String? fileName;
  final int? userId;
  final int? sellerId;
  final int? fileSize;
  final String? extension;
  final String? type;
  final String? externalLink;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? url;

  SellerShopFile({
    this.id,
    this.fileOriginalName,
    this.fileName,
    this.userId,
    this.sellerId,
    this.fileSize,
    this.extension,
    this.type,
    this.externalLink,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.url,
  });

  factory SellerShopFile.fromJson(Map<String, dynamic> json) => SellerShopFile(
    id: _asInt(json['id']),
    fileOriginalName: json['file_original_name'] as String?,
    fileName: json['file_name'] as String?,
    userId: _asInt(json['user_id']),
    sellerId: _asInt(json['seller_id']),
    fileSize: _asInt(json['file_size']),
    extension: json['extension'] as String?,
    type: json['type'] as String?,
    externalLink: json['external_link'] as String?,
    createdAt: _asDate(json['created_at']),
    updatedAt: _asDate(json['updated_at']),
    deletedAt: _asDate(json['deleted_at']),
    url: json['url'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'file_original_name': fileOriginalName,
    'file_name': fileName,
    'user_id': userId,
    'seller_id': sellerId,
    'file_size': fileSize,
    'extension': extension,
    'type': type,
    'external_link': externalLink,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'url': url,
  };
}

class SellerShop {
  final int? id;
  final int? userId;
  final String? name;
  final String? shopName;
  final String? slug;
  final String? code;
  final String? description;
  final SellerShopFile? logo;
  final SellerShopFile? banner;
  final String? phone;
  final String? email;
  final String? address;
  final dynamic zone;
  final dynamic district;
  final dynamic area;
  final dynamic lat;
  final dynamic lon;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SellerShopPackage? package;

  SellerShop({
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
    this.createdAt,
    this.updatedAt,
    this.package,
  });

  factory SellerShop.fromJson(Map<String, dynamic> json) => SellerShop(
    id: _asInt(json['id']),
    userId: _asInt(json['user_id']),
    name: json['name'] as String?,
    shopName: json['shop_name'] as String?,
    slug: json['slug'] as String?,
    code: json['code'] as String?,
    description: json['description'] as String?,
    logo: json['logo'] is Map<String, dynamic>
        ? SellerShopFile.fromJson(json['logo'] as Map<String, dynamic>)
        : null,
    banner: json['banner'] is Map<String, dynamic>
        ? SellerShopFile.fromJson(json['banner'] as Map<String, dynamic>)
        : null,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    address: json['address'] as String?,
    zone: json['zone'],
    district: json['district'],
    area: json['area'],
    lat: json['lat'],
    lon: json['lon'],
    status: json['status'] as String?,
    createdAt: _asDate(json['created_at']),
    updatedAt: _asDate(json['updated_at']),
    package: json['package'] is Map<String, dynamic>
        ? SellerShopPackage.fromJson(json['package'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'name': name,
    'shop_name': shopName,
    'slug': slug,
    'code': code,
    'description': description,
    'logo': logo?.toJson(),
    'banner': banner?.toJson(),
    'phone': phone,
    'email': email,
    'address': address,
    'zone': zone,
    'district': district,
    'area': area,
    'lat': lat,
    'lon': lon,
    'status': status,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'package': package?.toJson(),
  };
}

class SellerShopPackage {
  final int? id;
  final int? storeId;
  final int? subscriptionPackageId;
  final String? status;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? trialEndsAt;
  final int? price;
  final String? currency;
  final String? billingCycle;
  final String? paymentStatus;
  final dynamic paymentReference;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final SubscriptionPackageDetails? package;

  SellerShopPackage({
    this.id,
    this.storeId,
    this.subscriptionPackageId,
    this.status,
    this.startsAt,
    this.endsAt,
    this.trialEndsAt,
    this.price,
    this.currency,
    this.billingCycle,
    this.paymentStatus,
    this.paymentReference,
    this.createdAt,
    this.updatedAt,
    this.package,
  });

  factory SellerShopPackage.fromJson(Map<String, dynamic> json) => SellerShopPackage(
    id: _asInt(json['id']),
    storeId: _asInt(json['store_id']),
    subscriptionPackageId: _asInt(json['subscription_package_id']),
    status: json['status'] as String?,
    startsAt: _asDate(json['starts_at']),
    endsAt: _asDate(json['ends_at']),
    trialEndsAt: _asDate(json['trial_ends_at']),
    price: _asInt(json['price']),
    currency: json['currency'] as String?,
    billingCycle: json['billing_cycle'] as String?,
    paymentStatus: json['payment_status'] as String?,
    paymentReference: json['payment_reference'],
    createdAt: _asDate(json['created_at']),
    updatedAt: _asDate(json['updated_at']),
    package: json['package'] is Map<String, dynamic>
        ? SubscriptionPackageDetails.fromJson(json['package'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'store_id': storeId,
    'subscription_package_id': subscriptionPackageId,
    'status': status,
    'starts_at': startsAt?.toIso8601String(),
    'ends_at': endsAt?.toIso8601String(),
    'trial_ends_at': trialEndsAt?.toIso8601String(),
    'price': price,
    'currency': currency,
    'billing_cycle': billingCycle,
    'payment_status': paymentStatus,
    'payment_reference': paymentReference,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'package': package?.toJson(),
  };
}

class SubscriptionPackageDetails {
  final int? id;
  final String? name;
  final String? slug;
  final String? shortDescription;
  final String? description;
  final int? price;
  final String? currency;
  final String? billingCycle;
  final int? trialDays;
  final int? maxProducts;
  final int? maxOrdersPerMonth;
  final int? maxStaff;
  final int? maxBranches;
  final int? commissionRate;
  final bool? isFeatured;
  final bool? isPopular;
  final String? status;
  final int? sortOrder;
  final List<String>? features;
  final List<dynamic>? metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubscriptionPackageDetails({
    this.id,
    this.name,
    this.slug,
    this.shortDescription,
    this.description,
    this.price,
    this.currency,
    this.billingCycle,
    this.trialDays,
    this.maxProducts,
    this.maxOrdersPerMonth,
    this.maxStaff,
    this.maxBranches,
    this.commissionRate,
    this.isFeatured,
    this.isPopular,
    this.status,
    this.sortOrder,
    this.features,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory SubscriptionPackageDetails.fromJson(Map<String, dynamic> json) =>
      SubscriptionPackageDetails(
        id: _asInt(json['id']),
        name: json['name'] as String?,
        slug: json['slug'] as String?,
        shortDescription: json['short_description'] as String?,
        description: json['description'] as String?,
        price: _asInt(json['price']),
        currency: json['currency'] as String?,
        billingCycle: json['billing_cycle'] as String?,
        trialDays: _asInt(json['trial_days']),
        maxProducts: _asInt(json['max_products']),
        maxOrdersPerMonth: _asInt(json['max_orders_per_month']),
        maxStaff: _asInt(json['max_staff']),
        maxBranches: _asInt(json['max_branches']),
        commissionRate: _asInt(json['commission_rate']),
        isFeatured: json['is_featured'] == true || json['is_featured'] == '1',
        isPopular: json['is_popular'] == true || json['is_popular'] == '1',
        status: json['status'] as String?,
        sortOrder: _asInt(json['sort_order']),
        features: (json['features'] as List?)
            ?.whereType<String>()
            .toList() ?? const [],
        metadata: json['metadata'] is List ? List<dynamic>.from(json['metadata']) : const [],
        createdAt: _asDate(json['created_at']),
        updatedAt: _asDate(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'short_description': shortDescription,
    'description': description,
    'price': price,
    'currency': currency,
    'billing_cycle': billingCycle,
    'trial_days': trialDays,
    'max_products': maxProducts,
    'max_orders_per_month': maxOrdersPerMonth,
    'max_staff': maxStaff,
    'max_branches': maxBranches,
    'commission_rate': commissionRate,
    'is_featured': isFeatured,
    'is_popular': isPopular,
    'status': status,
    'sort_order': sortOrder,
    'features': features,
    'metadata': metadata,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}

/// Helpers (defensive parsing)

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
