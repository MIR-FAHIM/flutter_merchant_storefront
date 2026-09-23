import 'package:ecom_delivery_flutter/app/models/reports/shop_cash_flow_report_model.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/controllers/shop_cash_flow_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/widgets/add_expense_bottom_sheet.dart';
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            const Color(0xFF0F766E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
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
            const SizedBox(height: 18),

            // 6. Bottom Highlighted Summary Cards (Interactive)
            _buildBottomSummaryCards(context),
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
              Text(
                'Reporting Period'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              // Custom Date Range Button
              InkWell(
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
                      Text(
                        'Custom Range'.tr,
                        style: TextStyle(
                          color: controller.selectedPeriod.value == 'custom'
                              ? const Color(0xFF0F766E)
                              : Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Quick Drawer & Cash Actions'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildShortcutButton(
                icon: Icons.wb_sunny_outlined,
                title: 'Set Opening Cash'.tr,
                bgColor: Colors.white.withOpacity(0.20),
                textColor: Colors.white,
                onTap: () => SetOpeningCashBottomSheet.show(
                  context: context,
                  controller: controller,
                ),
              ),
              const SizedBox(width: 8),
              _buildShortcutButton(
                icon: Icons.bolt_rounded,
                title: '+ Quick Cash Sale'.tr,
                bgColor: _amber.withOpacity(0.25),
                textColor: const Color(0xFFFFFBEB),
                onTap: () => QuickCashSaleBottomSheet.show(
                  context: context,
                  controller: controller,
                ),
              ),
              const SizedBox(width: 8),
              _buildShortcutButton(
                icon: Icons.money_off_rounded,
                title: '- Add Expense'.tr,
                bgColor: _red.withOpacity(0.25),
                textColor: const Color(0xFFFEF2F2),
                onTap: () => AddExpenseBottomSheet.show(
                  context: context,
                  controller: controller,
                ),
              ),
              const SizedBox(width: 8),
              _buildShortcutButton(
                icon: Icons.tune_rounded,
                title: 'Adjust Drawer'.tr,
                bgColor: _cyan.withOpacity(0.25),
                textColor: const Color(0xFFF0FDFA),
                onTap: () => AdjustCashDrawerBottomSheet.show(
                  context: context,
                  controller: controller,
                ),
              ),
            ],
          ),
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

  // --- Top 4 KPI Summary Cards (Clickable) ---
  Widget _buildKpiCardsGrid(BuildContext context) {
    final kpis = controller.reportData.value?.kpiCards ?? KpiCards();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Financial KPI Snapshot'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: 'Expected Cash in Drawer'.tr,
                subtitle: 'Physical Till Cash'.tr,
                amount: kpis.expectedCashInDrawer,
                icon: Icons.payments_outlined,
                accentColor: const Color(0xFF34D399),
                isHighlight: true,
                onTap: () => AdjustCashDrawerBottomSheet.show(
                  context: context,
                  controller: controller,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiCard(
                title: 'Total Digital Payments'.tr,
                subtitle: 'bKash / Nagad / Card'.tr,
                amount: kpis.totalDigitalPayments,
                icon: Icons.account_balance_outlined,
                accentColor: _blue,
                onTap: () => Get.toNamed(Routes.ORDER_SHOP_LIST),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildKpiCard(
                title: "Today's New Baki".tr,
                subtitle: 'Unpaid Given Out'.tr,
                amount: kpis.todayNewBaki,
                icon: Icons.assignment_late_outlined,
                accentColor: _amber,
                onTap: () => Get.toNamed(Routes.BAKI_KHATA),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildKpiCard(
                title: 'Store Market Baki'.tr,
                subtitle: 'Overall Customer Debt'.tr,
                amount: kpis.totalStoreOutstandingBaki,
                icon: Icons.account_balance_wallet_outlined,
                accentColor: _red,
                onTap: () => Get.toNamed(Routes.BAKI_KHATA),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String subtitle,
    required double amount,
    required IconData icon,
    required Color accentColor,
    bool isHighlight = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isHighlight
                ? Colors.black.withOpacity(0.35)
                : Colors.black.withOpacity(0.22),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isHighlight ? Colors.white.withOpacity(0.45) : Colors.white.withOpacity(0.15),
              width: isHighlight ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 15, color: accentColor),
                  ),
                  const Spacer(),
                  if (isHighlight)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'IN HAND'.tr,
                        style: TextStyle(color: accentColor, fontSize: 8.5, fontWeight: FontWeight.w900),
                      ),
                    ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: Colors.white.withOpacity(0.55),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '৳${_formatCurrency(amount)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white60, fontSize: 9.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Master Financial & Cash Ledger Table (Executive Merchant View) ---
  Widget _buildMasterLedgerTable(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.isLedgerTableExpanded.value;
      final grouped = controller.groupedLedgerRows;
      final totalRowsCount = controller.reportData.value?.ledgerRows.length ?? 0;

      final sectionConfigs = [
        {
          'key': 'OPENING_BALANCE',
          'title': 'OPENING CASH BALANCE'.tr,
          'icon': Icons.wb_sunny_outlined,
          'color': const Color(0xFF6EE7B7),
        },
        {
          'key': 'REVENUE_INFLOW',
          'title': 'CASH INFLOW & REVENUE'.tr,
          'icon': Icons.arrow_downward_rounded,
          'color': const Color(0xFF6EE7B7),
        },
        {
          'key': 'CASH_OUTFLOW',
          'title': 'CASH OUTFLOW & EXPENSES'.tr,
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
      ];

      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.28),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Table Header (Interactive toggle)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: controller.toggleLedgerTable,
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
                        child: const Icon(Icons.table_chart_outlined, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Master Cash & Financial Ledger'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isExpanded
                                  ? 'Tap to collapse breakdown'.tr
                                  : '$totalRowsCount ${'ledger entries • Tap to view breakdown'.tr}',
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

            // Animated Expandable Content
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(color: Colors.white.withOpacity(0.15), height: 1),

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
                        // Section Header Bar with Subtotal
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          color: secColor.withOpacity(0.12),
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
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                              Text(
                                _formatSectionSubtotal(key, secTotal),
                                style: TextStyle(
                                  color: secTotal.abs() > 0.0001 ? secColor : Colors.white54,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.white.withOpacity(0.08), height: 1),

                        // Section Rows
                        ...rows.map((row) => _buildLedgerRow(context, row)),
                      ],
                    );
                  }),
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
    final icon = _getLedgerRowIcon(row);
    final smartAction = _getSmartAction(context, row);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: smartAction?.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.white.withOpacity(0.06), width: 0.6),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon container
              Container(
                height: 34,
                width: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: flowBadgeColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: flowBadgeColor, size: 17),
              ),
              const SizedBox(width: 10),

              // Title and Flow Type Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: flowBadgeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: flowBadgeColor.withOpacity(0.24), width: 0.6),
                          ),
                          child: Text(
                            row.flowType.isNotEmpty ? row.flowType : 'Entry'.tr,
                            style: TextStyle(
                              color: flowBadgeColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Amount & Smart Action Button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    amountText,
                    style: TextStyle(
                      color: amountColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (smartAction != null) ...[
                    const SizedBox(height: 3),
                    InkWell(
                      onTap: smartAction.onTap,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: smartAction.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: smartAction.color.withOpacity(0.35), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (smartAction.icon != null) ...[
                              Icon(smartAction.icon, size: 10.5, color: smartAction.color),
                              const SizedBox(width: 3),
                            ],
                            Text(
                              smartAction.label,
                              style: TextStyle(
                                color: smartAction.color,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSmartLedgerTitle(LedgerRowItem row) {
    final title = row.title.toLowerCase();
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
    final sec = row.section.toUpperCase();
    if (sec == 'CASH_OUTFLOW') return const Color(0xFFFCA5A5);
    if (sec == 'REVENUE_INFLOW' || sec == 'OPENING_BALANCE') return const Color(0xFF6EE7B7);
    if (sec == 'DRAWER_ADJUSTMENT') return const Color(0xFF5EEAD4);
    if (sec == 'BAKI_FLOW') return const Color(0xFFFDE68A);
    return Colors.white;
  }

  Color _getFlowBadgeColor(LedgerRowItem row) {
    final flow = row.flowType.toLowerCase();
    final sec = row.section.toUpperCase();
    if (flow.contains('cash in') || flow.contains('recovery') || sec == 'REVENUE_INFLOW') {
      return const Color(0xFF6EE7B7);
    }
    if (flow.contains('cash out') || sec == 'CASH_OUTFLOW') {
      return const Color(0xFFFCA5A5);
    }
    if (flow.contains('digital')) {
      return const Color(0xFF93C5FD);
    }
    if (flow.contains('drawer') || flow.contains('starting') || sec == 'OPENING_BALANCE' || sec == 'DRAWER_ADJUSTMENT') {
      return const Color(0xFF5EEAD4);
    }
    if (flow.contains('debt') || sec == 'BAKI_FLOW') {
      return const Color(0xFFFDE68A);
    }
    return Colors.white60;
  }

  IconData _getLedgerRowIcon(LedgerRowItem row) {
    final title = row.title.toLowerCase();
    final sec = row.section.toUpperCase();

    if (title.contains('opening') || sec == 'OPENING_BALANCE') return Icons.wb_sunny_outlined;
    if (title.contains('quick manual')) return Icons.flash_on_rounded;
    if (title.contains('pos')) return Icons.point_of_sale_rounded;
    if (title.contains('cod')) return Icons.local_shipping_outlined;
    if (title.contains('baki recovered') || title.contains('recovery')) return Icons.payments_outlined;
    if (title.contains('digital') || title.contains('bkash') || title.contains('nagad')) return Icons.account_balance_wallet_outlined;
    if (title.contains('refund')) return Icons.currency_exchange_outlined;
    if (title.contains('expense') || sec == 'CASH_OUTFLOW') return Icons.shopping_bag_outlined;
    if (title.contains('adjust') || sec == 'DRAWER_ADJUSTMENT') return Icons.tune_rounded;
    if (title.contains('new baki')) return Icons.assignment_late_outlined;
    if (title.contains('total baki')) return Icons.assignment_turned_in_outlined;
    return Icons.receipt_long_outlined;
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
