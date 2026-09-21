import 'package:ecom_delivery_flutter/app/models/baki/baki_summary_model.dart';
import 'package:ecom_delivery_flutter/app/modules/baki/controllers/baki_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/baki/views/widgets/collect_payment_bottom_sheet.dart';
import 'package:ecom_delivery_flutter/app/modules/baki/views/widgets/quick_add_baki_bottom_sheet.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BakiKhataScreen extends GetView<BakiController> {
  const BakiKhataScreen({super.key});

  static String _formatDateTime(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute $period';
    } catch (_) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111213),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1C1E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'baki.title'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => controller.loadBakiSummary(),
            tooltip: 'common.refresh'.tr,
          ),
        ],
      ),
      body: Obx(() {
        final summary = controller.bakiSummary.value;
        final isLoading = controller.isLoading.value;
        final currentTab = controller.selectedTabIndex.value;

        return RefreshIndicator(
          color: const Color(0xFF34D399),
          backgroundColor: const Color(0xFF1B1C1E),
          onRefresh: () => controller.loadBakiSummary(showLoading: false),
          child: Column(
            children: [
              // Summary card
              _buildStoreSummaryCard(summary),

              // Segmented Tab switcher
              _buildTabSelector(summary),

              // Search bar (only visible when in Customer List tab)
              if (currentTab == 0) _buildSearchBar(),

              // Content View
              Expanded(
                child: isLoading && summary == null
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF34D399),
                        ),
                      )
                    : (currentTab == 0
                        ? _buildCustomerList(summary)
                        : _buildRecentEntriesList(summary)),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStoreSummaryCard(BakiSummaryData? summary) {
    final totalBaki = summary?.totalStoreBaki ?? 0.0;
    final customerCount = summary?.totalCustomersWithBaki ?? 0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFFEF4444),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'baki.totalStoreBaki'.tr,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '৳${totalBaki.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF242528),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2E3033)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'baki.customersWithBaki'.tr,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$customerCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(BakiSummaryData? summary) {
    final customerCount = summary?.customers.length ?? 0;
    final recentCount = summary?.recentLedgerEntries.length ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1C1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2E3033)),
        ),
        child: Obx(() {
          final selectedTab = controller.selectedTabIndex.value;
          return Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => controller.setTab(0),
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedTab == 0 ? const Color(0xFF34D399) : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${'baki.customerList'.tr} ($customerCount)',
                      style: TextStyle(
                        color: selectedTab == 0 ? Colors.black : Colors.white70,
                        fontWeight: selectedTab == 0 ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => controller.setTab(1),
                  borderRadius: BorderRadius.circular(9),
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedTab == 1 ? const Color(0xFF34D399) : Colors.transparent,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${'baki.recentTransactions'.tr} ($recentCount)',
                      style: TextStyle(
                        color: selectedTab == 1 ? Colors.black : Colors.white70,
                        fontWeight: selectedTab == 1 ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: TextField(
        controller: controller.searchController,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'baki.searchHint'.tr,
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
          prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
          suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                  onPressed: controller.clearSearch,
                )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildCustomerList(BakiSummaryData? summary) {
    final customers = controller.filteredCustomers;

    if (customers.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 70),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1C1E),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2E3033)),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: Color(0xFF34D399),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'baki.noBakiCustomers'.tr,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'baki.allClear'.tr,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final customer = customers[index];
        return _buildCustomerCard(context, customer);
      },
    );
  }

  Widget _buildCustomerCard(BuildContext context, BakiCustomerItem customer) {
    final name = customer.name?.trim().isNotEmpty == true
        ? customer.name!
        : 'baki.unknownCustomer'.tr;
    final phone = customer.phone ?? '';
    final due = customer.totalBaki;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer info & Due badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF242528),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Color(0xFF34D399),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, color: Colors.white38, size: 13),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'baki.due'.tr,
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '৳${due.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(color: Color(0xFF2E3033), height: 1),
          const SizedBox(height: 10),

          // Action Buttons: Collect Payment, Quick Add Baki, View Ledger
          Row(
            children: [
              // Collect Payment (Green)
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: () {
                    CollectPaymentBottomSheet.show(
                      context: context,
                      customer: customer,
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 15, color: Colors.white),
                  label: Text(
                    'baki.collect'.tr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Quick Add Baki (Amber / Red)
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () {
                    QuickAddBakiBottomSheet.show(
                      context: context,
                      customer: customer,
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 15, color: Color(0xFFF59E0B)),
                  label: Text(
                    'baki.addBaki'.tr,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // View Ledger
              Material(
                color: const Color(0xFF242528),
                borderRadius: BorderRadius.circular(8),
                child: InkWell(
                  onTap: () {
                    Get.toNamed(
                      Routes.CUSTOMER_LEDGER,
                      arguments: {
                        'customerId': customer.customerId,
                        'customer': customer,
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2E3033)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.history, size: 16, color: Colors.white70),
                        const SizedBox(width: 4),
                        Text(
                          'baki.ledger'.tr,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntriesList(BakiSummaryData? summary) {
    final entries = summary?.recentLedgerEntries ?? [];

    if (entries.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 70),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B1C1E),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF2E3033)),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Colors.white38,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'baki.noRecentTransactions'.tr,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isDue = entry.isDue;
        final accentColor = isDue ? const Color(0xFFEF4444) : const Color(0xFF10B981);
        final sign = isDue ? '+' : '-';
        final amount = isDue
            ? (entry.dueAmount > 0 ? entry.dueAmount : entry.amount)
            : (entry.paidAmount > 0 ? entry.paidAmount : entry.amount);

        final customerName = entry.customer?.name ?? 'baki.unknownCustomer'.tr;
        final orderNo = entry.order?.orderNumber;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1B1C1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF2E3033)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () {
              if (entry.customerId != null) {
                Get.toNamed(
                  Routes.CUSTOMER_LEDGER,
                  arguments: {
                    'customerId': entry.customerId,
                    'customer': BakiCustomerItem(
                      customerId: entry.customerId,
                      name: entry.customer?.name,
                      phone: entry.customer?.phone,
                      email: entry.customer?.email,
                      totalBaki: entry.runningBalance,
                    ),
                  },
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isDue ? Icons.arrow_upward : Icons.arrow_downward,
                          color: accentColor,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    isDue ? 'baki.due'.tr : 'baki.payment'.tr,
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (orderNo != null) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF242528),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFF2E3033)),
                                    ),
                                    child: Text(
                                      '#$orderNo',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              customerName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$sign ৳${amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (entry.runningBalance > 0)
                            Text(
                              '${'baki.balance'.tr}: ৳${entry.runningBalance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  if (entry.note != null && entry.note!.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF242528),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        entry.note!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDateTime(entry.createdAt),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'baki.viewLedger'.tr,
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 2),
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF34D399),
                            size: 14,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
