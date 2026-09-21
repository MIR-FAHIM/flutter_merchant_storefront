import 'dart:async';
import 'package:ecom_delivery_flutter/app/models/baki/baki_summary_model.dart';
import 'package:ecom_delivery_flutter/app/models/baki/customer_ledger_model.dart';
import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:ecom_delivery_flutter/app/repositories/baki_repository.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BakiController extends GetxController {
  final BakiRepository _repository = BakiRepository();

  final Rx<BakiSummaryData?> bakiSummary = Rx<BakiSummaryData?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxInt selectedTabIndex = 0.obs;

  List<BakiCustomerItem> get filteredCustomers {
    final list = bakiSummary.value?.customers ?? [];
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((c) {
      final name = (c.name ?? '').toLowerCase();
      final phone = (c.phone ?? '').toLowerCase();
      return name.contains(q) || phone.contains(q);
    }).toList();
  }

  List<LedgerItem> get recentEntries => bakiSummary.value?.recentLedgerEntries ?? [];

  void setTab(int index) {
    selectedTabIndex.value = index;
  }

  // Search
  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  Timer? _debounceTimer;

  // Collect Payment Form State
  final TextEditingController collectAmountController = TextEditingController();
  final TextEditingController collectNoteController = TextEditingController();
  final RxString collectSelectedMethod = 'cash'.obs;
  final Rxn<DateTime> collectSelectedDueDate = Rxn<DateTime>();

  // Quick Add Baki Form State
  final TextEditingController quickAddAmountController = TextEditingController();
  final TextEditingController quickAddNoteController = TextEditingController();
  final Rxn<DateTime> quickAddSelectedDueDate = Rxn<DateTime>();

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
    searchController.addListener(_onSearchChanged);
    loadBakiSummary();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    searchController.dispose();
    collectAmountController.dispose();
    collectNoteController.dispose();
    quickAddAmountController.dispose();
    quickAddNoteController.dispose();
    super.onClose();
  }

  void initCollectPayment(BakiCustomerItem customer) {
    collectAmountController.clear();
    collectNoteController.clear();
    collectSelectedMethod.value = 'cash';
    collectSelectedDueDate.value = null;
  }

  void initQuickAdd(BakiCustomerItem customer) {
    quickAddAmountController.clear();
    quickAddNoteController.clear();
    quickAddSelectedDueDate.value = null;
  }

  void _onSearchChanged() {
    final text = searchController.text.trim();
    if (searchQuery.value == text) return;
    searchQuery.value = text;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      loadBakiSummary(query: searchQuery.value, showLoading: false);
    });
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    loadBakiSummary();
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

  Future<void> loadBakiSummary({String? query, bool showLoading = true}) async {
    final storeId = currentStoreId;
    if (storeId.isEmpty) {
      debugPrint('No store ID available for Baki summary');
      return;
    }

    if (showLoading) {
      isLoading.value = true;
    }

    try {
      final response = await _repository.fetchBakiSummary(
        storeId: storeId,
        search: query != null && query.isNotEmpty ? query : null,
      );
      final statusCode = response['status_code'] as int? ?? 500;
      final body = response['body'];

      if (statusCode >= 200 && statusCode < 300) {
        if (body is Map && body['data'] is Map) {
          bakiSummary.value = BakiSummaryData.fromJson(
            Map<String, dynamic>.from(body['data']),
          );
        } else {
          bakiSummary.value = null;
        }
      } else {
        final message = _extractErrorMessage(body, 'Failed to fetch Baki summary');
        Get.showSnackbar(Ui.ErrorSnackBar(
          title: 'common.error'.tr,
          message: message,
        ));
      }
    } catch (e) {
      debugPrint('Error loading Baki summary: $e');
      Get.showSnackbar(Ui.ErrorSnackBar(
        title: 'common.error'.tr,
        message: e.toString().replaceFirst('Exception: ', ''),
      ));
    } finally {
      if (showLoading) {
        isLoading.value = false;
      }
    }
  }

  Future<bool> collectPayment({
    required int customerId,
    required double amount,
    required String paymentMethod,
    String? note,
    String? dueDate,
  }) async {
    final storeId = currentStoreId;
    if (storeId.isEmpty) return false;

    isActionLoading.value = true;
    try {
      final body = <String, dynamic>{
        'customer_id': customerId,
        'collected_amount': amount,
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
        await loadBakiSummary(query: searchQuery.value, showLoading: false);
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
      debugPrint('Error collecting payment: $e');
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
    required int customerId,
    required double amount,
    String? note,
    String? dueDate,
  }) async {
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
        await loadBakiSummary(query: searchQuery.value, showLoading: false);
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
      debugPrint('Error adding baki: $e');
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
