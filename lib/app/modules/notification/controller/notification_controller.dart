import 'package:ecom_delivery_flutter/app/models/notification/notification_center_model.dart';
import 'package:ecom_delivery_flutter/app/repositories/notification_repository.dart';

import 'package:get/get.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository = NotificationRepository();
  final orderGroups = <OrderNotificationGroup>[].obs;
  final generalNotifications = <NotificationItem>[].obs;
  final orderHistory = <NotificationItem>[].obs;
  final unreadCount = 0.obs;
  final selectedTab = 0.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final isRefreshing = false.obs;
  final isDetailLoading = false.obs;
  final error = ''.obs;
  final hasMore = true.obs;

  int _page = 1;
  bool _readInProgress = false;
  int? _loadedHistoryOrderId;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
    fetchUnreadCount();
  }

  List<Object> get visibleItems {
    final items = <Object>[];
    if (selectedTab.value != 2) items.addAll(orderGroups);
    if (selectedTab.value != 1) items.addAll(generalNotifications);
    items.sort((a, b) {
      final aDate = a is OrderNotificationGroup
          ? a.latestDate
          : (a as NotificationItem).createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
      final bDate = b is OrderNotificationGroup
          ? b.latestDate
          : (b as NotificationItem).createdAt ??
              DateTime.fromMillisecondsSinceEpoch(0);
      return bDate.compareTo(aDate);
    });
    return items;
  }

  Future<void> fetchNotifications({bool reset = true}) async {
    if (reset && isLoading.value) return;
    if (!reset && (isLoadingMore.value || !hasMore.value)) return;

    if (reset) {
      isLoading.value = true;
      _page = 1;
      hasMore.value = true;
      error.value = '';
      orderGroups.clear();
      generalNotifications.clear();
    } else {
      isLoadingMore.value = true;
    }

    try {
      final response = await _repository.getNotifications(page: _page);
      if (response is Map && response['status'] == 'success') {
        final page = NotificationResponse.fromJson(
          Map<String, dynamic>.from(response),
        ).data;
        _mergeOrders(page.orders);
        _mergeGeneral(page.general);
        unreadCount.value = page.totalUnread;
        _page = page.pagination.currentPage + 1;
        hasMore.value = page.pagination.currentPage < page.pagination.lastPage;
      } else {
        error.value = _message(response);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    isRefreshing.value = true;
    try {
      await Future.wait([
        fetchNotifications(),
        fetchUnreadCount(),
      ]);
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final response = await _repository.getUnreadCount();
      if (response is Map && response['status'] == 'success') {
        final data = response['data'];
        if (data is Map) {
          unreadCount.value =
              int.tryParse(data['unread_count'].toString()) ?? 0;
        }
      }
    } catch (_) {}
  }

  Future<bool> markNotificationRead(NotificationItem item) async {
    if (item.isRead || _readInProgress) return true;
    _readInProgress = true;
    try {
      final response = await _repository.markRead(item.id);
      if (_successful(response)) {
        item.isRead = true;
        _replaceGeneral(item);
        await fetchUnreadCount();
        return true;
      }
      return false;
    } finally {
      _readInProgress = false;
    }
  }

  Future<void> fetchOrderHistory(int orderId, {bool force = false}) async {
    if (!force &&
        (isDetailLoading.value ||
            (_loadedHistoryOrderId == orderId && orderHistory.isNotEmpty))) {
      return;
    }
    isDetailLoading.value = true;
    orderHistory.clear();
    try {
      final response = await _repository.getOrderHistory(orderId);
      if (_successful(response)) {
        final data = response['data'];
        final raw = data is Map ? data['notifications'] : null;
        orderHistory.assignAll(_items(raw));
        _loadedHistoryOrderId = orderId;
        await markOrderNotificationsRead(orderId);
      } else {
        error.value = _message(response);
      }
    } catch (e) {
      error.value = e.toString();
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> markOrderNotificationsRead(int orderId) async {
    final unread = orderHistory.where((item) => !item.isRead).toList();
    for (final item in unread) {
      final response = await _repository.markRead(item.id);
      if (_successful(response)) item.isRead = true;
    }
    final groupIndex =
        orderGroups.indexWhere((group) => group.orderId == orderId);
    if (groupIndex >= 0) {
      final group = orderGroups[groupIndex];
      group.isUnread = false;
      orderGroups[groupIndex] = group;
    }
    orderGroups.refresh();
    await fetchUnreadCount();
  }

  Future<bool> markAllAsRead() async {
    if (unreadCount.value == 0 || _readInProgress) return true;
    _readInProgress = true;
    try {
      final response = await _repository.markAllRead();
      if (_successful(response)) {
        unreadCount.value = 0;
        for (final group in orderGroups) group.isUnread = false;
        for (final item in generalNotifications) item.isRead = true;
        orderGroups.refresh();
        generalNotifications.refresh();
        await fetchUnreadCount();
        return true;
      }
      return false;
    } finally {
      _readInProgress = false;
    }
  }

  void _mergeOrders(List<OrderNotificationGroup> incoming) {
    for (final group in incoming) {
      final index =
          orderGroups.indexWhere((item) => item.orderId == group.orderId);
      if (index < 0) {
        orderGroups.add(group);
      } else if (group.latestDate.isAfter(orderGroups[index].latestDate)) {
        orderGroups[index].latest = group.latest;
        orderGroups[index].isUnread = group.isUnread;
      }
    }
    orderGroups.refresh();
  }

  void _mergeGeneral(List<NotificationItem> incoming) {
    final knownIds = generalNotifications.map((item) => item.id).toSet();
    generalNotifications
        .addAll(incoming.where((item) => !knownIds.contains(item.id)));
    generalNotifications.refresh();
  }

  void _replaceGeneral(NotificationItem item) {
    final index =
        generalNotifications.indexWhere((value) => value.id == item.id);
    if (index >= 0) generalNotifications[index] = item;
    generalNotifications.refresh();
  }

  List<NotificationItem> _items(dynamic raw) => raw is List
      ? raw
          .map((value) => value is Map
              ? NotificationItem.fromJson(Map<String, dynamic>.from(value))
              : null)
          .whereType<NotificationItem>()
          .toList()
      : <NotificationItem>[];

  bool _successful(dynamic response) =>
      response is Map && response['status'] == 'success';

  String _message(dynamic response) => response is Map
      ? response['message']?.toString() ?? 'Unable to load notifications'
      : 'Unable to load notifications';
}
