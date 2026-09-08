class SellerCustomer {
  const SellerCustomer({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.address,
    this.status,
  });

  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? address;
  final String? status;

  factory SellerCustomer.fromJson(Map<String, dynamic> json) {
    return SellerCustomer(
      id: _toInt(json['id'] ?? json['customer_user_id']),
      name: _firstString(json, const ['name', 'customer_name', 'full_name']),
      phone: _firstString(json, const ['phone', 'mobile', 'customer_phone']),
      email: _firstString(json, const ['email', 'customer_email']),
      address: _firstString(json, const ['address', 'customer_address']),
      status: json['status']?.toString(),
    );
  }
}

class SellerCustomerAddResult {
  const SellerCustomerAddResult({
    this.message,
    this.customer,
  });

  final String? message;
  final SellerCustomer? customer;

  factory SellerCustomerAddResult.fromJson(Map<String, dynamic> json) {
    final data = _asMap(json['data']);
    final customerMap = _asMap(data?['customer'] ?? json['customer']);

    return SellerCustomerAddResult(
      message: json['message']?.toString(),
      customer: customerMap == null ? null : SellerCustomer.fromJson(customerMap),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String? _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value != null && value.toString().trim().isNotEmpty) {
      return value.toString().trim();
    }
  }
  return null;
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
