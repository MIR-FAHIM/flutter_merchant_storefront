class CustomerLedgerResponse {
  final String? status;
  final String? message;
  final CustomerLedgerData? data;

  CustomerLedgerResponse({
    this.status,
    this.message,
    this.data,
  });

  factory CustomerLedgerResponse.fromJson(Map<String, dynamic> json) {
    return CustomerLedgerResponse(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? CustomerLedgerData.fromJson(json['data'] as Map<String, dynamic>)
          : (json['data'] is Map
              ? CustomerLedgerData.fromJson(Map<String, dynamic>.from(json['data']))
              : null),
    );
  }
}

class CustomerLedgerData {
  final CustomerLedgerInfo? customer;
  final double totalBaki;
  final CustomerLedgerPagination? ledgers;

  CustomerLedgerData({
    this.customer,
    required this.totalBaki,
    this.ledgers,
  });

  factory CustomerLedgerData.fromJson(Map<String, dynamic> json) {
    final rawCustomer = json['customer'] ?? json['customer_info'];

    final rawLedgers = json['ledger_history'] ??
        json['ledgers'] ??
        json['ledger_entries'] ??
        json['recent_ledger_entries'] ??
        json['entries'] ??
        json['data'];

    CustomerLedgerPagination? pagination;
    if (rawLedgers is Map<String, dynamic>) {
      pagination = CustomerLedgerPagination.fromJson(rawLedgers);
    } else if (rawLedgers is Map) {
      pagination = CustomerLedgerPagination.fromJson(Map<String, dynamic>.from(rawLedgers));
    } else if (rawLedgers is List) {
      pagination = CustomerLedgerPagination(
        currentPage: 1,
        lastPage: 1,
        data: rawLedgers
            .whereType<Map>()
            .map((e) => LedgerItem.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );
    }

    return CustomerLedgerData(
      customer: rawCustomer is Map
          ? CustomerLedgerInfo.fromJson(Map<String, dynamic>.from(rawCustomer))
          : null,
      totalBaki: _toDouble(
        json['total_baki'] ??
            json['total_outstanding_baki'] ??
            json['total_due'] ??
            json['due_amount'],
      ),
      ledgers: pagination,
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}

class CustomerLedgerInfo {
  final int? id;
  final String? name;
  final String? phone;
  final String? email;
  final String? avatar;
  final String? address;

  CustomerLedgerInfo({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.avatar,
    this.address,
  });

  factory CustomerLedgerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerLedgerInfo(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : (int.tryParse(json['id']?.toString() ?? '') ??
              (json['customer_id'] is num
                  ? (json['customer_id'] as num).toInt()
                  : int.tryParse(json['customer_id']?.toString() ?? ''))),
      name: json['name']?.toString() ?? json['customer_name']?.toString(),
      phone: json['phone']?.toString() ?? json['customer_phone']?.toString(),
      email: json['email']?.toString(),
      avatar: json['avatar']?.toString(),
      address: json['address']?.toString(),
    );
  }
}

class CustomerLedgerPagination {
  final int currentPage;
  final int lastPage;
  final List<LedgerItem> data;

  CustomerLedgerPagination({
    required this.currentPage,
    required this.lastPage,
    required this.data,
  });

  factory CustomerLedgerPagination.fromJson(Map<String, dynamic> json) {
    var rawList = json['data'] ??
        json['ledger_history'] ??
        json['ledgers'] ??
        json['entries'];
    List<LedgerItem> items = [];
    if (rawList is List) {
      items = rawList
          .whereType<Map>()
          .map((e) => LedgerItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return CustomerLedgerPagination(
      currentPage: json['current_page'] is num
          ? (json['current_page'] as num).toInt()
          : (int.tryParse(json['current_page']?.toString() ?? '') ?? 1),
      lastPage: json['last_page'] is num
          ? (json['last_page'] as num).toInt()
          : (int.tryParse(json['last_page']?.toString() ?? '') ?? 1),
      data: items,
    );
  }
}

class LedgerCreator {
  final int? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? userType;

  LedgerCreator({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.userType,
  });

  factory LedgerCreator.fromJson(Map<String, dynamic> json) {
    return LedgerCreator(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      userType: json['user_type']?.toString(),
    );
  }
}

class LedgerItem {
  final int? id;
  final int? shopId;
  final int? sellerId;
  final int? customerId;
  final int? orderId;
  final String type; // "DUE" or "PAYMENT"
  final double amount;
  final double paidAmount;
  final double dueAmount;
  final double runningBalance;
  final String? dueDate;
  final String? note;
  final String? createdAt;
  final String? updatedAt;
  final String? paymentMethod;
  final LedgerOrder? order;
  final CustomerLedgerInfo? customer;
  final LedgerCreator? creator;
  final String? createdBy;

  LedgerItem({
    this.id,
    this.shopId,
    this.sellerId,
    this.customerId,
    this.orderId,
    required this.type,
    required this.amount,
    required this.paidAmount,
    required this.dueAmount,
    required this.runningBalance,
    this.dueDate,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.paymentMethod,
    this.order,
    this.customer,
    this.creator,
    this.createdBy,
  });

  bool get isDue =>
      type.toUpperCase() == 'DUE' || (type.isEmpty && amount > 0);
  bool get isPayment =>
      type.toUpperCase() == 'PAYMENT' ||
      type.toUpperCase() == 'COLLECT' ||
      type.toUpperCase() == 'PAID' ||
      (type.isEmpty && amount < 0);

  factory LedgerItem.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString().toUpperCase() ??
        (_toDouble(json['paid_amount']) > 0 && _toDouble(json['due_amount']) == 0
            ? 'PAYMENT'
            : 'DUE');

    final rawCust = json['customer'];
    final rawOrder = json['order'];
    final rawCreator = json['creator'];

    final creatorObj = rawCreator is Map
        ? LedgerCreator.fromJson(Map<String, dynamic>.from(rawCreator))
        : null;

    final resolvedCreatorName = creatorObj?.name?.trim().isNotEmpty == true
        ? creatorObj!.name!
        : (json['created_by']?.toString() ?? json['staff_name']?.toString());

    return LedgerItem(
      id: _toInt(json['id']),
      shopId: _toInt(json['shop_id']),
      sellerId: _toInt(json['seller_id']),
      customerId: _toInt(json['customer_id']),
      orderId: _toInt(json['order_id']),
      type: rawType,
      amount: _toDouble(json['amount']),
      paidAmount: _toDouble(json['paid_amount']),
      dueAmount: _toDouble(json['due_amount']),
      runningBalance: _toDouble(json['running_balance']),
      dueDate: json['due_date']?.toString(),
      note: json['note']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      paymentMethod: json['payment_method']?.toString(),
      customer: rawCust is Map
          ? CustomerLedgerInfo.fromJson(Map<String, dynamic>.from(rawCust))
          : null,
      order: rawOrder is Map
          ? LedgerOrder.fromJson(Map<String, dynamic>.from(rawOrder))
          : null,
      creator: creatorObj,
      createdBy: resolvedCreatorName,
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }

  static int? _toInt(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toInt();
    return int.tryParse(val.toString());
  }
}

class LedgerOrder {
  final int? id;
  final String? orderNumber;
  final double total;
  final double paidAmount;
  final double dueAmount;
  final String? paymentStatus;
  final String? status;
  final String? customerName;
  final String? customerPhone;
  final String? note;
  final String? dueDate;
  final String? platform;

  LedgerOrder({
    this.id,
    this.orderNumber,
    this.total = 0.0,
    this.paidAmount = 0.0,
    this.dueAmount = 0.0,
    this.paymentStatus,
    this.status,
    this.customerName,
    this.customerPhone,
    this.note,
    this.dueDate,
    this.platform,
  });

  factory LedgerOrder.fromJson(Map<String, dynamic> json) {
    return LedgerOrder(
      id: json['id'] is num
          ? (json['id'] as num).toInt()
          : int.tryParse(json['id']?.toString() ?? ''),
      orderNumber: json['order_number']?.toString() ?? json['order_no']?.toString(),
      total: _toDouble(json['total'] ?? json['subtotal'] ?? json['grand_total']),
      paidAmount: _toDouble(json['paid_amount']),
      dueAmount: _toDouble(json['due_amount']),
      paymentStatus: json['payment_status']?.toString(),
      status: json['status']?.toString(),
      customerName: json['customer_name']?.toString(),
      customerPhone: json['customer_phone']?.toString(),
      note: json['note']?.toString(),
      dueDate: json['due_date']?.toString(),
      platform: json['platform']?.toString(),
    );
  }

  static double _toDouble(dynamic val) {
    if (val == null) return 0.0;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString()) ?? 0.0;
  }
}
