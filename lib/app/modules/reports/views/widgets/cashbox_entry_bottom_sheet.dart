import 'package:ecom_delivery_flutter/app/models/reports/shop_cash_flow_report_model.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/controllers/shop_cash_flow_controller.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

enum CashboxEntryType { deposit, withdrawal, closing, carryForward }

class CashboxEntryBottomSheet extends StatefulWidget {
  const CashboxEntryBottomSheet({
    super.key,
    required this.controller,
    required this.storeId,
    required this.type,
  });

  final ShopCashFlowController controller;
  final String storeId;
  final CashboxEntryType type;

  static Future<void> show({
    required BuildContext context,
    required ShopCashFlowController controller,
    required CashboxEntryType type,
  }) async {
    final storeId = controller.currentStoreId;
    if (storeId.isEmpty) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: 'cashbox.selectStore'.tr));
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: const Color(0xFF202428),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CashboxEntryBottomSheet(
        controller: controller,
        storeId: storeId,
        type: type,
      ),
    );
  }

  @override
  State<CashboxEntryBottomSheet> createState() =>
      _CashboxEntryBottomSheetState();
}

class _CashboxEntryBottomSheetState extends State<CashboxEntryBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _carryAmount = TextEditingController(text: '0');
  final _withdrawalAmount = TextEditingController();
  final _note = TextEditingController();
  DateTime _date = DateTime.now();
  late DateTime _toDate;
  bool _setNextOpening = false;
  bool _loadingDaily = false;
  bool _withdrawalSaved = false;
  String? _dailyError;
  ShopCashFlowReportData? _dailyReport;
  int _dailyRequest = 0;

  bool get _isClosing => widget.type == CashboxEntryType.closing;
  bool get _isCarry => widget.type == CashboxEntryType.carryForward;
  bool get _busy => widget.controller.isActionLoading.value || _loadingDaily;
  String get _titleKey {
    switch (widget.type) {
      case CashboxEntryType.deposit:
        return 'cashbox.deposit';
      case CashboxEntryType.withdrawal:
        return 'cashbox.withdrawal';
      case CashboxEntryType.closing:
        return 'cashbox.closing';
      case CashboxEntryType.carryForward:
        return 'cashbox.carryForward';
    }
  }

  @override
  void initState() {
    super.initState();
    _toDate = DateTime(_date.year, _date.month, _date.day + 1);
    if (_isClosing) _loadDailyReport();
  }

  @override
  void dispose() {
    _amount.dispose();
    _carryAmount.dispose();
    _withdrawalAmount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _loadDailyReport() async {
    final request = ++_dailyRequest;
    setState(() {
      _loadingDaily = true;
      _dailyError = null;
      _dailyReport = null;
    });
    try {
      final report = await widget.controller.fetchReportForDate(
        storeId: widget.storeId,
        date: _date,
      );
      if (mounted && request == _dailyRequest) {
        setState(() => _dailyReport = report);
      }
    } catch (e) {
      if (mounted && request == _dailyRequest) {
        setState(() => _dailyError = e.toString());
      }
    } finally {
      if (mounted && request == _dailyRequest) {
        setState(() => _loadingDaily = false);
      }
    }
  }

  double? _readAmount(String text) {
    final normalized = text
        .trim()
        .replaceAll(',', '')
        .runes
        .map((rune) => rune >= 0x09E6 && rune <= 0x09EF
            ? String.fromCharCode(rune - 0x09E6 + 48)
            : String.fromCharCode(rune))
        .join();
    final amount = double.tryParse(normalized);
    return amount != null && amount.isFinite ? amount : null;
  }

  Future<void> _pickDate({bool target = false}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: target ? _toDate : _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (target) {
        _toDate = picked;
      } else {
        _date = picked;
        _toDate = DateTime(picked.year, picked.month, picked.day + 1);
        _withdrawalSaved = false;
      }
    });
    if (_isClosing && !target) await _loadDailyReport();
  }

  void _error(String key) =>
      Get.showSnackbar(Ui.ErrorSnackBar(message: key.tr));

  Future<void> _recordWithdrawal() async {
    if (_busy) return;
    final actual = _readAmount(_amount.text);
    final withdrawal = _readAmount(_withdrawalAmount.text);
    final carry = _readAmount(_carryAmount.text);
    if (actual == null || actual < 0) {
      _error('cashbox.nonnegativeAmount');
      return;
    }
    if (withdrawal == null || withdrawal <= 0) {
      _error('cashbox.positiveAmount');
      return;
    }
    if (withdrawal > actual ||
        carry == null ||
        carry < 0 ||
        carry > actual - withdrawal) {
      _error('cashbox.withdrawalExceedsCash');
      return;
    }
    final saved = await widget.controller.submitOwnerWithdrawal(
      storeId: widget.storeId,
      amount: withdrawal,
      date: _date,
      note: _note.text,
    );
    if (!mounted || !saved) return;
    setState(() {
      _amount.text = (actual - withdrawal).toStringAsFixed(2);
      _withdrawalAmount.clear();
      _withdrawalSaved = true;
    });
    await _loadDailyReport();
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    if (_isClosing && _withdrawalAmount.text.trim().isNotEmpty) {
      _error('cashbox.recordWithdrawalFirst');
      return;
    }
    if (_isClosing && _dailyReport == null) return;
    final amount = _readAmount(_amount.text)!;
    final controller = widget.controller;
    final bool saved;
    switch (widget.type) {
      case CashboxEntryType.deposit:
        saved = await controller.submitOwnerDeposit(
            storeId: widget.storeId,
            amount: amount,
            date: _date,
            note: _note.text);
      case CashboxEntryType.withdrawal:
        saved = await controller.submitOwnerWithdrawal(
            storeId: widget.storeId,
            amount: amount,
            date: _date,
            note: _note.text);
      case CashboxEntryType.closing:
        saved = await controller.submitClosingCash(
            storeId: widget.storeId,
            actualCash: amount,
            carryForwardAmount: _readAmount(_carryAmount.text)!,
            date: _date,
            setNextOpening: _setNextOpening,
            note: _note.text);
      case CashboxEntryType.carryForward:
        saved = await controller.submitCarryForward(
            storeId: widget.storeId,
            amount: amount,
            fromDate: _date,
            toDate: _toDate,
            note: _note.text);
    }
    if (saved && mounted) Navigator.of(context).pop();
  }

  Widget _amountField(String key, TextEditingController input,
      {bool positive = false, bool required = true}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: input,
        enabled: !_busy,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: key.tr,
          prefixText: '৳ ',
          filled: true,
          fillColor: const Color(0xFF292E33),
          border: const OutlineInputBorder(),
          errorMaxLines: 3,
        ),
        validator: (value) {
          if (!required && (value ?? '').trim().isEmpty) return null;
          final amount = _readAmount(value ?? '');
          if (amount == null || (positive ? amount <= 0 : amount < 0)) {
            return (positive
                    ? 'cashbox.positiveAmount'
                    : 'cashbox.nonnegativeAmount')
                .tr;
          }
          if (input == _carryAmount &&
              amount > (_readAmount(_amount.text) ?? 0)) {
            return 'cashbox.carryExceedsClosing'.tr;
          }
          return null;
        },
      ),
    );
  }

  Widget _dateButton(String label, DateTime date, {bool target = false}) {
    return OutlinedButton.icon(
      onPressed: _busy ? null : () => _pickDate(target: target),
      icon: const Icon(Icons.calendar_today_outlined, size: 16),
      label: Text('${label.tr}: ${DateFormat('yyyy-MM-dd').format(date)}'),
    );
  }

  Widget _notice(String key, {Color color = const Color(0xFFFBBF24)}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(key.tr, style: TextStyle(color: color, fontSize: 12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Subscribe to the shared request state even when a field builds first.
      final actionLoading = widget.controller.isActionLoading.value;
      return PopScope(
        canPop: !actionLoading && !_loadingDaily,
        child: Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(primary: Color(0xFF34D399)),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  16, 12, 16, MediaQuery.of(context).viewInsets.bottom + 16),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Text(_titleKey.tr,
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700))),
                          IconButton(
                            tooltip: 'cashbox.close'.tr,
                            onPressed:
                                _busy ? null : () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      _dateButton(
                          _isCarry ? 'cashbox.fromDate' : 'Date', _date),
                      if (_isCarry)
                        _dateButton('cashbox.toDate', _toDate, target: true),
                      const SizedBox(height: 12),
                      if (widget.type == CashboxEntryType.deposit)
                        _notice('cashbox.depositWarning'),
                      if (widget.type == CashboxEntryType.withdrawal)
                        _notice('cashbox.withdrawalWarning'),
                      if (_isCarry) _notice('cashbox.carryHelp'),
                      if (_isClosing) ...[
                        if (_loadingDaily) const LinearProgressIndicator(),
                        if (_dailyError != null) ...[
                          Text(_dailyError!,
                              style: const TextStyle(color: Colors.redAccent)),
                          TextButton.icon(
                            onPressed: _busy ? null : _loadDailyReport,
                            icon: const Icon(Icons.refresh_rounded),
                            label: Text('cashbox.retry'.tr),
                          ),
                        ],
                        if (_dailyReport != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '${'cashbox.expected'.tr}: ৳${NumberFormat.decimalPattern(Get.locale?.languageCode == 'bn' ? 'bn' : 'en').format(_dailyReport!.kpiCards?.expectedCashInDrawer ?? 0)}',
                              style: const TextStyle(
                                  color: Color(0xFF34D399),
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        _notice('cashbox.closingHelp'),
                      ],
                      _amountField(
                        _isClosing ? 'cashbox.actualClosing' : 'cashbox.amount',
                        _amount,
                        positive: !_isClosing && !_isCarry,
                      ),
                      if (_isClosing) ...[
                        _amountField('cashbox.carryAmount', _carryAmount),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text('cashbox.setNextOpening'.tr,
                              style: const TextStyle(fontSize: 13)),
                          value: _setNextOpening,
                          onChanged: _busy
                              ? null
                              : (value) => setState(
                                  () => _setNextOpening = value ?? false),
                        ),
                        const Divider(),
                        _notice('cashbox.withdrawalWarning'),
                        _amountField(
                            'cashbox.withdrawalOptional', _withdrawalAmount,
                            positive: true, required: false),
                        OutlinedButton.icon(
                          onPressed: _busy || _dailyReport == null
                              ? null
                              : _recordWithdrawal,
                          icon: const Icon(Icons.north_east_rounded, size: 16),
                          label: Text('cashbox.recordWithdrawal'.tr),
                        ),
                        if (_withdrawalSaved)
                          _notice('cashbox.withdrawalRecorded',
                              color: const Color(0xFF34D399)),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: _note,
                        enabled: !_busy,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Note (Optional)'.tr,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _busy || (_isClosing && _dailyReport == null)
                            ? null
                            : _submit,
                        icon: actionLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.check_rounded, size: 18),
                        label: Text((_isClosing
                                ? 'cashbox.saveClosing'
                                : 'cashbox.save')
                            .tr),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
