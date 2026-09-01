class LoginResponseModel {
  final String? status;
  final String? message;
  final LoginData? data;

  LoginResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? LoginData.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }

  bool get isSuccess => status?.toLowerCase() == 'success';
}

class LoginData {
  final String? token;
  final String? tokenType;
  final DateTime? expiresAt;
  final int? tokenId;
  final LoginUser? user;

  LoginData({
    this.token,
    this.tokenType,
    this.expiresAt,
    this.tokenId,
    this.user,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      token: json['token']?.toString(),
      tokenType: json['token_type']?.toString(),
      expiresAt: _toDateTime(json['expires_at']),
      tokenId: _toInt(json['token_id']),
      user: json['user'] is Map<String, dynamic>
          ? LoginUser.fromJson(Map<String, dynamic>.from(json['user']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'token_type': tokenType,
      'expires_at': expiresAt?.toIso8601String(),
      'token_id': tokenId,
      'user': user?.toJson(),
    };
  }
}

class LoginUser {
  final int? id;
  final int? referredBy;
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
  final LoginShop? shop;

  LoginUser({
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

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      id: _toInt(json['id']),
      referredBy: _toInt(json['referred_by']),
      provider: json['provider']?.toString(),
      providerId: json['provider_id']?.toString(),
      userType: json['user_type']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      emailVerifiedAt: _toDateTime(json['email_verified_at']),
      deviceToken: json['device_token']?.toString(),
      avatar: json['avatar']?.toString(),
      avatarOriginal: json['avatar_original']?.toString(),
      address: json['address']?.toString(),
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
      shop: json['shop'] is Map<String, dynamic>
          ? LoginShop.fromJson(Map<String, dynamic>.from(json['shop']))
          : null,
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
      'shop': shop?.toJson(),
    };
  }
}

class LoginShop {
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
  final dynamic zone;
  final dynamic district;
  final dynamic area;
  final dynamic lat;
  final dynamic lon;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LoginShop({
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
  });

  factory LoginShop.fromJson(Map<String, dynamic> json) {
    return LoginShop(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id']),
      name: json['name']?.toString(),
      shopName: json['shop_name']?.toString(),
      slug: json['slug']?.toString(),
      code: json['code']?.toString(),
      description: json['description']?.toString(),
      logo: json['logo']?.toString(),
      banner: json['banner']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      zone: json['zone'],
      district: json['district'],
      area: json['area'],
      lat: json['lat'],
      lon: json['lon'],
      status: json['status']?.toString(),
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
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();

  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();

  return double.tryParse(value.toString());
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;

  final String dateText = value.toString().trim();

  if (dateText.isEmpty) return null;

  return DateTime.tryParse(dateText);
}