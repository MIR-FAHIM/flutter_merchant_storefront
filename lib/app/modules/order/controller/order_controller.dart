import 'package:ecom_delivery_flutter/app/models/order/order_list_model.dart';

import 'package:ecom_delivery_flutter/app/repositories/order_rep.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  String _resolveShopId() {
    return Get.find<AuthService>().currentUser.value.data!.user!.id.toString();
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

      isInitialLoading.value = orderItems.isEmpty;

      final response = await _orderRepository.shopOrderList(
        shopId: shopId,
        page: currentPage.value,
        perPage: perPage,
      );

      final ShopOrderResponseModel model =
      ShopOrderResponseModel.fromJson(Map<String, dynamic>.from(response));

      if (model.isSuccess) {
        final ShopOrderPagination? pagination = model.data;

        orderItems.assignAll(pagination?.orders ?? []);
        currentPage.value = pagination?.currentPage ?? 1;
        lastPage.value = pagination?.lastPage ?? 1;
        totalOrders.value = pagination?.total ?? orderItems.length;
      } else {
        orderItems.clear();
        errorMessage.value = model.message ?? 'Failed to load orders';
      }
    } catch (e) {
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

        orderItems.addAll(pagination?.orders ?? []);
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
          selectedOrder.value = OrderInfo(
            id: selectedOrder.value!.id,
            userId: selectedOrder.value!.userId,
            orderNumber: selectedOrder.value!.orderNumber,
            paymentGroupId: selectedOrder.value!.paymentGroupId,
            status: normalizedStatus,
            paymentStatus: selectedOrder.value!.paymentStatus,
            customerName: selectedOrder.value!.customerName,
            customerPhone: selectedOrder.value!.customerPhone,
            shippingAddress: selectedOrder.value!.shippingAddress,
            zone: selectedOrder.value!.zone,
            district: selectedOrder.value!.district,
            area: selectedOrder.value!.area,
            lat: selectedOrder.value!.lat,
            lon: selectedOrder.value!.lon,
            subtotal: selectedOrder.value!.subtotal,
            shippingFee: selectedOrder.value!.shippingFee,
            discount: selectedOrder.value!.discount,
            total: selectedOrder.value!.total,
            note: selectedOrder.value!.note,
            platform: selectedOrder.value!.platform,
            userAddressId: selectedOrder.value!.userAddressId,
            isActive: selectedOrder.value!.isActive,
            createdAt: selectedOrder.value!.createdAt,
            updatedAt: selectedOrder.value!.updatedAt,
            user: selectedOrder.value!.user,
          );
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