/// Models for: GET /customer-preferences-store/customers-by-seller/{sellerId}
///
/// Response shape:
/// SellerPreferredCustomerResponse
///   -> SellerPreferredCustomerPagination (data)
///        -> List<SellerPreferredCustomer> (data.data)
///             -> Customer (data.data[i].customer)

class SellerPreferredCustomerResponse {
  final String status;
  final String message;
  final SellerPreferredCustomerPagination data;

  SellerPreferredCustomerResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SellerPreferredCustomerResponse.fromJson(Map<String, dynamic> json) {
    return SellerPreferredCustomerResponse(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      data: SellerPreferredCustomerPagination.fromJson(
        json['data'] ?? <String, dynamic>{},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class SellerPreferredCustomerPagination {
  final int currentPage;
  final List<SellerPreferredCustomer> data;
  final String? firstPageUrl;
  final int from;
  final int lastPage;
  final String? lastPageUrl;
  final List<PaginationLink> links;
  final String? nextPageUrl;
  final String? path;
  final int perPage;
  final String? prevPageUrl;
  final int to;
  final int total;

  SellerPreferredCustomerPagination({
    required this.currentPage,
    required this.data,
    this.firstPageUrl,
    required this.from,
    required this.lastPage,
    this.lastPageUrl,
    required this.links,
    this.nextPageUrl,
    this.path,
    required this.perPage,
    this.prevPageUrl,
    required this.to,
    required this.total,
  });

  factory SellerPreferredCustomerPagination.fromJson(Map<String, dynamic> json) {
    return SellerPreferredCustomerPagination(
      currentPage: json['current_page'] ?? 0,
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => SellerPreferredCustomer.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 0,
      lastPageUrl: json['last_page_url'],
      links: (json['links'] as List<dynamic>? ?? [])
          .map((e) => PaginationLink.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'] ?? 0,
      prevPageUrl: json['prev_page_url'],
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': data.map((e) => e.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,
      'links': links.map((e) => e.toJson()).toList(),
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
      'total': total,
    };
  }
}

class PaginationLink {
  final String? url;
  final String label;
  final bool active;

  PaginationLink({
    this.url,
    required this.label,
    required this.active,
  });

  factory PaginationLink.fromJson(Map<String, dynamic> json) {
    return PaginationLink(
      url: json['url'],
      label: json['label'] ?? '',
      active: json['active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'label': label,
      'active': active,
    };
  }
}

class SellerPreferredCustomer {
  final int id;
  final int customerUserId;
  final int sellerId;
  final int addedBy;
  final String addedByType;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final Customer customer;

  SellerPreferredCustomer({
    required this.id,
    required this.customerUserId,
    required this.sellerId,
    required this.addedBy,
    required this.addedByType,
    required this.status,
    this.createdAt,
    this.updatedAt,
    required this.customer,
  });

  factory SellerPreferredCustomer.fromJson(Map<String, dynamic> json) {
    return SellerPreferredCustomer(
      id: json['id'] ?? 0,
      customerUserId: json['customer_user_id'] ?? 0,
      sellerId: json['seller_id'] ?? 0,
      addedBy: json['added_by'] ?? 0,
      addedByType: json['added_by_type'] ?? '',
      status: json['status'] ?? '',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      customer: Customer.fromJson(json['customer'] ?? <String, dynamic>{}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_user_id': customerUserId,
      'seller_id': sellerId,
      'added_by': addedBy,
      'added_by_type': addedByType,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'customer': customer.toJson(),
    };
  }
}

class Customer {
  final int id;
  final int? referredBy;
  final String? provider;
  final String? providerId;
  final String userType;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? deviceToken;
  final String? avatar;
  final String? avatarOriginal;
  final String? address;
  final String? country;
  final String? state;
  final String? city;
  final String? postalCode;
  final String? phone;
  final num balance;
  final int banned;
  final String? referralCode;
  final int? customerPackageId;
  final int remainingUploads;
  final int ordersCount;
  final String? createdAt;
  final String? updatedAt;

  Customer({
    required this.id,
    this.referredBy,
    this.provider,
    this.providerId,
    required this.userType,
    required this.name,
    required this.email,
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
    required this.balance,
    required this.banned,
    this.referralCode,
    this.customerPackageId,
    required this.remainingUploads,
    required this.ordersCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      referredBy: json['referred_by'],
      provider: json['provider'],
      providerId: json['provider_id']?.toString(),
      userType: json['user_type'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      deviceToken: json['device_token'],
      avatar: json['avatar'],
      avatarOriginal: json['avatar_original'],
      address: json['address'],
      country: json['country'],
      state: json['state'],
      city: json['city'],
      postalCode: json['postal_code'],
      phone: json['phone'],
      balance: json['balance'] ?? 0,
      banned: json['banned'] ?? 0,
      referralCode: json['referral_code'],
      customerPackageId: json['customer_package_id'],
      remainingUploads: json['remaining_uploads'] ?? 0,
      ordersCount: _toInt(json['orders_count'] ?? json['order_count']),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
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
      'email_verified_at': emailVerifiedAt,
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
      'orders_count': ordersCount,
      'order_count': ordersCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? 0;
}

class SellerCustomerOrderPage {
  const SellerCustomerOrderPage({
    required this.orders,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  final List<SellerCustomerOrder> orders;
  final int currentPage;
  final int lastPage;
  final int total;

  bool get hasMore => currentPage < lastPage;

  factory SellerCustomerOrderPage.fromJson(Map<String, dynamic> json) {
    final items = json['data'] is List ? json['data'] as List : <dynamic>[];
    return SellerCustomerOrderPage(
      orders: items
          .whereType<Map>()
          .map((item) => SellerCustomerOrder.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(),
      currentPage: _toInt(json['current_page']),
      lastPage: _toInt(json['last_page']),
      total: _toInt(json['total']),
    );
  }
}

class SellerCustomerOrder {
  const SellerCustomerOrder({
    required this.id,
    this.orderNumber,
    this.status,
    this.paymentStatus,
    this.total,
    this.createdAt,
  });

  final int id;
  final String? orderNumber;
  final String? status;
  final String? paymentStatus;
  final num? total;
  final String? createdAt;

  factory SellerCustomerOrder.fromJson(Map<String, dynamic> json) {
    return SellerCustomerOrder(
      id: _toInt(json['id']),
      orderNumber: json['order_number']?.toString(),
      status: json['status']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      total: json['total'] is num
          ? json['total'] as num
          : num.tryParse(json['total']?.toString() ?? ''),
      createdAt: json['created_at']?.toString(),
    );
  }
}
