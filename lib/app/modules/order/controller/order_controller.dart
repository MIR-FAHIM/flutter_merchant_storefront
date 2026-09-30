import 'package:ecom_delivery_flutter/app/models/order/order_list_model.dart';

import 'package:ecom_delivery_flutter/app/modules/root/controllers/root_controller.dart';
import 'package:ecom_delivery_flutter/app/repositories/order_rep.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class OrderStatusOption {
  OrderStatusOption({
    required this.id,
    required this.name,
    required this.isActive,
  });

  final int id;
  final String name;
  final bool isActive;

  factory OrderStatusOption.fromJson(Map<String, dynamic> json) {
    return OrderStatusOption(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      isActive: json['is_active'] == true || json['is_active']?.toString() == '1',
    );
  }
}

class OrderController extends GetxController {
  OrderController({
    this.defaultShopId = '215',
    this.perPage = 20,
  });

  final String defaultShopId;
  final int perPage;

  final OrderRepository _orderRepository = OrderRepository();

  final ScrollController scrollController = ScrollController();

  final RxList<OrderInfo> orders = <OrderInfo>[].obs;
  final RxList<ShopOrderItem> orderItems = <ShopOrderItem>[].obs;

  final RxBool isInitialLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool isDetailLoading = false.obs;
  final RxBool isStatusLoading = false.obs;
  final RxBool isUpdatingStatus = false.obs;

  final RxString errorMessage = ''.obs;
  final RxString detailErrorMessage = ''.obs;
  final RxString statusErrorMessage = ''.obs;
  final RxString statusUpdateMessage = ''.obs;
  final RxString selectedOrderStatus = ''.obs;

  final RxList<OrderStatusOption> orderStatusOptions = <OrderStatusOption>[].obs;

  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalOrders = 0.obs;

  final Rxn<ShopOrderItem> selectedOrderItem = Rxn<ShopOrderItem>();
  final Rxn<OrderInfo> selectedOrder = Rxn<OrderInfo>();

  // Search & Filter state
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxString selectedFilterStatus = 'all'.obs;

  void setFilterStatus(String status) {
    selectedFilterStatus.value = status;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedFilterStatus.value = 'all';
  }

  List<OrderInfo> get filteredOrders {
    return orders.where((order) {
      // Filter status / type
      final filter = selectedFilterStatus.value.toLowerCase().trim();
      if (filter != 'all') {
        final status = (order.status ?? '').toLowerCase();
        final orderType = (order.orderType ?? '').toLowerCase();
        final paymentMethod = (order.paymentMethod ?? '').toLowerCase();
        final double dueAmount = order.dueAmount ?? 0;
        final String orderNum = (order.orderNumber ?? '').toUpperCase();

        if (filter == 'online') {
          if (orderType != 'online' && orderNum.startsWith('POS-')) {
            return false;
          }
        } else if (filter == 'pos') {
          if (orderType != 'pos' && !orderNum.startsWith('POS-')) {
            return false;
          }
        } else if (filter == 'baki') {
          if (dueAmount <= 0 && paymentMethod != 'baki') {
            return false;
          }
        } else if (filter == 'pending') {
          if (status != 'pending' && status != 'unpaid') {
            return false;
          }
        } else if (filter == 'confirmed' || filter == 'processing') {
          if (status != 'confirmed' &&
              status != 'processing' &&
              status != 'accepted') {
            return false;
          }
        } else if (filter == 'completed' || filter == 'delivered') {
          if (status != 'completed' && status != 'delivered') {
            return false;
          }
        } else if (filter == 'cancelled') {
          if (status != 'cancelled' &&
              status != 'canceled' &&
              status != 'failed') {
            return false;
          }
        }
      }

      // Search filter
      if (searchQuery.value.trim().isNotEmpty) {
        final query = searchQuery.value.trim().toLowerCase();
        final orderNum = (order.orderNumber ?? '').toLowerCase();
        final orderId = (order.id ?? '').toString().toLowerCase();
        final customer = (order.customerName ?? order.user?.name ?? '').toLowerCase();
        final phone = (order.customerPhone ?? order.user?.phone ?? '').toLowerCase();
        final payment = (order.paymentMethod ?? '').toLowerCase();
        final address = (order.shippingAddress ?? '').toLowerCase();

        bool matchItem = false;
        if (order.items != null) {
          for (final item in order.items!) {
            if ((item.productName ?? '').toLowerCase().contains(query) ||
                (item.sku ?? '').toLowerCase().contains(query)) {
              matchItem = true;
              break;
            }
          }
        }

        return orderNum.contains(query) ||
            orderId.contains(query) ||
            customer.contains(query) ||
            phone.contains(query) ||
            payment.contains(query) ||
            address.contains(query) ||
            matchItem;
      }

      return true;
    }).toList();
  }

  List<ShopOrderItem> get filteredOrderItems {
    return orderItems.where((item) {
      final order = item.order;

      // Status filter
      final filter = selectedFilterStatus.value.toLowerCase().trim();
      if (filter != 'all') {
        final status = (item.status ?? order?.status ?? '').toLowerCase();
        final orderType = (order?.orderType ?? '').toLowerCase();
        final paymentMethod = (order?.paymentMethod ?? '').toLowerCase();
        final double dueAmount = order?.dueAmount ?? 0;
        final String orderNum = (order?.orderNumber ?? '').toUpperCase();

        if (filter == 'online') {
          if (orderType != 'online' && orderNum.startsWith('POS-')) {
            return false;
          }
        } else if (filter == 'pos') {
          if (orderType != 'pos' && !orderNum.startsWith('POS-')) {
            return false;
          }
        } else if (filter == 'baki') {
          if (dueAmount <= 0 && paymentMethod != 'baki') {
            return false;
          }
        } else if (filter == 'pending') {
          if (status != 'pending' && status != 'unpaid') {
            return false;
          }
        } else if (filter == 'confirmed' || filter == 'processing') {
          if (status != 'processing' &&
              status != 'confirmed' &&
              status != 'accepted') {
            return false;
          }
        } else if (filter == 'completed' || filter == 'delivered') {
          if (status != 'delivered' && status != 'completed') {
            return false;
          }
        } else if (filter == 'cancelled') {
          if (status != 'cancelled' &&
              status != 'canceled' &&
              status != 'failed') {
            return false;
          }
        }
      }

      // Search filter
      if (searchQuery.value.trim().isNotEmpty) {
        final query = searchQuery.value.trim().toLowerCase();
        final orderNum = (order?.orderNumber ?? '').toLowerCase();
        final orderId = (item.orderId ?? item.id ?? '').toString().toLowerCase();
        final product = (item.productName ?? '').toLowerCase();
        final customer = (order?.customerName ?? order?.user?.name ?? '').toLowerCase();
        final sku = (item.sku ?? '').toLowerCase();

        return orderNum.contains(query) ||
            orderId.contains(query) ||
            product.contains(query) ||
            customer.contains(query) ||
            sku.contains(query);
      }

      return true;
    }).toList();
  }

  late final String shopId;

  bool get hasMore => currentPage.value < lastPage.value;

  @override
  void onInit() {
    super.onInit();

    shopId = _resolveShopId();

    scrollController.addListener(_onScroll);

    getShopOrderList(isRefresh: true);
  }

  @override
  void onClose() {
    searchController.dispose();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  String _resolveShopId() {
    try {
      final user = Get.find<AuthService>().currentUser.value.data?.user;
      final shopId = user?.shop?.id?.toString();
      if (shopId != null && shopId.isNotEmpty && shopId != '0') {
        return shopId;
      }
      final userId = user?.id?.toString();
      if (userId != null && userId.isNotEmpty && userId != '0') {
        return userId;
      }
    } catch (_) {}

    final box = GetStorage();
    final saved = box.read('storeId') ??
        box.read('shopId') ??
        box.read('selected_store_id');
    if (saved != null && saved.toString().isNotEmpty) {
      return saved.toString();
    }

    return defaultShopId;
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final double position = scrollController.position.pixels;
    final double max = scrollController.position.maxScrollExtent;

    if (position >= max - 250) {
      getMoreShopOrderList();
    }
  }

  Future<void> refreshOrders() async {
    await getShopOrderList(isRefresh: true);
  }

  Future<void> getShopOrderList({
    bool isRefresh = false,
  }) async {
    if (isInitialLoading.value || isMoreLoading.value) return;

    try {
      errorMessage.value = '';

      if (isRefresh) {
        currentPage.value = 1;
      }

      isInitialLoading.value = orders.isEmpty && orderItems.isEmpty;

      final response = await _orderRepository.shopOrderList(
        shopId: shopId,
        page: currentPage.value,
        perPage: perPage,
      );

      final ShopOrderResponseModel model =
          ShopOrderResponseModel.fromJson(Map<String, dynamic>.from(response));

      if (model.isSuccess) {
        final ShopOrderPagination? pagination = model.data;
        final List<OrderInfo> newOrders = pagination?.orderList ?? [];
        final List<ShopOrderItem> newItems = pagination?.orders ?? [];

        orders.assignAll(newOrders);
        orderItems.assignAll(newItems);
        currentPage.value = pagination?.currentPage ?? 1;
        lastPage.value = pagination?.lastPage ?? 1;
        totalOrders.value = pagination?.total ??
            (newOrders.isNotEmpty ? newOrders.length : newItems.length);
      } else {
        orders.clear();
        orderItems.clear();
        errorMessage.value = model.message ?? 'Failed to load orders';
      }
    } catch (e) {
      orders.clear();
      orderItems.clear();
      errorMessage.value = e.toString();
      debugPrint('getShopOrderList error: $e');
    } finally {
      isInitialLoading.value = false;
    }
  }

  Future<void> getMoreShopOrderList() async {
    if (!hasMore) return;
    if (isInitialLoading.value || isMoreLoading.value) return;

    try {
      isMoreLoading.value = true;
      errorMessage.value = '';

      final int nextPage = currentPage.value + 1;

      final response = await _orderRepository.shopOrderList(
        shopId: shopId,
        page: nextPage,
        perPage: perPage,
      );

      final ShopOrderResponseModel model =
          ShopOrderResponseModel.fromJson(Map<String, dynamic>.from(response));

      if (model.isSuccess) {
        final ShopOrderPagination? pagination = model.data;
        final List<OrderInfo> newOrders = pagination?.orderList ?? [];
        final List<ShopOrderItem> newItems = pagination?.orders ?? [];

        orders.addAll(newOrders);
        orderItems.addAll(newItems);
        currentPage.value = pagination?.currentPage ?? nextPage;
        lastPage.value = pagination?.lastPage ?? lastPage.value;
        totalOrders.value = pagination?.total ?? totalOrders.value;
      } else {
        errorMessage.value = model.message ?? 'Failed to load more orders';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('getMoreShopOrderList error: $e');
    } finally {
      isMoreLoading.value = false;
    }
  }

  Future<void> openOrder(OrderInfo order) async {
    selectedOrder.value = order;
    selectedOrderItem.value = (order.items != null && order.items!.isNotEmpty)
        ? order.items!.first
        : null;

    Get.toNamed(Routes.ORDER_SHOP_DETAIL);

    final int? orderId = order.id;
    if (orderId != null) {
      await getOrderDetails(orderId.toString());
    }
  }

  Future<void> openOrderDetail(ShopOrderItem item) async {
    selectedOrderItem.value = item;
    selectedOrder.value = item.order;

    Get.toNamed(Routes.ORDER_SHOP_DETAIL);

    final int? orderId = item.orderId ?? item.order?.id;

    if (orderId != null) {
      await getOrderDetails(orderId.toString());
    }
  }

  Future<void> getOrderDetails(String orderId) async {
    try {
      isDetailLoading.value = true;
      detailErrorMessage.value = '';

      final response = await _orderRepository.orderDetails(
        orderId: orderId,
      );

      final OrderDetailResponseModel model =
      OrderDetailResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      if (model.isSuccess) {
        if (model.item != null) {
          selectedOrderItem.value = model.item;
        }

        if (model.order != null) {
          selectedOrder.value = model.order;
        }

        final String currentStatus = selectedOrder.value?.status ??
            selectedOrderItem.value?.status ?? '';

        if (currentStatus.isNotEmpty) {
          selectedOrderStatus.value = currentStatus.trim().toLowerCase();
        }

        await loadOrderStatuses();
      } else {
        detailErrorMessage.value =
            model.message ?? 'Failed to load order details';
      }
    } catch (e) {
      detailErrorMessage.value = e.toString();
      debugPrint('getOrderDetails error: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> loadOrderStatuses() async {
    try {
      isStatusLoading.value = true;
      statusErrorMessage.value = '';

      final response = await _orderRepository.fetchOrderStatuses();
      final int statusCode = response['status_code'] is int ? response['status_code'] as int : 200;
      final dynamic body = response['body'];
      final Map<String, dynamic> payload = body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
      final List<dynamic> data = payload['data'] is List ? payload['data'] as List<dynamic> : const [];

      if (statusCode >= 200 && statusCode < 300) {
        orderStatusOptions.assignAll(
          data
              .whereType<Map>()
              .map((item) => OrderStatusOption.fromJson(Map<String, dynamic>.from(item)))
              .toList(),
        );

        if (selectedOrderStatus.value.isEmpty && orderStatusOptions.isNotEmpty) {
          selectedOrderStatus.value = orderStatusOptions.first.name.toLowerCase();
        }

        if (selectedOrderStatus.value.isNotEmpty && orderStatusOptions.isNotEmpty) {
          final bool matchesExisting = orderStatusOptions.any(
            (option) => option.name.toLowerCase() == selectedOrderStatus.value,
          );

          if (!matchesExisting) {
            selectedOrderStatus.value = orderStatusOptions.first.name.toLowerCase();
          }
        }
      } else {
        statusErrorMessage.value = payload['message']?.toString() ?? 'Failed to load order statuses';
      }
    } catch (e) {
      statusErrorMessage.value = e.toString();
      debugPrint('loadOrderStatuses error: $e');
    } finally {
      isStatusLoading.value = false;
    }
  }

  Future<bool> changeOrderStatus({
    required String orderId,
    required String status,
  }) async {
    if (orderId.isEmpty || status.isEmpty || isUpdatingStatus.value) {
      return false;
    }

    try {
      isUpdatingStatus.value = true;
      statusUpdateMessage.value = '';
      statusErrorMessage.value = '';

      final response = await _orderRepository.updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      final int statusCode = response['status_code'] is int ? response['status_code'] as int : 500;
      final dynamic body = response['body'];
      final Map<String, dynamic> payload = body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};

      if (statusCode >= 200 && statusCode < 300) {
        final String normalizedStatus = status.trim();
        selectedOrderStatus.value = normalizedStatus;
        statusUpdateMessage.value = payload['message']?.toString() ?? 'Order status updated successfully';

        if (selectedOrder.value != null) {
          selectedOrder.value = selectedOrder.value!.copyWith(status: normalizedStatus);
        }

        final int parsedId = int.tryParse(orderId) ?? 0;
        final int orderIdx = orders.indexWhere((o) => o.id == parsedId);
        if (orderIdx != -1) {
          orders[orderIdx] = orders[orderIdx].copyWith(status: normalizedStatus);
          orders.refresh();
        }

        if (selectedOrderItem.value != null) {
          selectedOrderItem.value = ShopOrderItem(
            id: selectedOrderItem.value!.id,
            orderId: selectedOrderItem.value!.orderId,
            productId: selectedOrderItem.value!.productId,
            shopId: selectedOrderItem.value!.shopId,
            productName: selectedOrderItem.value!.productName,
            sku: selectedOrderItem.value!.sku,
            unitPrice: selectedOrderItem.value!.unitPrice,
            qty: selectedOrderItem.value!.qty,
            lineTotal: selectedOrderItem.value!.lineTotal,
            status: normalizedStatus,
            isSettleWithSeller: selectedOrderItem.value!.isSettleWithSeller,
            createdAt: selectedOrderItem.value!.createdAt,
            updatedAt: selectedOrderItem.value!.updatedAt,
            order: selectedOrderItem.value!.order,
          );
        }

        await getOrderDetails(orderId);
        if (Get.isRegistered<RootController>()) {
          Get.find<RootController>().fetchPendingOrderCount();
        }
        return true;
      }

      statusErrorMessage.value = payload['message']?.toString() ?? 'Failed to update order status';
      return false;
    } catch (e) {
      statusErrorMessage.value = e.toString();
      debugPrint('changeOrderStatus error: $e');
      return false;
    } finally {
      isUpdatingStatus.value = false;
    }
  }
}