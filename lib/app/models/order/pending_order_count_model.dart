class PendingOrderCountModel {
  final String? status;
  final String? message;
  final PendingOrderCountData? data;

  PendingOrderCountModel({
    this.status,
    this.message,
    this.data,
  });

  factory PendingOrderCountModel.fromJson(Map<String, dynamic> json) {
    return PendingOrderCountModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] != null && json['data'] is Map<String, dynamic>
          ? PendingOrderCountData.fromJson(
              json['data'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  bool get isSuccess => status?.toLowerCase() == 'success';
}

class PendingOrderCountData {
  final int count;
  final String? status;
  final int? shopId;
  final int? userId;

  PendingOrderCountData({
    this.count = 0,
    this.status,
    this.shopId,
    this.userId,
  });

  factory PendingOrderCountData.fromJson(Map<String, dynamic> json) {
    final rawCount = json['pending_order_count'] ??
        json['pending_orders_count'] ??
        json['count'];
    return PendingOrderCountData(
      count: _toInt(rawCount),
      status: json['status']?.toString(),
      shopId: _toInt(json['shop_id']),
      userId: _toInt(json['user_id']),
    );
  }
}

int _toInt(dynamic val) {
  if (val == null) return 0;
  if (val is int) return val;
  if (val is num) return val.toInt();
  if (val is String) return int.tryParse(val) ?? 0;
  return 0;
}
