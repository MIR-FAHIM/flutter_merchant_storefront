import 'package:ecom_delivery_flutter/app/models/pos/pos_cart_model.dart';
import 'package:ecom_delivery_flutter/app/models/product/product_response_model.dart';
import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:ecom_delivery_flutter/app/repositories/pos_repository.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PosCartController extends GetxController {
  final PosRepository _repository = PosRepository();

  // Multi-counter state
  final RxString selectedCounter = 'Counter 1'.obs;
  final List<String> defaultCounters = const ['Counter 1', 'Counter 2', 'Counter 3'];

  // Cart state
  final Rx<PosCartModel?> activeCart = Rx<PosCartModel?>(null);
  final RxList<PosCartModel> heldCarts = <PosCartModel>[].obs;

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isCartActionLoading = false.obs;
  final RxBool isHeldListLoading = false.obs;
  final RxBool isCheckingOut = false.obs;
  final RxInt addingProductId = 0.obs;

  // Computed getters
  int get totalItems {
    final cart = activeCart.value;
    if (cart == null) return 0;
    if (cart.totalItems > 0) return cart.totalItems;
    return cart.items.fold<int>(0, (sum, i) => sum + i.qty);
  }

  double get subtotal {
    final cart = activeCart.value;
    if (cart == null) return 0.0;
    if (cart.subtotal > 0) return cart.subtotal;
    return cart.items.fold<double>(0.0, (sum, i) => sum + i.lineTotal);
  }

  bool get isCartEmpty => totalItems == 0;

  List<PosCartItemModel> get items => activeCart.value?.items ?? [];

  /// Resolve current store ID
  String get currentStoreId {
    if (Get.isRegistered<ProductController>()) {
      final productCtrl = Get.find<ProductController>();
      if (productCtrl.selectedStoreId.value.isNotEmpty) {
        return productCtrl.selectedStoreId.value;
      }
      if (productCtrl.shopId.isNotEmpty) {
        return productCtrl.shopId;
      }
    }

    final authUserShop = Get.find<AuthService>()
        .currentUser
        .value
        .data
        ?.user
        ?.shop
        ?.id
        ?.toString();
    if (authUserShop != null && authUserShop.isNotEmpty) {
      return authUserShop;
    }

    final box = GetStorage();
    final saved = box.read('storeId') ??
        box.read('shopId') ??
        box.read('selected_store_id');
    return saved?.toString() ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    final savedCounter = GetStorage().read('pos_active_counter');
    if (savedCounter != null && savedCounter.toString().isNotEmpty) {
      selectedCounter.value = savedCounter.toString();
    }
    fetchActiveCart();
  }

  /// Switch Counter and reload cart for the selected counter
  Future<void> switchCounter(String newCounter) async {
    if (newCounter.trim().isEmpty) return;
    selectedCounter.value = newCounter.trim();
    GetStorage().write('pos_active_counter', selectedCounter.value);
    await fetchActiveCart();
  }

  /// A. Fetch Active Cart for current counter
  Future<void> fetchActiveCart() async {
    final storeId = currentStoreId;
    if (storeId.isEmpty) {
      debugPrint('POS: storeId is empty, skipping fetchActiveCart');
      return;
    }

    try {
      isLoading.value = true;
      final cart = await _repository.fetchActiveCart(
        storeId: storeId,
        counterName: selectedCounter.value,
      );
      if (cart != null) {
        activeCart.value = cart;
      } else {
        // Initialize empty cart state
        activeCart.value = PosCartModel(
          counterName: selectedCounter.value,
          totalItems: 0,
          subtotal: 0.0,
          items: [],
        );
      }
    } catch (e) {
      debugPrint('Error fetching active POS cart: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// B. Add Product to Active Cart
  Future<bool> addItem({
    required ProductData product,
    int qty = 1,
    double? customPrice,
    String? customerName,
    String? customerPhone,
  }) async {
    final storeId = currentStoreId;
    if (storeId.isEmpty) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        message: 'pos.noActiveStore'.tr,
      ));
      return false;
    }

    final productId = product.id;
    if (productId == null) return false;

    addingProductId.value = productId;
    try {
      final unitPrice = customPrice ?? product.unitPrice ?? 0.0;
      final body = <String, dynamic>{
        'counter_name': selectedCounter.value,
        'product_id': productId,
        'qty': qty,
        'unit_price': unitPrice,
        if (customerName != null && customerName.trim().isNotEmpty)
          'customer_name': customerName.trim(),
        if (customerPhone != null && customerPhone.trim().isNotEmpty)
          'customer_phone': customerPhone.trim(),
      };

      // If product has a separate store_product_id, send it
      if (product.id != null) {
        body['store_product_id'] = product.id;
      }

      final updatedCart = await _repository.addItem(
        storeId: storeId,
        body: body,
      );

      if (updatedCart != null) {
        activeCart.value = updatedCart;
        Get.showSnackbar(Ui.SuccessSnackBar(
          title: 'pos.cartUpdated'.tr,
          message: '${product.name ?? 'Product'} ${'pos.itemAddedToCounter'.tr} (${selectedCounter.value})',
        ));
        return true;
      }
      return false;
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    } finally {
      addingProductId.value = 0;
    }
  }

  /// C. Update Item Quantity
  Future<void> updateItemQty({
    required PosCartItemModel item,
    required int newQty,
  }) async {
    if (item.id == null) return;

    if (newQty <= 0) {
      await removeItem(itemId: item.id!);
      return;
    }

    final storeId = currentStoreId;
    if (storeId.isEmpty) return;

    try {
      isCartActionLoading.value = true;
      final body = <String, dynamic>{
        'qty': newQty,
        'unit_price': item.unitPrice,
        if (item.note != null && item.note!.isNotEmpty) 'note': item.note,
      };

      final updated = await _repository.updateItem(
        storeId: storeId,
        itemId: item.id!,
        body: body,
      );

      if (updated != null) {
        activeCart.value = updated;
      }
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    } finally {
      isCartActionLoading.value = false;
    }
  }

  /// C2. Update Item Custom Price or Note
  Future<void> updateItemDetails({
    required PosCartItemModel item,
    required double newUnitPrice,
    String? note,
  }) async {
    if (item.id == null) return;
    final storeId = currentStoreId;
    if (storeId.isEmpty) return;

    try {
      isCartActionLoading.value = true;
      final body = <String, dynamic>{
        'qty': item.qty,
        'unit_price': newUnitPrice,
        'note': note ?? item.note,
      };

      final updated = await _repository.updateItem(
        storeId: storeId,
        itemId: item.id!,
        body: body,
      );

      if (updated != null) {
        activeCart.value = updated;
        Get.showSnackbar(Ui.SuccessSnackBar(
          message: 'pos.itemUpdated'.tr,
        ));
      }
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    } finally {
      isCartActionLoading.value = false;
    }
  }

  /// D. Remove Item from Cart
  Future<void> removeItem({required int itemId}) async {
    final storeId = currentStoreId;
    if (storeId.isEmpty) return;

    try {
      isCartActionLoading.value = true;
      final updated = await _repository.removeItem(
        storeId: storeId,
        itemId: itemId,
      );

      if (updated != null) {
        activeCart.value = updated;
        Get.showSnackbar(Ui.SuccessSnackBar(
          message: 'pos.itemRemoved'.tr,
        ));
      }
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
    } finally {
      isCartActionLoading.value = false;
    }
  }

  /// E. Park / Hold Cart
  Future<PosHoldCartResponse?> holdCart({
    String? reason,
    String? customerName,
    String? customerPhone,
  }) async {
    final storeId = currentStoreId;
    if (storeId.isEmpty) return null;

    try {
      isCartActionLoading.value = true;
      final body = <String, dynamic>{
        'counter_name': selectedCounter.value,
        'hold_reason': (reason != null && reason.trim().isNotEmpty)
            ? reason.trim()
            : 'Parked bill',
        if (customerName != null && customerName.trim().isNotEmpty)
          'customer_name': customerName.trim(),
        if (customerPhone != null && customerPhone.trim().isNotEmpty)
          'customer_phone': customerPhone.trim(),
      };

      final response = await _repository.holdCart(
        storeId: storeId,
        body: body,
      );

      if (response != null) {
        activeCart.value = response.newActiveCart ??
            PosCartModel(
              counterName: selectedCounter.value,
              totalItems: 0,
              subtotal: 0.0,
              items: [],
            );
        return response;
      }
      return null;
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
      return null;
    } finally {
      isCartActionLoading.value = false;
    }
  }

  /// F. List All Parked Bills
  Future<void> loadHeldCarts() async {
    final storeId = currentStoreId;
    if (storeId.isEmpty) return;

    try {
      isHeldListLoading.value = true;
      final list = await _repository.fetchHeldList(storeId: storeId);
      heldCarts.assignAll(list);
    } catch (e) {
      debugPrint('Error fetching held carts: $e');
    } finally {
      isHeldListLoading.value = false;
    }
  }

  /// G. Resume Parked Bill
  Future<bool> resumeCart({required String holdCode}) async {
    final storeId = currentStoreId;
    if (storeId.isEmpty) return false;

    try {
      isCartActionLoading.value = true;
      final body = <String, dynamic>{
        'hold_code': holdCode,
        'counter_name': selectedCounter.value,
      };

      final resumed = await _repository.resumeCart(
        storeId: storeId,
        body: body,
      );

      if (resumed != null) {
        activeCart.value = resumed;
        heldCarts.removeWhere((c) => c.holdCode == holdCode);
        Get.showSnackbar(Ui.SuccessSnackBar(
          message: '$holdCode ${'pos.billResumed'.tr}',
        ));
        return true;
      }
      return false;
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
      return false;
    } finally {
      isCartActionLoading.value = false;
    }
  }

  /// H. Checkout Cart (Complete Sale)
  Future<PosCheckoutResponse?> checkout({
    required String paymentMethod,
    required double paidAmount,
    String? customerName,
    String? customerPhone,
    String? note,
    String? dueDate,
    int? customerId,
  }) async {
    final storeId = currentStoreId;
    final cartId = activeCart.value?.id;
    if (storeId.isEmpty || cartId == null) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        message: 'pos.noActiveCartCheckout'.tr,
      ));
      return null;
    }

    try {
      isCheckingOut.value = true;
      final body = <String, dynamic>{
        'cart_id': cartId,
        'payment_method': paymentMethod.toLowerCase(),
        'paid_amount': paidAmount,
        if (dueDate != null && dueDate.trim().isNotEmpty)
          'due_date': dueDate.trim(),
        if (customerId != null)
          'customer_id': customerId,
        if (customerName != null && customerName.trim().isNotEmpty)
          'customer_name': customerName.trim(),
        if (customerPhone != null && customerPhone.trim().isNotEmpty)
          'customer_phone': customerPhone.trim(),
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      };

      final result = await _repository.checkout(
        storeId: storeId,
        body: body,
      );

      if (result != null) {
        // Reset local cart to blank
        activeCart.value = PosCartModel(
          counterName: selectedCounter.value,
          totalItems: 0,
          subtotal: 0.0,
          items: [],
        );
        return result;
      }
      return null;
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        message: e.toString().replaceAll('Exception: ', ''),
      ));
      return null;
    } finally {
      isCheckingOut.value = false;
    }
  }
}
