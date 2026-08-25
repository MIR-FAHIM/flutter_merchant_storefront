
import 'package:ecom_delivery_flutter/app/models/product/product_response_model.dart';
import 'package:ecom_delivery_flutter/app/repositories/product_rep.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductController extends GetxController {
  ProductController({
    this.defaultShopId = '44',
    this.perPage = 24,
  });

  final String defaultShopId;
  final int perPage;

  final ProductRepository _productRepository = ProductRepository();

  final ScrollController scrollController = ScrollController();

  final RxList<ProductData> products = <ProductData>[].obs;

  final RxBool isInitialLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  final RxString errorMessage = ''.obs;

  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalProducts = 0.obs;

  late final String shopId;

  bool get hasMore => currentPage.value < lastPage.value;

  @override
  void onInit() {
    super.onInit();

    shopId = _resolveShopId();

    scrollController.addListener(_onScroll);

    getShopProductList(isRefresh: true);
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

    final double currentPosition = scrollController.position.pixels;
    final double maxPosition = scrollController.position.maxScrollExtent;

    if (currentPosition >= maxPosition - 250) {
      getMoreShopProductList();
    }
  }

  Future<void> refreshProducts() async {
    await getShopProductList(isRefresh: true);
  }

  Future<void> getShopProductList({
    bool isRefresh = false,
  }) async {
    if (isInitialLoading.value ||
        isMoreLoading.value ||
        isRefreshing.value) {
      return;
    }

    try {
      errorMessage.value = '';

      if (isRefresh) {
        currentPage.value = 1;

        if (products.isEmpty) {
          isInitialLoading.value = true;
        } else {
          isRefreshing.value = true;
        }
      } else {
        isInitialLoading.value = true;
      }

      final response = await _productRepository.shopProductList(
        shopId: shopId,
        page: currentPage.value,
        perPage: perPage,
      );

      final ProductResponseModel model = ProductResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      if (model.isSuccess) {
        final ProductPagination? pagination = model.data;

        products.assignAll(pagination?.products ?? []);

        currentPage.value = pagination?.currentPage ?? 1;
        lastPage.value = pagination?.lastPage ?? 1;
        totalProducts.value = pagination?.total ?? products.length;
      } else {
        products.clear();
        errorMessage.value = model.message ?? 'Failed to load products';
      }
    } catch (e) {
      products.clear();
      errorMessage.value = e.toString();
      debugPrint('getShopProductList error: $e');
    } finally {
      isInitialLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> getMoreShopProductList() async {
    if (!hasMore) return;

    if (isInitialLoading.value ||
        isMoreLoading.value ||
        isRefreshing.value) {
      return;
    }

    try {
      isMoreLoading.value = true;
      errorMessage.value = '';

      final int nextPage = currentPage.value + 1;

      final response = await _productRepository.shopProductList(
        shopId: shopId,
        page: nextPage,
        perPage: perPage,
      );

      final ProductResponseModel model = ProductResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      if (model.isSuccess) {
        final ProductPagination? pagination = model.data;

        products.addAll(pagination?.products ?? []);

        currentPage.value = pagination?.currentPage ?? nextPage;
        lastPage.value = pagination?.lastPage ?? lastPage.value;
        totalProducts.value = pagination?.total ?? totalProducts.value;
      } else {
        errorMessage.value = model.message ?? 'Failed to load more products';
      }
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint('getMoreShopProductList error: $e');
    } finally {
      isMoreLoading.value = false;
    }
  }
}