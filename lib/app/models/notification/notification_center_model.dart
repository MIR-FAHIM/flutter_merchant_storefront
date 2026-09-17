import 'dart:convert';

NotificationResponse notificationResponseFromJson(String source) =>
    NotificationResponse.fromJson(json.decode(source) as Map<String, dynamic>);

class NotificationResponse {
  final String status;
  final String message;
  final NotificationPage data;

  const NotificationResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      status: _string(json['status']),
      message: _string(json['message']),
      data: NotificationPage.fromJson(_map(json['data']) ?? const {}),
    );
  }
}

class NotificationPage {
  final int totalUnread;
  final List<OrderNotificationGroup> orders;
  final List<NotificationItem> general;
  final NotificationPagination pagination;

  const NotificationPage({
    required this.totalUnread,
    required this.orders,
    required this.general,
    required this.pagination,
  });

  factory NotificationPage.fromJson(Map<String, dynamic> json) {
    return NotificationPage(
      totalUnread: _int(json['total_unread']),
      orders: _list(json['orders'])
          .map(_map)
          .whereType<Map<String, dynamic>>()
          .map(OrderNotificationGroup.fromJson)
          .toList(),
      general: _list(json['general'])
          .map(_map)
          .whereType<Map<String, dynamic>>()
          .map(NotificationItem.fromJson)
          .toList(),
      pagination: NotificationPagination.fromJson(
        _map(json['pagination']) ?? const {},
      ),
    );
  }
}

class OrderNotificationGroup {
  final int orderId;
  final int unreadCount;
  bool isUnread;
  final String title;
  NotificationItem latest;
  final List<NotificationItem> notifications;

  OrderNotificationGroup({
    required this.orderId,
    required this.unreadCount,
    required this.isUnread,
    required this.title,
    required this.latest,
    required this.notifications,
  });

  factory OrderNotificationGroup.fromJson(Map<String, dynamic> json) {
    final latest = NotificationItem.fromJson(_map(json['latest']) ?? const {});
    return OrderNotificationGroup(
      orderId: _int(json['order_id']),
      unreadCount: _int(json['unread_count']),
      isUnread: _bool(json['is_unread']),
      title: _string(json['title'], fallback: 'Order #${json['order_id']}'),
      latest: latest,
      notifications: _list(json['notifications'])
          .map(_map)
          .whereType<Map<String, dynamic>>()
          .map(NotificationItem.fromJson)
          .toList(),
    );
  }

  DateTime get latestDate =>
      latest.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
}

class NotificationItem {
  final int id;
  final int? userId;
  final int? shopId;
  final int? orderId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  bool isRead;
  final DateTime? readAt;
  final DateTime? createdAt;

  NotificationItem({
    required this.id,
    this.userId,
    this.shopId,
    this.orderId,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.isRead,
    this.readAt,
    this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: _int(json['id']),
      userId: _nullableInt(json['user_id']),
      shopId: _nullableInt(json['shop_id']),
      orderId: _nullableInt(json['order_id']),
      type: _string(json['type']),
      title: _string(json['title'], fallback: 'Notification'),
      message: _string(json['message']),
      data: _map(json['data']) ?? <String, dynamic>{},
      isRead: _bool(json['is_read']),
      readAt: _date(json['read_at']),
      createdAt: _date(json['created_at']),
    );
  }
}

class NotificationPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  const NotificationPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory NotificationPagination.fromJson(Map<String, dynamic> json) {
    return NotificationPagination(
      currentPage: _int(json['current_page'], fallback: 1),
      lastPage: _int(json['last_page'], fallback: 1),
      perPage: _int(json['per_page'], fallback: 20),
      total: _int(json['total']),
    );
  }
}

Map<String, dynamic>? _map(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}

List<dynamic> _list(dynamic value) => value is List ? value : const [];

String _string(dynamic value, {String fallback = ''}) =>
    value?.toString() ?? fallback;

int _int(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

int? _nullableInt(dynamic value) {
  if (value == null) return null;
  return _int(value);
}

bool _bool(dynamic value) {
  if (value is bool) return value;
  return value?.toString().toLowerCase() == 'true' || value?.toString() == '1';
}

DateTime? _date(dynamic value) =>
    value is String ? DateTime.tryParse(value) : null;
