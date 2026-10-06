import 'package:ecom_delivery_flutter/app/models/reports/shop_cash_flow_report_model.dart';
import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:ecom_delivery_flutter/app/repositories/shop_cash_flow_repository.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class ShopCashFlowController extends GetxController {
  ShopCashFlowController({ShopCashFlowRepository? repository})
      : _repository = repository ?? ShopCashFlowRepository();

  final ShopCashFlowRepository _repository;

  // Reactive state
  final Rx<ShopCashFlowReportData?> reportData = Rx<ShopCashFlowReportData?>(null);
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;

  // Filter state
  final RxString selectedPeriod = 'today'.obs; // 'today', 'yesterday', 'this_week', 'this_month', 'custom'
  final Rxn<DateTime> customStartDate = Rxn<DateTime>();
  final Rxn<DateTime> customEndDate = Rxn<DateTime>();

  // Expansion state for collapsible report sections
  final RxBool isLedgerTableExpanded = false.obs;
  final RxBool isBottomSummaryExpanded = false.obs;

  void toggleLedgerTable() => isLedgerTableExpanded.toggle();
  void toggleBottomSummary() => isBottomSummaryExpanded.toggle();

  // Quick Action Form Controllers & State
  // 1. Set Opening Cash
  final TextEditingController openingAmountController = TextEditingController();
  final TextEditingController openingNoteController = TextEditingController();
  final Rx<DateTime> openingDate = Rx<DateTime>(DateTime.now());

  // 2. Quick Cash Sale
  final TextEditingController quickAmountController = TextEditingController();
  final TextEditingController quickNoteController = TextEditingController();

  // 3. Add Expense
  final TextEditingController expenseAmountController = TextEditingController();
  final TextEditingController expenseNoteController = TextEditingController();
  final RxString expenseCategory = 'Tea & Snacks'.obs;
  static const List<String> expenseCategories = [
    'Tea & Snacks',
    'Transport',
    'Utility',
    'Supplier Payment',
    'Other',
  ];

  // 4. Adjust Cash Drawer
  final TextEditingController drawerActualCashController = TextEditingController();
  final TextEditingController drawerNoteController = TextEditingController();
  final RxString drawerReason = 'Rush Hour Unlogged Sales'.obs;
  static const List<String> drawerReasons = [
    'Rush Hour Unlogged Sales',
    'Change Correction',
    'Unrecorded Cash Out',
    'Other',
  ];

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

    final authUserShop = Get.isRegistered<AuthService>()
        ? Get.find<AuthService>()
        .currentUser
        .value
        .data
        ?.user
        ?.shop
        ?.id
        ?.toString()
        : null;
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
    fetchReport();
  }

  @override
  void onClose() {
    openingAmountController.dispose();
    openingNoteController.dispose();
    quickAmountController.dispose();
    quickNoteController.dispose();
    expenseAmountController.dispose();
    expenseNoteController.dispose();
    drawerActualCashController.dispose();
    drawerNoteController.dispose();
    super.onClose();
  }

  // --- Filter Methods ---

  void setPeriod(String period) {
    selectedPeriod.value = period;
    customStartDate.value = null;
    customEndDate.value = null;
    fetchReport();
  }

  void changePeriod(String period) => setPeriod(period);

  void applyCustomDateRange(DateTime start, DateTime end) {
    selectedPeriod.value = 'custom';
    customStartDate.value = start;
    customEndDate.value = end;
    fetchReport();
  }

  // Grouped rows getter for grouped master table
  Map<String, List<LedgerRowItem>> get groupedLedgerRows {
    final map = <String, List<LedgerRowItem>>{
      'OPENING_BALANCE': [],
      'REVENUE_INFLOW': [],
      'CASH_OUTFLOW': [],
      'DRAWER_ADJUSTMENT': [],
      'BAKI_FLOW': [],
    };

    final rows = reportData.value?.ledgerRows ?? [];
    for (var row in rows) {
      final sec = row.section.trim();
      if (map.containsKey(sec)) {
        map[sec]!.add(row);
      } else {
        map.putIfAbsent(sec, () => []).add(row);
      }
    }
    return map;
  }

  // --- Fetch Summary Report ---
  Future<void> fetchReport() async {
    final storeId = currentStoreId;
    if (storeId.isEmpty) return;

    isLoading.value = true;
    try {
      String? apiPeriod;
      String? fromDate;
      String? toDate;

      if (selectedPeriod.value == 'custom' &&
          customStartDate.value != null &&
          customEndDate.value != null) {
        fromDate = DateFormat('yyyy-MM-dd').format(customStartDate.value!);
        toDate = DateFormat('yyyy-MM-dd').format(customEndDate.value!);
      } else {
        switch (selectedPeriod.value) {
          case 'yesterday':
            apiPeriod = 'yesterday';
            break;
          case 'this_week':
          case 'weekly':
            apiPeriod = 'weekly';
            break;
          case 'this_month':
          case 'monthly':
            apiPeriod = 'monthly';
            break;
          case 'today':
          default:
            apiPeriod = 'today';
            break;
        }
      }

      final response = await _repository.fetchSummaryReport(
        storeId: storeId,
        period: apiPeriod,
        from: fromDate,
        to: toDate,
      );

      final statusCode = response['status_code'];
      final body = response['body'];

      if (statusCode == 200 && body is Map<String, dynamic>) {
        if (body['data'] != null && body['data'] is Map<String, dynamic>) {
          reportData.value =
              ShopCashFlowReportData.fromJson(body['data'] as Map<String, dynamic>);
        } else {
          reportData.value = ShopCashFlowReportData.fromJson(body);
        }
      } else {
        final errMsg = body is Map && body['message'] != null
            ? body['message'].toString()
            : 'Could not load cash flow report'.tr;
        Get.showSnackbar(Ui.ErrorSnackBar(message: errMsg));
      }
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
    } finally {
      isLoading.value = false;
    }
  }

  // --- Quick Action 1: Set Morning Opening Cash Drawer ---
  void initOpeningForm() {
    openingAmountController.clear();
    openingNoteController.clear();
    openingDate.value = DateTime.now();
  }

  Future<bool> submitOpeningCash() async {
    final storeId = currentStoreId;
    if (!_canSubmitCashAction(storeId)) return false;
    final amount = double.tryParse(openingAmountController.text.trim());
    if (amount == null || !amount.isFinite || amount < 0) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: 'Please enter a valid cash amount'.tr));
      return false;
    }

    isActionLoading.value = true;
    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(openingDate.value);
      final body = <String, dynamic>{
        'amount': amount,
        'entry_date': formattedDate,
      };
      if (openingNoteController.text.trim().isNotEmpty) {
        body['note'] = openingNoteController.text.trim();
      }

      final response = await _repository.setOpeningCash(
        storeId: storeId,
        body: body,
      );

      final statusCode = response['status_code'];
      final respBody = response['body'];

      if (statusCode == 200 || statusCode == 201) {
        Get.showSnackbar(Ui.SuccessSnackBar(
          message: respBody is Map && respBody['message'] != null
              ? respBody['message'].toString()
              : 'Opening cash drawer recorded successfully'.tr,
        ));
        await fetchReport();
        return true;
      } else {
        final msg = respBody is Map && respBody['message'] != null
            ? respBody['message'].toString()
            : 'Failed to set opening cash'.tr;
        Get.showSnackbar(Ui.ErrorSnackBar(message: msg));
        return false;
      }
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  // --- Quick Action 2: Quick Cash Sale (No Cart) ---
  void initQuickCashForm() {
    quickAmountController.clear();
    quickNoteController.clear();
  }

  Future<bool> submitQuickCash() async {
    final storeId = currentStoreId;
    if (!_canSubmitCashAction(storeId)) return false;
    final amount = double.tryParse(quickAmountController.text.trim());
    if (amount == null || amount <= 0) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: 'Please enter a valid cash sale amount'.tr));
      return false;
    }

    isActionLoading.value = true;
    try {
      final body = <String, dynamic>{
        'amount': amount,
      };
      if (quickNoteController.text.trim().isNotEmpty) {
        body['note'] = quickNoteController.text.trim();
      }

      final response = await _repository.recordQuickCash(
        storeId: storeId,
        body: body,
      );

      final statusCode = response['status_code'];
      final respBody = response['body'];

      if (statusCode == 200 || statusCode == 201) {
        Get.showSnackbar(Ui.SuccessSnackBar(
          message: respBody is Map && respBody['message'] != null
              ? respBody['message'].toString()
              : 'Quick cash sale recorded successfully'.tr,
        ));
        await fetchReport();
        return true;
      } else {
        final msg = respBody is Map && respBody['message'] != null
            ? respBody['message'].toString()
            : 'Failed to record quick cash sale'.tr;
        Get.showSnackbar(Ui.ErrorSnackBar(message: msg));
        return false;
      }
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  // --- Quick Action 3: Add Daily Shop Expense ---
  void initExpenseForm() {
    expenseAmountController.clear();
    expenseNoteController.clear();
    expenseCategory.value = expenseCategories.first;
  }

  Future<bool> submitExpense() async {
    final storeId = currentStoreId;
    if (!_canSubmitCashAction(storeId)) return false;
    final amount = double.tryParse(expenseAmountController.text.trim());
    if (amount == null || amount <= 0) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: 'Please enter a valid expense amount'.tr));
      return false;
    }

    isActionLoading.value = true;
    try {
      final body = <String, dynamic>{
        'amount': amount,
        'category': expenseCategory.value,
      };
      if (expenseNoteController.text.trim().isNotEmpty) {
        body['note'] = expenseNoteController.text.trim();
      }

      final response = await _repository.addExpense(
        storeId: storeId,
        body: body,
      );

      final statusCode = response['status_code'];
      final respBody = response['body'];

      if (statusCode == 200 || statusCode == 201) {
        Get.showSnackbar(Ui.SuccessSnackBar(
          message: respBody is Map && respBody['message'] != null
              ? respBody['message'].toString()
              : 'Shop expense added successfully'.tr,
        ));
        await fetchReport();
        return true;
      } else {
        final msg = respBody is Map && respBody['message'] != null
            ? respBody['message'].toString()
            : 'Failed to add expense'.tr;
        Get.showSnackbar(Ui.ErrorSnackBar(message: msg));
        return false;
      }
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  // --- Quick Action 4: Adjust Cash Drawer (Tally Fix) ---
  void initAdjustDrawerForm() {
    drawerActualCashController.clear();
    drawerNoteController.clear();
    drawerReason.value = drawerReasons.first;
  }

  Future<bool> submitAdjustDrawer() async {
    final storeId = currentStoreId;
    if (!_canSubmitCashAction(storeId)) return false;
    final actualCash = double.tryParse(drawerActualCashController.text.trim());
    if (actualCash == null || actualCash < 0) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: 'Please enter actual cash in hand'.tr));
      return false;
    }

    isActionLoading.value = true;
    try {
      final body = <String, dynamic>{
        'actual_cash': actualCash,
        'reason': drawerReason.value,
      };
      if (drawerNoteController.text.trim().isNotEmpty) {
        body['note'] = drawerNoteController.text.trim();
      }

      final response = await _repository.adjustDrawer(
        storeId: storeId,
        body: body,
      );

      final statusCode = response['status_code'];
      final respBody = response['body'];

      if (statusCode == 200 || statusCode == 201) {
        Get.showSnackbar(Ui.SuccessSnackBar(
          message: respBody is Map && respBody['message'] != null
              ? respBody['message'].toString()
              : 'Cash drawer adjustment recorded'.tr,
        ));
        await fetchReport();
        return true;
      } else {
        final msg = respBody is Map && respBody['message'] != null
            ? respBody['message'].toString()
            : 'Failed to adjust drawer'.tr;
        Get.showSnackbar(Ui.ErrorSnackBar(message: msg));
        return false;
      }
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<ShopCashFlowReportData> fetchReportForDate({
    required String storeId,
    required DateTime date,
  }) async {
    final day = DateFormat('yyyy-MM-dd').format(date);
    final response = await _repository.fetchSummaryReport(
      storeId: storeId, from: day, to: day,
    );
    final body = response['body'];
    if (response['status_code'] == 200 && body is Map &&
        !['error', 'failed'].contains(body['status'])) {
      return ShopCashFlowReportResponse.fromJson(
        Map<String, dynamic>.from(body),
      ).data ?? ShopCashFlowReportData.fromJson(Map<String, dynamic>.from(body));
    }
    throw Exception(_cashActionError(body));
  }

  Future<bool> submitOwnerDeposit({
    required String storeId,
    required double amount,
    required DateTime date,
    String note = '',
  }) {
    if (!amount.isFinite || amount <= 0) {
      _cashValidationError('cashbox.positiveAmount');
      return Future.value(false);
    }
    return _submitCashAction(
      storeId: storeId,
      request: () => _repository.recordOwnerDeposit(
        storeId: storeId,
        body: {
          'amount': amount,
          'entry_date': DateFormat('yyyy-MM-dd').format(date),
          'category': 'Owner Cash Deposit',
          'note': note.trim(),
        },
      ),
    );
  }

  Future<bool> submitOwnerWithdrawal({
    required String storeId,
    required double amount,
    required DateTime date,
    String note = '',
  }) {
    if (!amount.isFinite || amount <= 0) {
      _cashValidationError('cashbox.positiveAmount');
      return Future.value(false);
    }
    return _submitCashAction(
      storeId: storeId,
      request: () => _repository.recordOwnerWithdrawal(
        storeId: storeId,
        body: {
          'amount': amount,
          'entry_date': DateFormat('yyyy-MM-dd').format(date),
          'category': 'Owner Withdrawal',
          'note': note.trim(),
        },
      ),
    );
  }

  Future<bool> submitClosingCash({
    required String storeId,
    required double actualCash,
    required double carryForwardAmount,
    required DateTime date,
    required bool setNextOpening,
    String note = '',
  }) {
    if (!actualCash.isFinite || actualCash < 0 ||
        !carryForwardAmount.isFinite || carryForwardAmount < 0) {
      _cashValidationError('cashbox.nonnegativeAmount');
      return Future.value(false);
    }
    if (carryForwardAmount > actualCash) {
      _cashValidationError('cashbox.carryExceedsClosing');
      return Future.value(false);
    }
    return _submitCashAction(
      storeId: storeId,
      request: () => _repository.recordClosingCash(
        storeId: storeId,
        body: {
          'actual_cash': actualCash,
          'entry_date': DateFormat('yyyy-MM-dd').format(date),
          'carry_forward_amount': carryForwardAmount,
          'set_next_opening': setNextOpening,
          'note': note.trim(),
        },
      ),
    );
  }

  Future<bool> submitCarryForward({
    required String storeId,
    required double amount,
    required DateTime fromDate,
    required DateTime toDate,
    String note = '',
  }) {
    if (!amount.isFinite || amount < 0) {
      _cashValidationError('cashbox.nonnegativeAmount');
      return Future.value(false);
    }
    final fromDay = DateTime(fromDate.year, fromDate.month, fromDate.day);
    final toDay = DateTime(toDate.year, toDate.month, toDate.day);
    if (!toDay.isAfter(fromDay)) {
      _cashValidationError('cashbox.laterDate');
      return Future.value(false);
    }
    return _submitCashAction(
      storeId: storeId,
      request: () => _repository.recordCarryForward(
        storeId: storeId,
        body: {
          'amount': amount,
          'from_date': DateFormat('yyyy-MM-dd').format(fromDate),
          'to_date': DateFormat('yyyy-MM-dd').format(toDate),
          'note': note.trim(),
        },
      ),
    );
  }

  void _cashValidationError(String key) {
    Get.showSnackbar(Ui.ErrorSnackBar(message: key.tr));
  }

  bool _canSubmitCashAction(String storeId) {
    if (isActionLoading.value) return false;
    if (storeId.isEmpty || storeId != currentStoreId) {
      _cashValidationError('cashbox.selectStore');
      return false;
    }
    return true;
  }

  String _cashActionError(dynamic body) {
    if (body is Map) {
      final errors = body['errors'];
      if (errors is Map && errors.isNotEmpty) {
        return errors.values
            .expand((value) => value is List ? value : [value])
            .map((value) => value.toString())
            .join('\n');
      }
      if (body['message'] != null) return body['message'].toString();
    }
    return 'cashbox.requestFailed'.tr;
  }

  Future<bool> _submitCashAction({
    required String storeId,
    required Future<Map<String, dynamic>> Function() request,
  }) async {
    if (!_canSubmitCashAction(storeId)) return false;
    isActionLoading.value = true;
    try {
      final response = await request();
      final code = response['status_code'] as int? ?? 500;
      final body = response['body'];
      if (code >= 200 && code < 300 &&
          !(body is Map && ['error', 'failed'].contains(body['status']))) {
        Get.showSnackbar(Ui.SuccessSnackBar(
          message: body is Map && body['message'] != null
              ? body['message'].toString() : 'cashbox.saved'.tr,
        ));
        await fetchReport();
        return true;
      }
      Get.showSnackbar(Ui.ErrorSnackBar(message: _cashActionError(body)));
      return false;
    } catch (e) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: e.toString()));
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }
}
