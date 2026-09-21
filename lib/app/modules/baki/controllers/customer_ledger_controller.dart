import 'package:ecom_delivery_flutter/app/models/baki/baki_summary_model.dart';
import 'package:ecom_delivery_flutter/app/models/baki/customer_ledger_model.dart';
import 'package:ecom_delivery_flutter/app/modules/baki/controllers/baki_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:ecom_delivery_flutter/app/repositories/baki_repository.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CustomerLedgerController extends GetxController {
  final BakiRepository _repository = BakiRepository();

  int? customerId;
  final Rx<BakiCustomerItem?> customerItem = Rx<BakiCustomerItem?>(null);
  final Rx<CustomerLedgerInfo?> customerInfo = Rx<CustomerLedgerInfo?>(null);
  final RxDouble totalBaki = 0.0.obs;

  final RxList<LedgerItem> ledgers = <LedgerItem>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isActionLoading = false.obs;

  int currentPage = 1;
  int lastPage = 1;

  final ScrollController scrollController = ScrollController();

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
    if (saved != null && saved.toString().isNotEmpty) {
      return saved.toString();
    }

    return '';
  }

  @override
  void onInit() {
    super.onInit();
    _initFromArguments();
    scrollController.addListener(_onScroll);
    if (customerId != null) {
      loadLedger(refresh: true);
    }
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _initFromArguments() {
    final args = Get.arguments;
    if (args is Map) {
      if (args['customerId'] != null) {
        customerId = int.tryParse(args['customerId'].toString());
      }
      if (args['customer'] is BakiCustomerItem) {
        customerItem.value = args['customer'] as BakiCustomerItem;
        customerId ??= customerItem.value?.customerId;
        totalBaki.value = customerItem.value?.totalBaki ?? 0.0;
      }
    } else if (args is int) {
      customerId = args;
    } else if (Get.parameters['customerId'] != null) {
      customerId = int.tryParse(Get.parameters['customerId']!);
    }
  }

  void _onScroll() {
    if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore.value && currentPage < lastPage) {
        loadMore();
      }
    }
  }

  String _extractErrorMessage(dynamic body, String fallback) {
    if (body is Map) {
      if (body['errors'] != null) {
        final errors = body['errors'];
        if (errors is Map) {
          if (errors['error'] != null &&
              errors['error'].toString().trim().isNotEmpty) {
            return errors['error'].toString().trim();
          }
          final values = errors.values
              .expand((v) => v is Iterable ? v : [v])
              .where((item) => item != null && item.toString().trim().isNotEmpty)
              .map((e) => e.toString().trim())
              .toList();
          if (values.isNotEmpty) return values.first;
        } else if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        } else if (errors is String && errors.trim().isNotEmpty) {
          return errors.trim();
        }
      }
      if (body['message'] != null &&
          body['message'].toString().trim().isNotEmpty) {
        return body['message'].toString().trim();
      }
    }
    return fallback;
  }

  Future<void> loadLedger({bool refresh = false}) async {
    final storeId = currentStoreId;
    if (storeId.isEmpty || customerId == null) {
      return;
    }

    if (refresh) {
      currentPage = 1;
      isLoading.value = true;
    }

    try {
      final response = await _repository.fetchCustomerLedger(
        storeId: storeId,
        customerId: customerId!,
        page: currentPage,
      );
      final statusCode = response['status_code'] as int? ?? 500;
      final body = response['body'];

      if (statusCode >= 200 && statusCode < 300) {
        if (body is Map && body['data'] is Map) {
          final ledgerData = CustomerLedgerData.fromJson(
            Map<String, dynamic>.from(body['data']),
          );

          if (ledgerData.customer != null) {
            customerInfo.value = ledgerData.customer;
          }
          totalBaki.value = ledgerData.totalBaki;

          final pagination = ledgerData.ledgers;
          if (pagination != null) {
            lastPage = pagination.lastPage;
            if (refresh) {
              ledgers.assignAll(pagination.data);
            } else {
              ledgers.addAll(pagination.data);
            }
          }
        }
      } else {
        final message = _extractErrorMessage(body, 'Failed to fetch customer ledger');
        Get.showSnackbar(Ui.ErrorSnackBar(
          title: 'common.error'.tr,
          message: message,
        ));
      }
    } catch (e) {
      debugPrint('Error loading customer ledger: $e');
      Get.showSnackbar(Ui.ErrorSnackBar(
        title: 'common.error'.tr,
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    } finally {
      if (refresh) {
        isLoading.value = false;
      }
    }
  }

  Future<void> loadMore() async {
    if (currentPage >= lastPage || isLoadingMore.value) return;

    isLoadingMore.value = true;
    currentPage++;

    try {
      final response = await _repository.fetchCustomerLedger(
        storeId: currentStoreId,
        customerId: customerId!,
        page: currentPage,
      );
      final statusCode = response['status_code'] as int? ?? 500;
      final body = response['body'];

      if (statusCode >= 200 && statusCode < 300) {
        if (body is Map && body['data'] is Map) {
          final ledgerData = CustomerLedgerData.fromJson(
            Map<String, dynamic>.from(body['data']),
          );

          if (ledgerData.ledgers != null) {
            final newItems = ledgerData.ledgers!.data;
            ledgers.addAll(newItems);
            lastPage = ledgerData.ledgers!.lastPage;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading more ledgers: $e');
      currentPage--;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<bool> collectPayment({
    required double amount,
    required String paymentMethod,
    String? note,
    String? dueDate,
  }) async {
    if (customerId == null) return false;

    // Use BakiController if registered to keep global sync
    if (Get.isRegistered<BakiController>()) {
      final ok = await Get.find<BakiController>().collectPayment(
        customerId: customerId!,
        amount: amount,
        paymentMethod: paymentMethod,
        note: note,
        dueDate: dueDate,
      );
      if (ok) {
        await loadLedger(refresh: true);
        return true;
      }
      return false;
    }

    final storeId = currentStoreId;
    if (storeId.isEmpty) return false;

    isActionLoading.value = true;
    try {
      final body = <String, dynamic>{
        'customer_id': customerId,
        'amount': amount,
        'payment_method': paymentMethod,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        if (dueDate != null && dueDate.trim().isNotEmpty) 'due_date': dueDate.trim(),
      };

      final response = await _repository.collectPayment(storeId: storeId, body: body);
      final statusCode = response['status_code'] as int? ?? 500;
      final responseBody = response['body'];

      if (statusCode >= 200 && statusCode < 300) {
        Get.showSnackbar(Ui.SuccessSnackBar(
          title: 'common.success'.tr,
          message: 'baki.paymentCollectedSuccess'.tr,
        ));
        await loadLedger(refresh: true);
        return true;
      } else {
        final message = _extractErrorMessage(responseBody, 'Failed to collect payment');
        Get.showSnackbar(Ui.ErrorSnackBar(
          title: 'common.error'.tr,
          message: message,
        ));
        return false;
      }
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        title: 'common.error'.tr,
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> quickAddBaki({
    required double amount,
    String? note,
    String? dueDate,
  }) async {
    if (customerId == null) return false;

    if (Get.isRegistered<BakiController>()) {
      final ok = await Get.find<BakiController>().quickAddBaki(
        customerId: customerId!,
        amount: amount,
        note: note,
        dueDate: dueDate,
      );
      if (ok) {
        await loadLedger(refresh: true);
        return true;
      }
      return false;
    }

    final storeId = currentStoreId;
    if (storeId.isEmpty) return false;

    isActionLoading.value = true;
    try {
      final body = <String, dynamic>{
        'customer_id': customerId,
        'amount': amount,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        if (dueDate != null && dueDate.trim().isNotEmpty) 'due_date': dueDate.trim(),
      };

      final response = await _repository.quickAddBaki(storeId: storeId, body: body);
      final statusCode = response['status_code'] as int? ?? 500;
      final responseBody = response['body'];

      if (statusCode >= 200 && statusCode < 300) {
        Get.showSnackbar(Ui.SuccessSnackBar(
          title: 'common.success'.tr,
          message: 'baki.bakiAddedSuccess'.tr,
        ));
        await loadLedger(refresh: true);
        return true;
      } else {
        final message = _extractErrorMessage(responseBody, 'Failed to add Baki');
        Get.showSnackbar(Ui.ErrorSnackBar(
          title: 'common.error'.tr,
          message: message,
        ));
        return false;
      }
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        title: 'common.error'.tr,
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }
}
