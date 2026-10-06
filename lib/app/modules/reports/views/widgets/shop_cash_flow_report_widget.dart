import 'dart:ui' show FontFeature;

import 'package:ecom_delivery_flutter/app/models/reports/shop_cash_flow_report_model.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/controllers/shop_cash_flow_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/widgets/add_expense_bottom_sheet.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/widgets/cashbox_entry_bottom_sheet.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/widgets/adjust_cash_drawer_bottom_sheet.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/widgets/quick_cash_sale_bottom_sheet.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/widgets/set_opening_cash_bottom_sheet.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/common/Color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ShopCashFlowReportWidget extends GetWidget<ShopCashFlowController> {
  const ShopCashFlowReportWidget({super.key});

  static const Color _green = Color(0xFF10B981);
  static const Color _blue = Color(0xFF38BDF8);
  static const Color _amber = Color(0xFFFBBF24);
  static const Color _red = Color(0xFFF87171);
  static const Color _cyan = Color(0xFF2DD4BF);

  @override
  ShopCashFlowController get controller {
    if (Get.isRegistered<ShopCashFlowController>()) {
      return Get.find<ShopCashFlowController>();
    }
    return Get.put(ShopCashFlowController());
  }

  Future<void> _pickCustomDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now.add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: controller.customStartDate.value ?? now.subtract(const Duration(days: 7)),
        end: controller.customEndDate.value ?? now,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: _green,
              onPrimary: Colors.white,
              surface: const Color(0xFF1B1C1E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      controller.applyCustomDateRange(picked.start, picked.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            const Color(0xFF0F766E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.24),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Obx(() {
        if (controller.isLoading.value && controller.reportData.value == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header with Store & Refresh
            _buildHeader(context),
            const SizedBox(height: 14),

            // 2. Date Filter Controls Toolbar
            _buildDateFilterToolbar(context),
            const SizedBox(height: 14),

            // 3. Quick Action Shortcuts
            _buildQuickActionShortcuts(context),
            const SizedBox(height: 16),

            // 4. Top 4 KPI Summary Cards (Interactive)
            _buildKpiCardsGrid(context),
            const SizedBox(height: 18),

            // 5. Master Financial & Cash Ledger Table (Interactive)
            _buildMasterLedgerTable(context),

          ],
        );
      }),
    );
  }

  // --- Header ---
  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.table_chart_outlined, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cash Flow & Ledger Report'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${'Store'.tr} #${controller.currentStoreId} • 360° ${'Audit View'.tr}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Get.toNamed(Routes.CASH_FLOW_GUIDE),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amberAccent.withOpacity(0.65), width: 1.2),
            ),
            child: const Icon(Icons.lightbulb_rounded, color: Colors.amberAccent, size: 18),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => controller.fetchReport(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: controller.isLoading.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  // --- Date Filter Controls Toolbar ---
  Widget _buildDateFilterToolbar(BuildContext context) {
    final presets = [
      {'id': 'today', 'label': 'Today'.tr},
      {'id': 'yesterday', 'label': 'Yesterday'.tr},
      {'id': 'this_week', 'label': 'This Week'.tr},
      {'id': 'this_month', 'label': 'This Month'.tr},
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.20),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Reporting Period'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Custom Date Range Button
              Flexible(
                child: InkWell(
                  onTap: () => _pickCustomDateRange(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: controller.selectedPeriod.value == 'custom'
                          ? Colors.white
                          : Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_calendar_outlined,
                          size: 13,
                          color: controller.selectedPeriod.value == 'custom'
                              ? const Color(0xFF0F766E)
                              : Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Custom Range'.tr,
                            style: TextStyle(
                              color: controller.selectedPeriod.value == 'custom'
                                  ? const Color(0xFF0F766E)
                                  : Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: presets.map((p) {
                final isSelected = controller.selectedPeriod.value == p['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(p['label']!),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        controller.setPeriod(p['id']!);
                      }
                    },
                    selectedColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.12),
                    labelStyle: TextStyle(
                      color: isSelected ? const Color(0xFF0F766E) : Colors.grey,
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.18),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  ),
                );
              }).toList(),
            ),
          ),
          if (controller.reportData.value?.from != null &&
              controller.reportData.value?.to != null) ...[
            const SizedBox(height: 6),
            Text(
              '${'Active Range'.tr}: ${_formatIso(controller.reportData.value?.from)} → ${_formatIso(controller.reportData.value?.to)}',
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ],
        ],
      ),
    );
  }

  // --- Quick Action Shortcuts ---
  Widget _buildQuickActionShortcuts(BuildContext context) {
    void entry(CashboxEntryType type) => CashboxEntryBottomSheet.show(
          context: context, controller: controller, type: type);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildShortcutButton(
          icon: Icons.wb_sunny_outlined,
          title: 'cashbox.opening'.tr,
          bgColor: _amber.withValues(alpha: 0.20),
          textColor: Colors.white,
          onTap: () => SetOpeningCashBottomSheet.show(
              context: context, controller: controller),
        ),
        _buildShortcutButton(
          icon: Icons.south_west_rounded,
          title: 'cashbox.deposit'.tr,
          bgColor: _green.withValues(alpha: 0.20),
          textColor: Colors.white,
          onTap: () => entry(CashboxEntryType.deposit),
        ),
        _buildShortcutButton(
          icon: Icons.north_east_rounded,
          title: 'cashbox.withdrawal'.tr,
          bgColor: _red.withValues(alpha: 0.20),
          textColor: Colors.white,
          onTap: () => entry(CashboxEntryType.withdrawal),
        ),
        _buildShortcutButton(
          icon: Icons.receipt_long_outlined,
          title: 'cashbox.expense'.tr,
          bgColor: _red.withValues(alpha: 0.20),
          textColor: Colors.white,
          onTap: () => AddExpenseBottomSheet.show(
              context: context, controller: controller),
        ),
        _buildShortcutButton(
          icon: Icons.bolt_rounded,
          title: 'cashbox.quickSale'.tr,
          bgColor: _amber.withValues(alpha: 0.20),
          textColor: Colors.white,
          onTap: () => QuickCashSaleBottomSheet.show(
              context: context, controller: controller),
        ),
        _buildShortcutButton(
          icon: Icons.fact_check_outlined,
          title: 'cashbox.closing'.tr,
          bgColor: _blue.withValues(alpha: 0.20),
          textColor: Colors.white,
          onTap: () => entry(CashboxEntryType.closing),
        ),
        _buildShortcutButton(
          icon: Icons.calendar_month_outlined,
          title: 'cashbox.carryForward'.tr,
          bgColor: _cyan.withValues(alpha: 0.20),
          textColor: Colors.white,
          onTap: () => entry(CashboxEntryType.carryForward),
        ),
        _buildShortcutButton(
          icon: Icons.tune_rounded,
          title: 'cashbox.adjustment'.tr,
          bgColor: _cyan.withValues(alpha: 0.20),
          textColor: Colors.white,
          onTap: () => AdjustCashDrawerBottomSheet.show(
              context: context, controller: controller),
        ),
      ],
    );
  }

  Widget _buildShortcutButton({
    required IconData icon,
    required String title,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: textColor),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCardsGrid(BuildContext context) {
    final kpis = controller.reportData.value?.kpiCards ?? KpiCards();
    final amounts = CashboxAmounts.fromReport(controller.reportData.value);
    void adjustCash() => AdjustCashDrawerBottomSheet.show(
          context: context,
          controller: controller,
        );

    const cashGreen = Color(0xFF34D399);
    const dividerColor = Color(0xFF34383E);
    final isBangla = Get.locale?.languageCode == 'bn';

    return DefaultTextStyle.merge(
      style: TextStyle(fontFamily: isBangla ? 'BanglaFont' : null),
      child: Material(
        color: const Color(0xFF202428),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined,
                      size: 18, color: cashGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'cashSnapshot.title'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _buildReceiptRow(
                'cashSnapshot.opening'.tr,
                _formatSnapshotAmount(amounts.openingCash),
                _amber,
                icon: Icons.wb_sunny_outlined,
                onTap: () => SetOpeningCashBottomSheet.show(
                  context: context,
                  controller: controller,
                ),
              ),
              _buildReceiptRow(
                'cashbox.cashSales'.tr,
                '+ ${_formatSnapshotAmount(amounts.cashSales)}',
                cashGreen,
                icon: Icons.south_west_rounded,
                onTap: () => Get.toNamed(Routes.ORDER_SHOP_LIST),
              ),
              _buildReceiptRow(
                'cashbox.bakiCollection'.tr,
                '+ ${_formatSnapshotAmount(amounts.bakiCashCollection)}',
                cashGreen,
                icon: Icons.menu_book_outlined,
                onTap: () => Get.toNamed(Routes.BAKI_KHATA),
              ),
              _buildReceiptRow(
                'cashbox.deposit'.tr,
                '+ ${_formatSnapshotAmount(amounts.ownerDeposit)}',
                _blue,
                icon: Icons.south_west_rounded,
                onTap: () => CashboxEntryBottomSheet.show(
                  context: context, controller: controller,
                  type: CashboxEntryType.deposit),
              ),
              _buildReceiptRow(
                'cashbox.expense'.tr,
                '- ${_formatSnapshotAmount(amounts.expense)}',
                _red,
                icon: Icons.north_east_rounded,
                onTap: () => AddExpenseBottomSheet.show(
                  context: context,
                  controller: controller,
                ),
              ),
              _buildReceiptRow(
                'cashbox.withdrawal'.tr,
                '- ${_formatSnapshotAmount(amounts.ownerWithdrawal)}',
                _amber,
                icon: Icons.north_east_rounded,
                onTap: () => CashboxEntryBottomSheet.show(
                  context: context, controller: controller,
                  type: CashboxEntryType.withdrawal),
              ),
              if (amounts.refunds != 0)
                _buildReceiptRow(
                  'cashbox.refunds'.tr,
                  '- ${_formatSnapshotAmount(amounts.refunds)}',
                  _red,
                  icon: Icons.undo_rounded,
                ),
              if (amounts.drawerAdjustment != 0)
                _buildReceiptRow(
                  'cashSnapshot.adjustment'.tr,
                  '${amounts.drawerAdjustment > 0 ? '+' : '-'} ${_formatSnapshotAmount(amounts.drawerAdjustment.abs())}',
                  _blue,
                  icon: Icons.tune_rounded,
                  onTap: adjustCash,
                ),
              const Divider(height: 12, color: dividerColor),
              _buildReceiptRow(
                'cashSnapshot.expected'.tr,
                _formatSnapshotAmount(kpis.expectedCashInDrawer),
                cashGreen,
                icon: Icons.payments_outlined,
                isBold: true,
                onTap: adjustCash,
              ),
              const Divider(height: 12, color: dividerColor),
              _buildReceiptRow(
                'cashbox.actualClosing'.tr,
                kpis.actualClosingCash == null
                    ? 'cashbox.notClosed'.tr
                    : _formatSnapshotAmount(kpis.actualClosingCash!),
                _blue,
                icon: Icons.fact_check_outlined,
                onTap: () => CashboxEntryBottomSheet.show(
                  context: context, controller: controller,
                  type: CashboxEntryType.closing),
              ),
              if (kpis.drawerDifference != null)
                _buildReceiptRow(
                  'cashbox.difference'.tr,
                  '${kpis.drawerDifference! > 0 ? '+' : ''}${_formatSnapshotAmount(kpis.drawerDifference!)}',
                  kpis.drawerDifference!.abs() < 0.005 ? cashGreen : _red,
                  icon: Icons.compare_arrows_rounded,
                ),
              _buildReceiptRow(
                'cashbox.carryForward'.tr,
                _formatSnapshotAmount(kpis.carryForwardCash ?? 0),
                _cyan,
                icon: Icons.calendar_month_outlined,
                onTap: () => CashboxEntryBottomSheet.show(
                  context: context, controller: controller,
                  type: CashboxEntryType.carryForward),
              ),
              const Divider(height: 12, color: dividerColor),
              LayoutBuilder(
                builder: (context, constraints) {
                  final metrics = [
                    _buildSnapshotMetric(
                      'cashSnapshot.digital'.tr,
                      kpis.totalDigitalPayments,
                      Icons.phone_android_outlined,
                      _blue,
                      () => Get.toNamed(Routes.ORDER_SHOP_LIST),
                    ),
                    _buildSnapshotMetric(
                      'cashSnapshot.newBaki'.tr,
                      kpis.todayNewBaki,
                      Icons.assignment_late_outlined,
                      _amber,
                      () => Get.toNamed(Routes.BAKI_KHATA),
                    ),
                    _buildSnapshotMetric(
                      'cashSnapshot.totalBaki'.tr,
                      kpis.totalStoreOutstandingBaki,
                      Icons.menu_book_outlined,
                      _red,
                      () => Get.toNamed(Routes.BAKI_KHATA),
                    ),
                  ];
                  if (constraints.maxWidth < 240) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: metrics,
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < metrics.length; i++) ...[
                        if (i > 0) const SizedBox(width: 8),
                        Expanded(child: metrics[i]),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: adjustCash,
                      icon: const Icon(Icons.tune_rounded, size: 15),
                      label: Text('cashSnapshot.adjustAction'.tr,
                          textAlign: TextAlign.center),
                      style: TextButton.styleFrom(
                        foregroundColor: cashGreen,
                        backgroundColor: cashGreen.withValues(alpha: 0.10),
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        textStyle: TextStyle(
                          fontFamily: isBangla ? 'BanglaFont' : null,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => Get.toNamed(Routes.BAKI_KHATA),
                      icon: const Icon(Icons.menu_book_outlined, size: 15),
                      label: Text('cashSnapshot.bakiAction'.tr,
                          textAlign: TextAlign.center),
                      style: TextButton.styleFrom(
                        foregroundColor: _amber,
                        backgroundColor: _amber.withValues(alpha: 0.10),
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        textStyle: TextStyle(
                          fontFamily: isBangla ? 'BanglaFont' : null,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSnapshotAmount(double amount) {
    final formatter =
        NumberFormat.decimalPattern(Get.locale?.languageCode == 'bn' ? 'bn' : 'en')
          ..minimumFractionDigits = 0
          ..maximumFractionDigits = 2;
    return '৳${formatter.format(amount)}';
  }

  Widget _buildReceiptRow(
    String label,
    String value,
    Color valueColor, {
    required IconData icon,
    bool isBold = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: isBold ? 18 : 14, color: valueColor),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                label,
                style: TextStyle(
                  color: isBold ? Colors.white : const Color(0xFFCDD2D6),
                  fontSize: isBold ? 13 : 12,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: isBold ? 24 : 13,
                      fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnapshotMetric(
    String label,
    double amount,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(label,
                      style: const TextStyle(
                          color: Colors.white60, fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 3),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _formatSnapshotAmount(amount),
                  style: TextStyle(
                      color: color, fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Invoice-style cashbox statement ---
  Widget _buildMasterLedgerTable(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.isLedgerTableExpanded.value;
      final grouped = controller.groupedLedgerRows;
      final totalRowsCount = controller.reportData.value?.ledgerRows.length ?? 0;
      final data = controller.reportData.value;
      final expectedCash = data?.kpiCards?.expectedCashInDrawer ??
          data?.totals?.expectedCashDrawer ?? 0;
      final entryCount = NumberFormat.decimalPattern(
              Get.locale?.languageCode == 'bn' ? 'bn' : 'en')
          .format(totalRowsCount);

      final sectionConfigs = [
        {
          'key': 'OPENING_BALANCE',
          'title': 'OPENING CASH BALANCE'.tr,
          'icon': Icons.wb_sunny_outlined,
          'color': _amber,
        },
        {
          'key': 'REVENUE_INFLOW',
          'title': 'cashbox.cashInflow'.tr,
          'icon': Icons.arrow_downward_rounded,
          'color': const Color(0xFF6EE7B7),
        },
        {
          'key': 'CASH_OUTFLOW',
          'title': 'cashbox.cashOutflow'.tr,
          'icon': Icons.arrow_upward_rounded,
          'color': const Color(0xFFFCA5A5),
        },
        {
          'key': 'DRAWER_ADJUSTMENT',
          'title': 'DRAWER ADJUSTMENTS'.tr,
          'icon': Icons.tune_rounded,
          'color': const Color(0xFF5EEAD4),
        },
        {
          'key': 'BAKI_FLOW',
          'title': 'BAKI (CREDIT) MOVEMENT'.tr,
          'icon': Icons.account_balance_wallet_outlined,
          'color': const Color(0xFFFDE68A),
        },
        {
          'key': 'OWNER_DEPOSIT',
          'title': 'cashbox.deposit'.tr,
          'icon': Icons.south_west_rounded,
          'color': const Color(0xFF6EE7B7),
        },
        {
          'key': 'OWNER_WITHDRAWAL',
          'title': 'cashbox.withdrawal'.tr,
          'icon': Icons.north_east_rounded,
          'color': const Color(0xFFFCA5A5),
        },
        {
          'key': 'CLOSING_BALANCE',
          'title': 'cashbox.closing'.tr,
          'icon': Icons.fact_check_outlined,
          'color': _blue,
        },
        {
          'key': 'CARRY_FORWARD',
          'title': 'cashbox.carryForward'.tr,
          'icon': Icons.forward_rounded,
          'color': _amber,
        },
      ];

      // New backend ledger sections must remain visible in the full audit.
      for (final key in grouped.keys) {
        if (!sectionConfigs.any((config) => config['key'] == key)) {
          sectionConfigs.add({
            'key': key,
            'title': key.replaceAll('_', ' ').tr,
            'icon': Icons.receipt_long_outlined,
            'color': _blue,
          });
        }
      }

      return Container(
        key: const ValueKey('cash-ledger-invoice'),
        decoration: BoxDecoration(
          color: const Color(0xFF181A1D),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF3C4045)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 3, color: _amber),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.toggleLedgerTable,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          color: _amber, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'cashLedger.title'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${'Store'.tr} #${controller.currentStoreId}  |  '
                              '${'cashLedger.entries'.trParams({'count': entryCount})}',
                              style: const TextStyle(color: Colors.white60, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        key: const ValueKey('cash-ledger-toggle'),
                        tooltip: (isExpanded
                            ? 'cashLedger.hide' : 'cashLedger.show').tr,
                        onPressed: controller.toggleLedgerTable,
                        icon: AnimatedRotation(
                          turns: isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.keyboard_arrow_down_rounded,
                              color: Colors.white70, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (data?.from != null && data?.to != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: Text(
                  '${_formatIso(data?.from)} - ${_formatIso(data?.to)}',
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ),

            // Animated Expandable Content
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFF3C4045), height: 1),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(child: Text('cashLedger.particulars'.tr,
                            style: const TextStyle(color: Colors.white54,
                                fontSize: 10, fontWeight: FontWeight.w600))),
                        const SizedBox(width: 12),
                        Text('cashLedger.amount'.tr,
                            style: const TextStyle(color: Colors.white54,
                                fontSize: 10, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  if (totalRowsCount == 0)
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text('cashLedger.empty'.tr,
                          style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    ),

                  // Render Sections
                  ...sectionConfigs.map((sec) {
                    final key = sec['key'] as String;
                    final rows = grouped[key] ?? [];
                    if (rows.isEmpty) return const SizedBox.shrink();

                    final secTotal = _calculateSectionTotal(key, rows);
                    final secColor = sec['color'] as Color;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF222529),
                            border: Border(top: BorderSide(color: Color(0xFF34383D))),
                          ),
                          child: Row(
                            children: [
                              Icon(sec['icon'] as IconData, size: 14, color: secColor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  sec['title'] as String,
                                  style: TextStyle(
                                    color: secColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                  _formatSectionSubtotal(key, secTotal),
                                  maxLines: 1,
                                  textAlign: TextAlign.end,
                                  style: TextStyle(
                                    color: secTotal.abs() > 0.0001 ? secColor : Colors.white54,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                    fontFeatures: const [FontFeature.tabularFigures()],
                                  ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...rows.map((row) => _buildLedgerRow(context, row)),
                      ],
                    );
                  }),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                    decoration: const BoxDecoration(
                      border: Border(top: BorderSide(color: Color(0xFF60666D))),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: Text('cashLedger.expectedCash'.tr,
                            style: const TextStyle(color: Color(0xFF6EE7B7),
                                fontSize: 12, fontWeight: FontWeight.w700))),
                        const SizedBox(width: 12),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerRight,
                            child: Text(_formatSnapshotAmount(expectedCash),
                              maxLines: 1,
                              textAlign: TextAlign.end,
                              style: const TextStyle(color: Color(0xFF6EE7B7),
                                  fontSize: 16, fontWeight: FontWeight.w800,
                                  fontFeatures: [FontFeature.tabularFigures()]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      );
    });
  }

  double _calculateSectionTotal(String key, List<LedgerRowItem> rows) {
    double total = 0.0;
    for (final r in rows) {
      if (key == 'CASH_OUTFLOW') {
        total += r.debit;
      } else if (key == 'REVENUE_INFLOW' || key == 'OPENING_BALANCE') {
        total += r.credit;
      } else {
        total += r.netImpact;
      }
    }
    return total;
  }

  String _formatSectionSubtotal(String key, double total) {
    if (total.abs() <= 0.0001) return '৳0.00';
    if (key == 'CASH_OUTFLOW') {
      return '-৳${_formatCurrency(total)}';
    }
    if (key == 'REVENUE_INFLOW' || key == 'OPENING_BALANCE') {
      return '+৳${_formatCurrency(total)}';
    }
    if (key == 'DRAWER_ADJUSTMENT' || key == 'BAKI_FLOW') {
      final sign = total > 0 ? '+' : (total < 0 ? '-' : '');
      return '$sign৳${_formatCurrency(total.abs())}';
    }
    return '৳${_formatCurrency(total)}';
  }

  Widget _buildLedgerRow(BuildContext context, LedgerRowItem row) {
    final amount = _getLedgerAmount(row);
    final amountText = _formatRowAmount(row, amount);
    final amountColor = _getRowAmountColor(row, amount);
    final title = _getSmartLedgerTitle(row);
    final flowBadgeColor = _getFlowBadgeColor(row);
    final smartAction = _getSmartAction(context, row);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: smartAction?.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFF34383D), width: 0.6),
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: flowBadgeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                      if (row.flowType.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(row.flowType.tr,
                            style: const TextStyle(color: Colors.white54,
                                fontSize: 10, height: 1.4)),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: constraints.maxWidth * 0.4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          amountText,
                          maxLines: 1,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            color: amountColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      if (smartAction != null) ...[
                        const SizedBox(height: 3),
                        IconButton(
                          tooltip: smartAction.label,
                          onPressed: smartAction.onTap,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
                          icon: Icon(smartAction.icon ?? Icons.arrow_forward_rounded,
                              color: smartAction.color, size: 16),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getSmartLedgerTitle(LedgerRowItem row) {
    final title = row.title.toLowerCase();
    if (title.contains('owner') && title.contains('deposit')) return 'cashbox.deposit'.tr;
    if (title.contains('owner') && title.contains('withdrawal')) return 'cashbox.withdrawal'.tr;
    if (title.contains('closing')) return 'cashbox.closing'.tr;
    if (title.contains('carry')) return 'cashbox.carryForward'.tr;
    if (title.contains('opening')) return 'Opening Drawer Cash'.tr;
    if (title.contains('quick manual')) return 'Quick Manual Cash Sales'.tr;
    if (title.contains('pos')) return 'POS In-Store Cash Sales'.tr;
    if (title.contains('online') && title.contains('cod')) return 'Online COD Cash Collected'.tr;
    if (title.contains('baki recovered') && title.contains('payment')) return 'Baki Cash Recovered'.tr;
    if (title.contains('total baki recovered')) return 'Total Baki Recovered'.tr;
    if (title.contains('digital')) return 'Digital Payments (bKash/Nagad)'.tr;
    if (title.contains('expense')) return 'Shop Daily Expenses'.tr;
    if (title.contains('refund')) return 'Customer Cash Refunds'.tr;
    if (title.contains('adjust')) return 'Till Balance Adjustments'.tr;
    if (title.contains('new baki')) return 'New Baki Given (Unpaid)'.tr;
    return row.title.tr;
  }

  _SmartAction? _getSmartAction(BuildContext context, LedgerRowItem row) {
    final title = row.title.toLowerCase();
    final sec = row.section.toUpperCase();
    final amount = _getLedgerAmount(row);

    if (title.contains('opening')) {
      return _SmartAction(
        label: amount > 0.001 ? 'Edit Till'.tr : '+ Set Till'.tr,
        icon: amount > 0.001 ? Icons.edit_outlined : Icons.add_rounded,
        color: const Color(0xFF5EEAD4),
        onTap: () => SetOpeningCashBottomSheet.show(context: context, controller: controller),
      );
    }
    if (title.contains('quick manual')) {
      return _SmartAction(
        label: '+ Quick Sale'.tr,
        icon: Icons.add_rounded,
        color: const Color(0xFF6EE7B7),
        onTap: () => QuickCashSaleBottomSheet.show(context: context, controller: controller),
      );
    }
    if (title.contains('expense')) {
      return _SmartAction(
        label: '+ Expense'.tr,
        icon: Icons.remove_rounded,
        color: const Color(0xFFFCA5A5),
        onTap: () => AddExpenseBottomSheet.show(context: context, controller: controller),
      );
    }
    if (title.contains('adjust') || sec == 'DRAWER_ADJUSTMENT') {
      return _SmartAction(
        label: 'Adjust Till'.tr,
        icon: Icons.tune_rounded,
        color: const Color(0xFF5EEAD4),
        onTap: () => AdjustCashDrawerBottomSheet.show(context: context, controller: controller),
      );
    }
    if (sec == 'BAKI_FLOW' || title.contains('baki')) {
      return _SmartAction(
        label: 'Baki Khata'.tr,
        icon: Icons.menu_book_outlined,
        color: const Color(0xFFFDE68A),
        onTap: () => Get.toNamed(Routes.BAKI_KHATA),
      );
    }
    if (title.contains('pos') || title.contains('sales') || title.contains('digital') || title.contains('refund') || title.contains('cod')) {
      return _SmartAction(
        label: 'Orders'.tr,
        icon: Icons.arrow_forward_rounded,
        color: Colors.white70,
        onTap: () => Get.toNamed(Routes.ORDER_SHOP_LIST),
      );
    }
    return null;
  }

  double _getLedgerAmount(LedgerRowItem row) {
    var amount = row.debit.abs();
    if (row.credit.abs() > amount) amount = row.credit.abs();
    if (row.netImpact.abs() > amount) amount = row.netImpact.abs();
    return amount;
  }

  String _formatRowAmount(LedgerRowItem row, double amount) {
    if (amount <= 0.0001) return '৳0.00';
    final sec = row.section.toUpperCase();
    if (sec == 'CASH_OUTFLOW') {
      return '-৳${_formatCurrency(amount)}';
    }
    if (sec == 'REVENUE_INFLOW' || sec == 'OPENING_BALANCE') {
      return '+৳${_formatCurrency(amount)}';
    }
    if (sec == 'DRAWER_ADJUSTMENT') {
      final sign = row.netImpact >= 0 ? '+' : '-';
      return '$sign৳${_formatCurrency(amount)}';
    }
    if (sec == 'BAKI_FLOW') {
      final sign = row.netImpact > 0 ? '+' : (row.netImpact < 0 ? '-' : '');
      return '$sign৳${_formatCurrency(amount)}';
    }
    return '৳${_formatCurrency(amount)}';
  }

  Color _getRowAmountColor(LedgerRowItem row, double amount) {
    if (amount <= 0.0001) return Colors.white38;
    return _getFlowBadgeColor(row);
  }

  Color _getFlowBadgeColor(LedgerRowItem row) {
    final flow = row.flowType.toLowerCase();
    final sec = row.section.toUpperCase();
    final title = row.title.toLowerCase();
    if (flow.contains('digital') || title.contains('digital') || title.contains('aamarpay')) {
      return const Color(0xFF93C5FD);
    }
    if (title.contains('owner') && title.contains('withdrawal') ||
        sec.contains('WITHDRAWAL')) return const Color(0xFFFCA5A5);
    if (title.contains('owner') && title.contains('deposit') ||
        sec.contains('DEPOSIT')) return const Color(0xFF6EE7B7);
    if (sec.contains('CLOSING')) return _blue;
    if (sec.contains('CARRY')) return _amber;
    if (sec == 'OPENING_BALANCE') return _amber;
    if (flow.contains('cash in') || flow.contains('recovery') || sec == 'REVENUE_INFLOW') {
      return const Color(0xFF6EE7B7);
    }
    if (flow.contains('cash out') || sec == 'CASH_OUTFLOW') {
      return const Color(0xFFFCA5A5);
    }
    if (flow.contains('drawer') || flow.contains('starting') || sec == 'OPENING_BALANCE' || sec == 'DRAWER_ADJUSTMENT') {
      return const Color(0xFF5EEAD4);
    }
    if (flow.contains('debt') || sec == 'BAKI_FLOW') {
      return const Color(0xFFFDE68A);
    }
    return Colors.white60;
  }

  // --- Bottom Highlighted Summary Cards ---
  Widget _buildBottomSummaryCards(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.isBottomSummaryExpanded.value;
      final totals = controller.reportData.value?.totals ?? LedgerTotals();

      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.24),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.toggleBottomSummary,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.wallet_outlined, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cash Drawer & Market Baki'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isExpanded
                                  ? 'Tap to collapse summary cards'.tr
                                  : 'Drawer: ৳${_formatCurrency(totals.expectedCashDrawer)} • Baki: ৳${_formatCurrency(totals.overallStoreBaki)}',
                              style: const TextStyle(color: Colors.white60, fontSize: 10.5),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isExpanded ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isExpanded ? 'Hide'.tr : 'Show'.tr,
                              style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4),
                            AnimatedRotation(
                              turns: isExpanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: Column(
                  children: [
                    Divider(color: Colors.white.withOpacity(0.15), height: 1),
                    const SizedBox(height: 10),

                    // Expected Cash in Drawer (Hand)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => AdjustCashDrawerBottomSheet.show(
                          context: context,
                          controller: controller,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.32),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _green.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.point_of_sale_rounded, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'EXPECTED CASH IN DRAWER (HAND)'.tr,
                                      style: const TextStyle(
                                        color: Color(0xFF6EE7B7),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tap to adjust till'.tr,
                                      style: const TextStyle(color: Colors.white60, fontSize: 9.5),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '৳${_formatCurrency(totals.expectedCashDrawer)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.white.withOpacity(0.55),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Overall Store Baki in Market
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Get.toNamed(Routes.BAKI_KHATA),
                        borderRadius: BorderRadius.circular(18),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.32),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: _red.withOpacity(0.35), width: 1.2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _red.withOpacity(0.25),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'STORE OVERALL MARKET OUTSTANDING BAKI'.tr,
                                      style: const TextStyle(
                                        color: Color(0xFFFCA5A5),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tap to open Baki Khata'.tr,
                                      style: const TextStyle(color: Colors.white60, fontSize: 9.5),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '৳${_formatCurrency(totals.overallStoreBaki)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.white.withOpacity(0.55),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      );
    });
  }

  static String _formatCurrency(double val) {
    return NumberFormat('#,##0.00').format(val);
  }

  static String _formatIso(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return iso;
    }
  }
}

class _SmartAction {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;

  const _SmartAction({
    required this.label,
    this.icon,
    required this.color,
    required this.onTap,
  });
}
