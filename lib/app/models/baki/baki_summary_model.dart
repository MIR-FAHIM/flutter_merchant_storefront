import 'package:ecom_delivery_flutter/app/models/baki/customer_ledger_model.dart';

class BakiSummaryResponse {
  final String? status;
  final String? message;
  final BakiSummaryData? data;

  BakiSummaryResponse({
    this.status,
    this.message,
    this.data,
  });

  factory BakiSummaryResponse.fromJson(Map<String, dynamic> json) {
    return BakiSummaryResponse(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? BakiSummaryData.fromJson(json['data'] as Map<String, dynamic>)
          : (json['data'] is Map
              ? BakiSummaryData.fromJson(Map<String, dynamic>.from(json['data']))
              : null),
    );
  }
}

class BakiSummaryData {
  final double totalStoreBaki;
  final int totalCustomersWithBaki;
  final List<BakiCustomerItem> customers;
  final List<LedgerItem> recentLedgerEntries;

  BakiSummaryData({
    required this.totalStoreBaki,
    required this.totalCustomersWithBaki,
    required this.customers,
    this.recentLedgerEntries = const [],
  });

  factory BakiSummaryData.fromJson(Map<String, dynamic> json) {
    // 1. Customers list (supports 'customers_list', 'customers', 'customers_with_baki')
    var rawCustomers =
        json['customers_list'] ?? json['customers'] ?? json['customers_with_baki'];
    List<BakiCustomerItem> customerList = [];
    if (rawCustomers is List) {
      customerList = rawCustomers
          .whereType<Map>()
          .map((item) => BakiCustomerItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } else if (rawCustomers is Map) {
      final mapData = rawCustomers['data'];
      if (mapData is List) {
        customerList = mapData
            .whereType<Map>()
            .map((item) => BakiCustomerItem.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    }

    // 2. Recent ledger entries (supports 'recent_ledger_entries', 'recent_ledgers', 'ledgers')
    var rawLedgers =
        json['recent_ledger_entries'] ?? json['recent_ledgers'] ?? json['ledgers'];
    List<LedgerItem> ledgerList = [];
    if (rawLedgers is List) {
      ledgerList = rawLedgers
          .whereType<Map>()
          .map((item) => LedgerItem.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    // 3. Total store baki (supports 'total_outstanding_baki', 'total_store_baki', 'total_baki', 'total_due')
    final totalBaki = _toDouble(
      json['total_outstanding_baki'] ??
          json['total_store_baki'] ??
          json['total_baki'] ??
          json['total_due'],
    );

    // 4. Customers count (supports 'customers_with_baki_count', 'total_customers_with_baki', 'customers_count')
    int count = _toInt(
      json['customers_with_baki_count'] ??
          json['total_customers_with_baki'] ??
          json['customers_count'],
    );
    if (count == 0 && customerList.isNotEmpty) {
      count = customerList.length;
    }

    return BakiSummaryData(
      totalStoreBaki: totalBaki,
      totalCustomersWithBaki: count,
      customers: customerList,
      recentLedgerEntries: ledgerList,
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }
}

class BakiCustomerItem {
  final int? customerId;
  final String? name;
  final String? phone;
  final String? email;
  final double totalBaki;
  final String? updatedAt;

  BakiCustomerItem({
    this.customerId,
    this.name,
    this.phone,
    this.email,
    required this.totalBaki,
    this.updatedAt,
  });

  factory BakiCustomerItem.fromJson(Map<String, dynamic> json) {
    final rawCustId = json['customer_id'] ?? json['id'] ?? json['user_id'];
    final id = rawCustId is num
        ? rawCustId.toInt()
        : int.tryParse(rawCustId?.toString() ?? '');

    return BakiCustomerItem(
      customerId: id,
      name: json['name']?.toString() ?? json['customer_name']?.toString(),
      phone: json['phone']?.toString() ?? json['customer_phone']?.toString(),
      email: json['email']?.toString(),
      totalBaki: _toDouble(
        json['total_baki'] ??
            json['due_amount'] ??
            json['total_due'] ??
            json['amount'],
      ),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  BakiCustomerItem copyWith({
    int? customerId,
    String? name,
    String? phone,
    String? email,
    double? totalBaki,
    String? updatedAt,
  }) {
    return BakiCustomerItem(
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      totalBaki: totalBaki ?? this.totalBaki,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}
