
import 'dart:convert';

import 'package:ecom_delivery_flutter/app/models/product/product_response_model.dart';
import 'package:ecom_delivery_flutter/app/models/seller_store_model.dart';
import 'package:ecom_delivery_flutter/app/repositories/product_rep.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProductController extends GetxController {
  ProductController({
    this.defaultShopId = '17',
    this.perPage = 12,
  });

  final String defaultShopId;
  final int perPage;

  final ProductRepository _productRepository = ProductRepository();

  final ScrollController scrollController = ScrollController();

  final RxList<ProductData> products = <ProductData>[].obs;
  final Rx<ProductData?> selectedProduct = Rx<ProductData?>(null);

  final RxBool isInitialLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isDetailLoading = false.obs;
  final RxBool isSaving = false.obs;

  final RxString errorMessage = ''.obs;
  final RxString detailError = ''.obs;
  final RxString saveMessage = ''.obs;

  final RxList<SellerStoreModel> sellerStores = <SellerStoreModel>[].obs;
  final RxList<SellerCategoryOption> activeCategories = <SellerCategoryOption>[].obs;
  final RxList<MarketplaceCategoryNode> marketplaceCategories = <MarketplaceCategoryNode>[].obs;
  final RxList<int> selectedCategoryIds = <int>[].obs;
  final RxList<SellerBrandOption> brands = <SellerBrandOption>[].obs;
  final RxString selectedStoreId = ''.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedBrandId = ''.obs;
  final RxString categoryError = ''.obs;
  final RxString addProductError = ''.obs;
  final RxBool isStoresLoading = false.obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxBool isCategorySyncing = false.obs;
  final RxBool isBrandsLoading = false.obs;
  final RxBool isCreatingProduct = false.obs;

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

    getStoreProductList(isRefresh: true);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  String _resolveShopId() {


    return Get.find<AuthService>().currentUser.value.data!.user!.shop!.id.toString();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;

    final double currentPosition = scrollController.position.pixels;
    final double maxPosition = scrollController.position.maxScrollExtent;

    if (currentPosition >= maxPosition - 250) {
      getMoreStoreProductList();
    }
  }

  Future<void> refreshProducts() async {
    await getStoreProductList(isRefresh: true);
  }

  Future<void> getProductDetails({required int productId}) async {
    if (productId <= 0) {
      detailError.value = 'Invalid product selected';
      return;
    }

    try {
      isDetailLoading.value = true;
      detailError.value = '';

      final Map<String, dynamic> response = await _productRepository.fetchProductDetails(
        productId: productId,
      );

      final int statusCode = response['status_code'] is int
          ? response['status_code'] as int
          : 200;
      final dynamic body = response['body'];

      if (statusCode >= 200 && statusCode < 300) {
        final Map<String, dynamic> payload = body is Map
            ? Map<String, dynamic>.from(body)
            : <String, dynamic>{};

        final dynamic item = payload['data'] ?? payload;

        if (item is Map) {
          selectedProduct.value = ProductData.fromJson(Map<String, dynamic>.from(item));
        } else {
          selectedProduct.value = null;
          detailError.value = 'No product details found';
        }
      } else {
        final Map<String, dynamic> payload = body is Map
            ? Map<String, dynamic>.from(body)
            : <String, dynamic>{};
        detailError.value = payload['message']?.toString() ?? 'Failed to load product details';
      }
    } catch (e) {
      selectedProduct.value = null;
      detailError.value = e.toString();
      debugPrint('getProductDetails error: $e');
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<bool> updateProduct({
    required int productId,
    required Map<String, String> fields,
  }) async {
    if (isSaving.value) {
      return false;
    }

    try {
      isSaving.value = true;
      saveMessage.value = '';

      final Map<String, dynamic> response = await _productRepository.updateProduct(
        productId: productId,
        fields: fields,
      );

      final int statusCode = response['status_code'] is int
          ? response['status_code'] as int
          : 500;
      final dynamic body = response['body'];
      final Map<String, dynamic> payload = body is Map
          ? Map<String, dynamic>.from(body)
          : <String, dynamic>{};

      if (statusCode >= 200 && statusCode < 300) {
        saveMessage.value = payload['message']?.toString() ?? 'Product updated successfully';
        await getProductDetails(productId: productId);
        return true;
      }

      final List<dynamic> errors = payload['errors'] is Map
          ? payload['errors'].values.expand((item) => item is List ? item : [item]).toList()
          : const [];

      final String validationMessage = errors.isNotEmpty
          ? errors.first.toString()
          : payload['message']?.toString() ?? 'Unable to update product';
      saveMessage.value = validationMessage;
      return false;
    } catch (e) {
      saveMessage.value = e.toString();
      debugPrint('updateProduct error: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  @Deprecated('Inactive: use getStoreProductList() for the seller-store product API.')
  Future<void> getShopProductList({
    bool isRefresh = false,
  }) async {
    debugPrint('Inactive getShopProductList called. Use getStoreProductList instead.');
  }

  Future<void> getStoreProductList({
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

      final response = await _productRepository.storeProductList(
        storeId: shopId,
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
      debugPrint('getStoreProductList error: $e');
    } finally {
      isInitialLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> getMoreStoreProductList() async {
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

      final response = await _productRepository.storeProductList(
        storeId: shopId,
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
      debugPrint('getMoreStoreProductList error: $e');
    } finally {
      isMoreLoading.value = false;
    }
  }

  @Deprecated('Inactive: use getMoreStoreProductList() for the seller-store product API.')
  Future<void> getMoreShopProductList() async {
    debugPrint('Inactive getMoreShopProductList called. Use getMoreStoreProductList instead.');
  }

  Future<void> initializeProductAddFlow() async {
    final directShopId = Get.find<AuthService>().currentUser.value.data!.user!.shop!.id.toString();
    selectedStoreId.value = directShopId;
    GetStorage().write('storeId', directShopId);
    GetStorage().write('shopId', directShopId);
    GetStorage().write('selected_store_id', directShopId);

    await loadSellerStores();
    await loadBrands();

    if (selectedStoreId.value.isNotEmpty) {
      await loadActiveCategories();
    }
  }

  Future<void> loadSellerStores() async {
    try {
      isStoresLoading.value = true;
      categoryError.value = '';

      final response = await _productRepository.fetchSellerShops();
      final statusCode = response['status_code'] is int ? response['status_code'] as int : 200;
      final body = response['body'];

      if (statusCode >= 200 && statusCode < 300) {
        final items = _extractList(body, keys: const ['data', 'shops', 'stores', 'items', 'result']);
        final stores = items
            .whereType<Map>()
            .map((item) => SellerStoreModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        sellerStores.assignAll(stores);

        final currentShopId = Get.find<AuthService>().currentUser.value.data?.user?.shop?.id?.toString() ?? '';
        final savedStoreId = GetStorage().read('storeId') ?? GetStorage().read('shopId') ?? GetStorage().read('selected_store_id');
        final resolvedStoreId = currentShopId.isNotEmpty
            ? currentShopId
            : (savedStoreId != null && savedStoreId.toString().isNotEmpty)
                ? savedStoreId.toString()
                : (stores.isNotEmpty ? stores.first.id?.toString() ?? '' : '');

        selectedStoreId.value = resolvedStoreId;
        if (selectedStoreId.value.isNotEmpty) {
          GetStorage().write('storeId', selectedStoreId.value);
          GetStorage().write('shopId', selectedStoreId.value);
          GetStorage().write('selected_store_id', selectedStoreId.value);
        }
      } else {
        final payload = body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
        addProductError.value = payload['message']?.toString() ?? 'Unable to load stores';
      }
    } catch (e) {
      addProductError.value = e.toString();
    } finally {
      isStoresLoading.value = false;
    }
  }

  Future<void> loadActiveCategories() async {
    if (selectedStoreId.value.isEmpty) {
      activeCategories.clear();
      categoryError.value = 'No store selected.';
      return;
    }

    try {
      isCategoriesLoading.value = true;
      categoryError.value = '';

      final response = await _productRepository.fetchStoreCategories(storeId: selectedStoreId.value);
      final statusCode = response['status_code'] is int ? response['status_code'] as int : 200;
      final body = response['body'];

      if (statusCode < 200 || statusCode >= 300) {
        final payload = body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
        categoryError.value = payload['message']?.toString() ?? 'Unable to load categories';
        activeCategories.clear();
        return;
      }

      final flattenedCategories = <SellerCategoryOption>[];
      final rootItems = _extractList(body, keys: const ['data', 'categories', 'items', 'result']);

      for (final item in rootItems) {
        if (item is Map) {
          _collectActiveCategories(Map<String, dynamic>.from(item), flattenedCategories);
        }
      }

      final active = flattenedCategories
          .where((option) => option.isActiveForStore == true)
          .toList();

      activeCategories.assignAll(active);

      if (active.isEmpty) {
        categoryError.value = 'No active categories found. Please activate categories first.';
      }
    } catch (e) {
      categoryError.value = e.toString();
      activeCategories.clear();
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> loadBrands() async {
    try {
      isBrandsLoading.value = true;

      final response = await _productRepository.fetchBrands();
      final statusCode = response['status_code'] is int ? response['status_code'] as int : 200;
      final body = response['body'];

      if (statusCode < 200 || statusCode >= 300) {
        brands.clear();
        return;
      }

      final items = _extractList(body, keys: const ['data', 'brands', 'items', 'result']);
      brands.assignAll(
        items.whereType<Map>().map((item) => SellerBrandOption.fromJson(Map<String, dynamic>.from(item))).toList(),
      );
    } catch (_) {
      brands.clear();
    } finally {
      isBrandsLoading.value = false;
    }
  }

  Future<void> loadMarketplaceCategories() async {
    final resolvedStoreId = _resolveMarketplaceStoreId();

    if (resolvedStoreId.isEmpty) {
      marketplaceCategories.clear();
      categoryError.value = 'No store selected.';
      return;
    }

    try {
      isCategoriesLoading.value = true;
      categoryError.value = '';

      final response = await _productRepository.fetchStoreCategories(storeId: resolvedStoreId);
      final statusCode = response['status_code'] is int ? response['status_code'] as int : 200;
      final body = response['body'];

      if (statusCode < 200 || statusCode >= 300) {
        categoryError.value = _categoryApiErrorMessage(statusCode, body);
        if (statusCode == 401) {
          Get.offAllNamed(Routes.LOGIN);
        }
        marketplaceCategories.clear();
        selectedCategoryIds.clear();
        return;
      }

      final rootItems = _extractList(body, keys: const ['data', 'categories', 'items', 'result']);
      final parsed = <MarketplaceCategoryNode>[];
      final selectedIds = <int>[];
      for (final item in rootItems) {
        if (item is Map) {
          final category = MarketplaceCategoryNode.fromJson(Map<String, dynamic>.from(item));
          parsed.add(category);
          _collectSelectedMarketplaceCategoryIds(category, selectedIds);
        }
      }

      marketplaceCategories.assignAll(parsed);
      selectedCategoryIds.assignAll(selectedIds.toSet().toList());
      if (parsed.isEmpty) {
        categoryError.value = 'No categories available for this store.';
      }
    } catch (e) {
      categoryError.value = e.toString();
      marketplaceCategories.clear();
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> initializeMarketplaceCategories({String? storeId}) async {
    final resolvedStoreId = storeId?.trim() ?? '';

    if (resolvedStoreId.isNotEmpty) {
      selectedStoreId.value = resolvedStoreId;
      GetStorage().write('storeId', resolvedStoreId);
      GetStorage().write('shopId', resolvedStoreId);
      GetStorage().write('selected_store_id', resolvedStoreId);
    } else if (selectedStoreId.value.isEmpty) {
      selectedStoreId.value = _resolveMarketplaceStoreId();
    }

    await loadMarketplaceCategories();
  }

  bool isMarketplaceCategorySelected(MarketplaceCategoryNode category) {
    final id = category.id;
    return id != null && selectedCategoryIds.contains(id);
  }

  void toggleMarketplaceCategory(MarketplaceCategoryNode category, bool selected) {
    final id = category.id;
    if (id == null) return;

    final currentIds = selectedCategoryIds.toList();
    if (selected) {
      if (!currentIds.contains(id)) currentIds.add(id);
    } else {
      currentIds.removeWhere((item) => item == id);
    }

    selectedCategoryIds.assignAll(currentIds);
  }

  Future<void> syncMarketplaceCategories() async {
    final resolvedStoreId = _resolveMarketplaceStoreId();

    if (resolvedStoreId.isEmpty) {
      categoryError.value = 'No store selected.';
      return;
    }

    try {
      isCategorySyncing.value = true;
      categoryError.value = '';

      final response = await _productRepository.syncStoreCategories(
        storeId: resolvedStoreId,
        categoryIds: selectedCategoryIds.toList(),
      );
      final statusCode = response['status_code'] is int ? response['status_code'] as int : 500;
      final body = response['body'];

      if (statusCode < 200 || statusCode >= 300) {
        final message = _categoryApiErrorMessage(statusCode, body);
        categoryError.value = message;
        if (statusCode == 401) {
          Get.offAllNamed(Routes.LOGIN);
        } else {
          Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
        }
        return;
      }

      Get.snackbar(
        'Success',
        'Store categories synced successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      await loadMarketplaceCategories();
      await loadActiveCategories();
    } catch (e) {
      categoryError.value = 'Failed to sync categories.';
      Get.snackbar(
        'Error',
        categoryError.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isCategorySyncing.value = false;
    }
  }

  String _resolveMarketplaceStoreId() {
    if (selectedStoreId.value.isNotEmpty) {
      return selectedStoreId.value;
    }

    final authShopId =
        Get.find<AuthService>().currentUser.value.data?.user?.shop?.id;
    if (authShopId != null) {
      return authShopId.toString();
    }

    final savedStoreId = GetStorage().read('storeId') ??
        GetStorage().read('shopId') ??
        GetStorage().read('selected_store_id');

    return savedStoreId?.toString() ?? '';
  }

  void _collectSelectedMarketplaceCategoryIds(
    MarketplaceCategoryNode category,
    List<int> results,
  ) {
    final id = category.id;
    if (id != null && category.isActiveForStore) {
      results.add(id);
    }

    for (final child in category.children) {
      _collectSelectedMarketplaceCategoryIds(child, results);
    }
  }

  String _categoryApiErrorMessage(int statusCode, dynamic body) {
    if (statusCode == 403) return 'You do not have permission.';
    if (statusCode == 404) return 'Store not found or access denied.';
    if (statusCode == 422) {
      final payload = body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};
      final errors = payload['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final messages = <String>[];
        errors.forEach((_, value) {
          if (value is List) {
            messages.addAll(value.map((item) => item.toString()));
          } else if (value != null) {
            messages.add(value.toString());
          }
        });
        if (messages.isNotEmpty) return messages.join('\n');
      }
      return payload['message']?.toString() ?? 'Please check your selected categories.';
    }

    return 'Failed to sync categories.';
  }

  String generateSlug(String value) {
    final normalized = value
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
    return normalized.isEmpty ? 'product' : normalized;
  }

  Future<bool> createSellerProduct({
    required String name,
    required String slug,
    required String categoryId,
    required String unitPrice,
    required String currentStock,
    required String? brandId,
    required String? purchasePrice,
    required String? unit,
    required String? weight,
    required String? shortDescription,
    required String? description,
    required String? discount,
    required String? discountType,
    required bool todaysDeal,
    required bool published,
    required bool featured,
    required bool refundable,
    required bool cashOnDelivery,
    required bool stockVisibility,
    required List<XFile> images,
  }) async {
    if (selectedStoreId.value.isEmpty) {
      addProductError.value = 'Please select a store first.';
      return false;
    }

    if (images.isEmpty) {
      addProductError.value = 'Please select at least one image for the product.';
      return false;
    }

    if (categoryId.isEmpty) {
      addProductError.value = 'Please select an active product category.';
      return false;
    }

    final user = Get.find<AuthService>().currentUser.value.data?.user;
    final userId = user?.id?.toString();
    if (userId == null || userId.isEmpty) {
      addProductError.value = 'Seller session expired.';
      return false;
    }

    try {
      isCreatingProduct.value = true;
      addProductError.value = '';

      final Map<String, String> fields = {
        'name': name.trim(),
        'slug': slug.trim(),
        'category_id': categoryId,
        'added_by': userId,
        'user_id': userId,
        'shop_id': selectedStoreId.value,
        'description': description?.trim() ?? '',
        'unit_price': unitPrice,
        'purchase_price': purchasePrice?.trim().isNotEmpty == true ? purchasePrice! : '0',
        'current_stock': currentStock,
        'variant_product': '0',
        'todays_deal': todaysDeal ? '1' : '0',
        'published': published ? '1' : '0',
        'approved': '1',
        'featured': featured ? '1' : '0',
        'refundable': refundable ? '1' : '0',
        'cash_on_delivery': cashOnDelivery ? '1' : '0',
        'stock_visibility_state': stockVisibility ? '1' : '0',
        'unit': unit?.trim().isNotEmpty == true ? unit! : 'pcs',
        'weight': weight?.trim().isNotEmpty == true ? weight! : '0',
        'short_description': shortDescription?.trim() ?? '',
      };

      if (brandId != null && brandId.isNotEmpty) {
        fields['brand_id'] = brandId;
      }

      final discountValue = double.tryParse(discount ?? '0') ?? 0;
      if (discountValue > 0) {
        fields['discount'] = discountValue.toString();
        fields['discount_type'] = (discountType == 'percent' ? 'percent' : 'amount');
      }

      final response = await _productRepository.createProduct(
        fields: fields,
        images: images,
      );

      final statusCode = response['status_code'] is int ? response['status_code'] as int : 500;
      final body = response['body'];
      final payload = body is Map ? Map<String, dynamic>.from(body) : <String, dynamic>{};

      if (statusCode < 200 || statusCode >= 300) {
        final errors = payload['errors'];
        String message = payload['message']?.toString() ?? 'Unable to create product';
        if (errors is Map && errors.isNotEmpty) {
          final values = errors.values.whereType<List>().expand((e) => e).toList();
          if (values.isNotEmpty) {
            message = values.first.toString();
          }
        }
        addProductError.value = message;
        return false;
      }

      final productId = _extractProductId(payload);
      if (productId == null) {
        addProductError.value = 'Product created but product id was not returned by the backend.';
        return false;
      }

      if (images.isNotEmpty) {
        final uploadResponse = await _productRepository.uploadProductImages(
          productId: productId,
          images: images,
        );
        final uploadStatus = uploadResponse['status_code'] is int ? uploadResponse['status_code'] as int : 500;
        final uploadBody = uploadResponse['body'];
        if (uploadStatus < 200 || uploadStatus >= 300) {
          final uploadPayload = uploadBody is Map ? Map<String, dynamic>.from(uploadBody) : <String, dynamic>{};
          addProductError.value = uploadPayload['message']?.toString() ?? 'Product was created but images could not be uploaded.';
          return false;
        }
      }

      return true;
    } catch (e) {
      addProductError.value = e.toString();
      return false;
    } finally {
      isCreatingProduct.value = false;
    }
  }

  int? _extractProductId(Map<String, dynamic> payload) {
    final dynamic dataValue = payload['data'];
    if (dataValue is Map) {
      final nested = Map<String, dynamic>.from(dataValue);
      final directId = nested['id'];
      if (directId != null) return int.tryParse(directId.toString());

      final nestedData = nested['data'];
      if (nestedData is Map) {
        final nestedId = nestedData['id'];
        if (nestedId != null) return int.tryParse(nestedId.toString());
      }
    }

    final id = payload['id'];
    if (id != null) return int.tryParse(id.toString());

    return null;
  }

  List<dynamic> _extractList(dynamic body, {required List<String> keys}) {
    if (body is List) return body;
    if (body is Map) {
      final map = Map<String, dynamic>.from(body);
      for (final key in keys) {
        final child = map[key];
        if (child is List) return child;
        if (child is Map) {
          final nested = Map<String, dynamic>.from(child);
          for (final nestedKey in keys) {
            final nestedChild = nested[nestedKey];
            if (nestedChild is List) return nestedChild;
          }
        }
      }
    }
    return <dynamic>[];
  }

  void _collectActiveCategories(Map<String, dynamic> node, List<SellerCategoryOption> results) {
    final dynamic children = node['children'] ?? node['subcategories'] ?? node['sub_categories'] ?? node['children_data'] ?? node['categories'];
    final bool isActive = _isTruthy(node['is_active_for_store']) ||
        _isTruthy(node['is_active']) ||
        _isTruthy(node['active']) ||
        _isTruthy(node['status']);

    final dynamic idValue = node['id'];
    final dynamic nameValue = node['name'];
    if (idValue != null && nameValue != null) {
      results.add(
        SellerCategoryOption(
          id: int.tryParse(idValue.toString()) ?? 0,
          name: nameValue.toString(),
          isActiveForStore: isActive,
        ),
      );
    }

    if (children is List) {
      for (final child in children) {
        if (child is Map) {
          _collectActiveCategories(Map<String, dynamic>.from(child), results);
        }
      }
    }

    if (children is Map) {
      _collectActiveCategories(Map<String, dynamic>.from(children), results);
    }
  }

  bool _isTruthy(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;
    final text = value?.toString().toLowerCase();
    return text == '1' || text == 'true' || text == 'yes' || text == 'active';
  }
}

class SellerCategoryOption {
  final int id;
  final String name;
  final bool isActiveForStore;

  SellerCategoryOption({
    required this.id,
    required this.name,
    required this.isActiveForStore,
  });
}

class SellerBrandOption {
  final int id;
  final String name;

  SellerBrandOption({
    required this.id,
    required this.name,
  });

  factory SellerBrandOption.fromJson(Map<String, dynamic> json) {
    return SellerBrandOption(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? json['brand_name']?.toString() ?? 'Brand',
    );
  }
}

class MarketplaceCategoryNode {
  final int? id;
  final int? parentId;
  final String name;
  final String slug;
  final bool isActiveForStore;
  final List<MarketplaceCategoryNode> children;
  final String? icon;
  final String? coverImage;
  final String? banner;

  MarketplaceCategoryNode({
    this.id,
    this.parentId,
    required this.name,
    required this.slug,
    required this.isActiveForStore,
    this.children = const [],
    this.icon,
    this.coverImage,
    this.banner,
  });

  factory MarketplaceCategoryNode.fromJson(Map<String, dynamic> json) {
    final children = (json['children'] is List)
        ? (json['children'] as List)
            .whereType<Map>()
            .map((item) => MarketplaceCategoryNode.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <MarketplaceCategoryNode>[];

    return MarketplaceCategoryNode(
      id: int.tryParse(json['id']?.toString() ?? ''),
      parentId: int.tryParse(json['parent_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? 'Category',
      slug: json['slug']?.toString() ?? '',
      isActiveForStore: _categoryActiveValue(json['is_active_for_store']),
      children: children,
      icon: json['icon']?.toString(),
      coverImage: json['cover_image']?.toString(),
      banner: json['banner']?.toString(),
    );
  }
}

bool _categoryActiveValue(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value == 1;
  final text = value?.toString().toLowerCase().trim();
  return text == '1' || text == 'true' || text == 'yes' || text == 'active';
}
