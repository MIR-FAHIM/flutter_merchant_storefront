class DashboardModel {
  final String? status;
  final String? message;
  final DashboardData? data;

  DashboardModel({
    this.status,
    this.message,
    this.data,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? DashboardData.fromJson(Map<String, dynamic>.from(json['data']))
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

class DashboardData {
  final int? shopsCount;
  final int? ordersCount;
  final double? ordersAmount;
  final int? productsCount;

  final int? todayTotalOrders;
  final int? lastWeekTotalOrders;
  final int? lastMonthTotalOrders;
  final int? yearTotalOrders;

  final OrdersByPeriod? ordersByPeriod;

  DashboardData({
    this.shopsCount,
    this.ordersCount,
    this.ordersAmount,
    this.productsCount,
    this.todayTotalOrders,
    this.lastWeekTotalOrders,
    this.lastMonthTotalOrders,
    this.yearTotalOrders,
    this.ordersByPeriod,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      shopsCount: _toInt(json['shops_count']),
      ordersCount: _toInt(json['orders_count']),
      ordersAmount: _toDouble(json['orders_amount']),
      productsCount: _toInt(json['products_count']),
      todayTotalOrders: _toInt(json['today_total_orders']),
      lastWeekTotalOrders: _toInt(json['last_week_total_orders']),
      lastMonthTotalOrders: _toInt(json['last_month_total_orders']),
      yearTotalOrders: _toInt(json['year_total_orders']),
      ordersByPeriod: json['orders_by_period'] is Map<String, dynamic>
          ? OrdersByPeriod.fromJson(
        Map<String, dynamic>.from(json['orders_by_period']),
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shops_count': shopsCount,
      'orders_count': ordersCount,
      'orders_amount': ordersAmount,
      'products_count': productsCount,
      'today_total_orders': todayTotalOrders,
      'last_week_total_orders': lastWeekTotalOrders,
      'last_month_total_orders': lastMonthTotalOrders,
      'year_total_orders': yearTotalOrders,
      'orders_by_period': ordersByPeriod?.toJson(),
    };
  }
}

class OrdersByPeriod {
  final int? today;
  final int? lastWeek;
  final int? lastMonth;
  final int? year;

  OrdersByPeriod({
    this.today,
    this.lastWeek,
    this.lastMonth,
    this.year,
  });

  factory OrdersByPeriod.fromJson(Map<String, dynamic> json) {
    return OrdersByPeriod(
      today: _toInt(json['today']),
      lastWeek: _toInt(json['lastWeek']),
      lastMonth: _toInt(json['lastMonth']),
      year: _toInt(json['year']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today': today,
      'lastWeek': lastWeek,
      'lastMonth': lastMonth,
      'year': year,
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

class ShopSummary {
  const ShopSummary({
    required this.period,
    required this.from,
    required this.to,
    required this.totalSales,
    required this.orderCount,
    required this.paidAmount,
    required this.dueAmount,
  });

  final String period;
  final String? from;
  final String? to;
  final double totalSales;
  final int orderCount;
  final double paidAmount;
  final double dueAmount;

  factory ShopSummary.fromJson(Map<String, dynamic> json) {
    return ShopSummary(
      period: json['period']?.toString() ?? 'daily',
      from: json['from']?.toString(),
      to: json['to']?.toString(),
      totalSales: _toDouble(json['total_sales']) ?? 0,
      orderCount: _toInt(json['order_count']) ?? 0,
      paidAmount: _toDouble(json['paid_amount']) ?? 0,
      dueAmount: _toDouble(json['due_amount']) ?? 0,
    );
  }
}

class ShopOrderSimpleReport {
  const ShopOrderSimpleReport({
    required this.shopId,
    required this.todayTotalOrder,
    required this.yesterdayTotalOrder,
    required this.lastWeekTotalOrder,
    required this.lastMonthTotalOrder,
  });

  final int shopId;
  final int todayTotalOrder;
  final int yesterdayTotalOrder;
  final int lastWeekTotalOrder;
  final int lastMonthTotalOrder;

  factory ShopOrderSimpleReport.fromJson(Map<String, dynamic> json) {
    return ShopOrderSimpleReport(
      shopId: _toInt(json['shop_id']) ?? 0,
      todayTotalOrder: _toInt(json['today_total_order']) ?? 0,
      yesterdayTotalOrder: _toInt(json['yesterday_total_order']) ?? 0,
      lastWeekTotalOrder: _toInt(json['last_week_total_order']) ?? 0,
      lastMonthTotalOrder: _toInt(json['last_month_total_order']) ?? 0,
    );
  }
}

class ShopProductLimitReport {
  const ShopProductLimitReport({
    required this.shopId,
    required this.productLimit,
    required this.totalProductAdded,
    required this.remainingProductLimit,
    required this.canAddMoreProduct,
  });

  final int shopId;
  final int productLimit;
  final int totalProductAdded;
  final int remainingProductLimit;
  final bool canAddMoreProduct;

  factory ShopProductLimitReport.fromJson(Map<String, dynamic> json) {
    return ShopProductLimitReport(
      shopId: _toInt(json['shop_id']) ?? 0,
      productLimit: _toInt(json['product_limit']) ?? 0,
      totalProductAdded: _toInt(json['total_product_added']) ?? 0,
      remainingProductLimit: _toInt(json['remaining_product_limit']) ?? 0,
      canAddMoreProduct: _toBool(json['can_add_more_product']),
    );
  }
}

bool _toBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;

  final text = value?.toString().toLowerCase().trim();
  return text == 'true' || text == '1' || text == 'yes';
}
