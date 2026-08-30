class SubscriptionPackage {
  final int? id;
  final String name;
  final String shortDescription;
  final double? price;
  final String billingCycle;
  final int? trialDays;
  final int? maxProducts;
  final int? maxOrdersPerMonth;
  final int? maxStaff;
  final int? maxBranches;
  final double? commissionRate;
  final List<String> features;
  final bool isPopular;
  final bool isFeatured;

  SubscriptionPackage({
    this.id,
    required this.name,
    required this.shortDescription,
    this.price,
    required this.billingCycle,
    this.trialDays,
    this.maxProducts,
    this.maxOrdersPerMonth,
    this.maxStaff,
    this.maxBranches,
    this.commissionRate,
    required this.features,
    required this.isPopular,
    required this.isFeatured,
  });

  factory SubscriptionPackage.fromJson(Map<String, dynamic> json) {
    return SubscriptionPackage(
      id: _toInt(json['id']),
      name: _text(json['name']) ?? 'Subscription Package',
      shortDescription: _text(json['short_description']) ?? '',
      price: _toDouble(json['price']),
      billingCycle: _text(json['billing_cycle']) ?? 'monthly',
      trialDays: _toInt(json['trial_days']),
      maxProducts: _toInt(json['max_products']),
      maxOrdersPerMonth: _toInt(json['max_orders_per_month']),
      maxStaff: _toInt(json['max_staff']),
      maxBranches: _toInt(json['max_branches']),
      commissionRate: _toDouble(json['commission_rate']),
      features: _features(json['features']),
      isPopular: _toBool(json['is_popular']),
      isFeatured: _toBool(json['is_featured']),
    );
  }

  String get priceText {
    final amount = price ?? 0;
    if (amount == 0) return 'Free';

    final hasDecimal = amount % 1 != 0;
    return '৳${hasDecimal ? amount.toStringAsFixed(2) : amount.toStringAsFixed(0)}';
  }

  String get billingCycleText {
    if (billingCycle.trim().isEmpty) return 'monthly';
    return billingCycle.trim();
  }
}

class StoreSubscription {
  final int? id;
  final int? subscriptionPackageId;
  final String packageName;
  final String status;
  final String? expiresAt;
  final String? renewsAt;
  final int? maxProducts;
  final int? maxOrdersPerMonth;

  StoreSubscription({
    this.id,
    this.subscriptionPackageId,
    required this.packageName,
    required this.status,
    this.expiresAt,
    this.renewsAt,
    this.maxProducts,
    this.maxOrdersPerMonth,
  });

  factory StoreSubscription.fromJson(Map<String, dynamic> json) {
    final package = _nestedMap(json['package']) ??
        _nestedMap(json['subscription_package']) ??
        _nestedMap(json['plan']);

    return StoreSubscription(
      id: _toInt(json['id']),
      subscriptionPackageId: _toInt(json['subscription_package_id']) ??
          _toInt(json['package_id']) ??
          _toInt(package?['id']),
      packageName: _text(json['package_name']) ??
          _text(json['name']) ??
          _text(package?['name']) ??
          'No active package',
      status: _text(json['status']) ?? 'inactive',
      expiresAt: _text(json['expires_at']) ??
          _text(json['expired_at']) ??
          _text(json['end_date']),
      renewsAt: _text(json['renews_at']) ??
          _text(json['renewal_date']) ??
          _text(json['next_billing_at']),
      maxProducts:
          _toInt(json['max_products']) ?? _toInt(package?['max_products']),
      maxOrdersPerMonth: _toInt(json['max_orders_per_month']) ??
          _toInt(package?['max_orders_per_month']),
    );
  }

  bool get isActive => status.toLowerCase() == 'active';

  String get displayDate => renewsAt ?? expiresAt ?? '';
}

Map<String, dynamic>? _nestedMap(dynamic value) {
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

String? _text(dynamic value) {
  if (value == null) return null;

  final text = value.toString().trim();
  if (text.isEmpty || text.toLowerCase() == 'null') return null;

  return text;
}

List<String> _features(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).where((item) {
      return item.trim().isNotEmpty;
    }).toList();
  }

  final text = _text(value);
  if (text == null) return [];

  return text
      .split(RegExp(r'[\n,]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
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

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value == 1;

  final text = value?.toString().toLowerCase().trim();
  return text == '1' || text == 'true' || text == 'yes';
}
