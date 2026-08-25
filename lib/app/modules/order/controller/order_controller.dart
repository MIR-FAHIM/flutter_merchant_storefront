import 'package:ecom_delivery_flutter/app/models/order/order_list_model.dart';

import 'package:ecom_delivery_flutter/app/repositories/order_rep.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

  final RxString errorMessage = ''.obs;
  final RxString detailErrorMessage = ''.obs;

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
    final dynamic args = Get.arguments;

    if (args is Map && args['shop_id'] != null) {
      return args['shop_id'].toString();
    }

    if (args is Map && args['shopId'] != null) {
      return args['shopId'].toString();
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
}