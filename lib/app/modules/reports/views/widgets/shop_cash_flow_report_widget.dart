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

  // --- Master Financial & Cash Ledger Table ---
  Widget _buildMasterLedgerTable(BuildContext context) {
    final grouped = controller.groupedLedgerRows;

    final sectionConfigs = [
      {
        'key': 'OPENING_BALANCE',
        'title': 'OPENING CASH BALANCE'.tr,
        'icon': Icons.wb_sunny_outlined,
        'color': const Color(0xFF6EE7B7),
      },
      {
        'key': 'REVENUE_INFLOW',
        'title': 'REVENUE & CASH INFLOW'.tr,
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
        'title': 'DRAWER ADJUSTMENTS & CORRECTIONS'.tr,
        'icon': Icons.tune_rounded,
        'color': const Color(0xFF5EEAD4),
      },
      {
        'key': 'BAKI_FLOW',
        'title': 'BAKI (CREDIT) MARKET FLOW'.tr,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Table Header
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.table_chart_outlined, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Master Cash & Financial Ledger'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.15), height: 1),

          // Column titles header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.black.withOpacity(0.22),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    'Title & Flow Type'.tr,
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Debit (৳)'.tr,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Credit (৳)'.tr,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'Net (৳)'.tr,
                    textAlign: TextAlign.right,
                    style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.15), height: 1),

          // Render Sections
          ...sectionConfigs.map((sec) {
            final key = sec['key'] as String;
            final rows = grouped[key] ?? [];
            if (rows.isEmpty) return const SizedBox.shrink();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Header Bar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  color: (sec['color'] as Color).withOpacity(0.12),
                  child: Row(
                    children: [
                      Icon(sec['icon'] as IconData, size: 12, color: sec['color'] as Color),
                      const SizedBox(width: 6),
                      Text(
                        sec['title'] as String,
                        style: TextStyle(
                          color: sec['color'] as Color,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(color: Colors.white.withOpacity(0.10), height: 1),

                // Section Rows
                ...rows.map((row) => _buildLedgerRow(context, row)),
              ],
            );
          }),
        ],
      ),
    );
  }

  VoidCallback? _getLedgerRowAction(BuildContext context, LedgerRowItem row) {
    final title = row.title.toLowerCase();
    final sec = row.section.toUpperCase();

    if (sec == 'BAKI_FLOW' || title.contains('baki')) {
      return () => Get.toNamed(Routes.BAKI_KHATA);
    }
    if (title.contains('expense')) {
      return () => AddExpenseBottomSheet.show(context: context, controller: controller);
    }
    if (title.contains('opening')) {
      return () => SetOpeningCashBottomSheet.show(context: context, controller: controller);
    }
    if (title.contains('adjust') || sec == 'DRAWER_ADJUSTMENT') {
      return () => AdjustCashDrawerBottomSheet.show(context: context, controller: controller);
    }
    if (title.contains('quick manual')) {
      return () => QuickCashSaleBottomSheet.show(context: context, controller: controller);
    }
    if (title.contains('pos') || title.contains('sales') || title.contains('digital') || title.contains('refund')) {
      return () => Get.toNamed(Routes.ORDER_SHOP_LIST);
    }
    return null;
  }

  Widget _buildLedgerRow(BuildContext context, LedgerRowItem row) {
    Color flowBadgeColor = const Color(0xFF6EE7B7);
    final ft = row.flowType.toLowerCase();
    if (ft.contains('cash out') || ft.contains('debt (+)')) {
      flowBadgeColor = const Color(0xFFFCA5A5);
    } else if (ft.contains('digital') || ft.contains('non-cash')) {
      flowBadgeColor = const Color(0xFF93C5FD);
    } else if (ft.contains('drawer') || ft.contains('starting')) {
      flowBadgeColor = const Color(0xFF5EEAD4);
    } else if (ft.contains('cleared') || ft.contains('debt (-)')) {
      flowBadgeColor = const Color(0xFFFDE68A);
    }

    final net = row.netImpact;
    final netColor = net > 0
        ? const Color(0xFF6EE7B7)
        : (net < 0 ? const Color(0xFFFCA5A5) : Colors.white70);

    final action = _getLedgerRowAction(context, row);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.08), width: 0.6)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title & flow type badge
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            row.title.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (action != null) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 9,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: flowBadgeColor.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        row.flowType.tr,
                        style: TextStyle(
                          color: flowBadgeColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Debit
              Expanded(
                flex: 2,
                child: Text(
                  row.debit > 0 ? _formatCurrency(row.debit) : '-',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
              // Credit
              Expanded(
                flex: 2,
                child: Text(
                  row.credit > 0 ? _formatCurrency(row.credit) : '-',
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
              // Net Impact
              Expanded(
                flex: 3,
                child: Text(
                  '${net > 0 ? '+' : ''}${_formatCurrency(net)}',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: netColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Bottom Highlighted Summary Cards ---
  Widget _buildBottomSummaryCards(BuildContext context) {
    final totals = controller.reportData.value?.totals ?? LedgerTotals();

    return Column(
      children: [
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
    );
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
