import 'package:ecom_delivery_flutter/app/models/baki/baki_summary_model.dart';
import 'package:ecom_delivery_flutter/app/models/baki/customer_ledger_model.dart';
import 'package:ecom_delivery_flutter/app/modules/baki/controllers/customer_ledger_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/baki/views/widgets/collect_payment_bottom_sheet.dart';
import 'package:ecom_delivery_flutter/app/modules/baki/views/widgets/quick_add_baki_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomerLedgerScreen extends GetView<CustomerLedgerController> {
  const CustomerLedgerScreen({super.key});

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

  static String _formatDateOnly(String? isoString) {
    if (isoString == null || isoString.isEmpty) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
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
          'baki.customerLedger'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () => controller.loadLedger(refresh: true),
            tooltip: 'common.refresh'.tr,
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(context),
      body: Obx(() {
        final isLoading = controller.isLoading.value;
        final ledgers = controller.ledgers;
        final info = controller.customerInfo.value;
        final item = controller.customerItem.value;
        final totalBaki = controller.totalBaki.value;

        final customerName = info?.name ?? item?.name ?? 'baki.unknownCustomer'.tr;
        final customerPhone = info?.phone ?? item?.phone ?? '';

        return RefreshIndicator(
          color: const Color(0xFF34D399),
          backgroundColor: const Color(0xFF1B1C1E),
          onRefresh: () => controller.loadLedger(refresh: true),
          child: CustomScrollView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Customer Balance & Details Header Card
              SliverToBoxAdapter(
                child: _buildCustomerHeaderCard(
                  name: customerName,
                  phone: customerPhone,
                  totalBaki: totalBaki,
                ),
              ),

              // Ledger Transactions Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'baki.transactionHistory'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${ledgers.length} ${'baki.records'.tr}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Ledger List / Empty / Loading
              if (isLoading && ledgers.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF34D399)),
                  ),
                )
              else if (ledgers.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1B1C1E),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFF2E3033)),
                          ),
                          child: const Icon(
                            Icons.history,
                            color: Colors.white38,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'baki.noLedgerEntries'.tr,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = ledgers[index];
                        return _buildLedgerCard(entry);
                      },
                      childCount: ledgers.length,
                    ),
                  ),
                ),

                // Pagination Loading indicator
                if (controller.isLoadingMore.value)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF34D399),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],

              const SliverToBoxAdapter(
                child: SizedBox(height: 24),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCustomerHeaderCard({
    required String name,
    required String phone,
    required double totalBaki,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF242528),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Color(0xFF34D399),
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (phone.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.phone_outlined, color: Colors.white38, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            phone,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: totalBaki > 0
                  ? const Color(0xFFEF4444).withValues(alpha: 0.08)
                  : const Color(0xFF10B981).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: totalBaki > 0
                    ? const Color(0xFFEF4444).withValues(alpha: 0.25)
                    : const Color(0xFF10B981).withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'baki.outstandingDue'.tr,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '৳${totalBaki.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: totalBaki > 0
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF10B981),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: totalBaki > 0
                        ? const Color(0xFFEF4444).withValues(alpha: 0.18)
                        : const Color(0xFF10B981).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    totalBaki > 0 ? 'baki.hasDue'.tr : 'baki.allClear'.tr,
                    style: TextStyle(
                      color: totalBaki > 0
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF10B981),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerCard(LedgerItem entry) {
    final isDue = entry.isDue;
    final accentColor = isDue ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    final sign = isDue ? '+' : '-';
    final amount = isDue
        ? (entry.dueAmount > 0 ? entry.dueAmount : entry.amount.abs())
        : (entry.paidAmount > 0 ? entry.paidAmount : entry.amount.abs());

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Badge
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

              // Title and badges
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
                        if (entry.order?.orderNumber != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF242528),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF2E3033)),
                            ),
                            child: Text(
                              '#${entry.order!.orderNumber}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                        if (!isDue && entry.paymentMethod != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF242528),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: const Color(0xFF2E3033)),
                            ),
                            child: Text(
                              entry.paymentMethod!.toUpperCase(),
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
                    if (entry.createdAt != null && entry.createdAt!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(entry.createdAt),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Amount
              Text(
                '$sign ৳${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          // Due date if exists
          if (entry.dueDate != null && entry.dueDate!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.event_outlined, color: Color(0xFFF59E0B), size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '${'baki.dueDateLabel'.tr}: ${_formatDateOnly(entry.dueDate)}',
                    style: const TextStyle(
                      color: Color(0xFFF59E0B),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Note if exists
          if (entry.note != null && entry.note!.isNotEmpty) ...[
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
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],

          // Running balance & staff info
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (entry.createdBy != null && entry.createdBy!.isNotEmpty)
                Text(
                  '${'baki.by'.tr}: ${entry.createdBy}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                )
              else
                const SizedBox.shrink(),
              Text(
                '${'baki.balance'.tr}: ৳${entry.runningBalance.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF1B1C1E),
        border: Border(top: BorderSide(color: Color(0xFF2E3033))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Collect Payment
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  final bakiCustomer = BakiCustomerItem(
                    customerId: controller.customerId,
                    name: controller.customerInfo.value?.name ?? controller.customerItem.value?.name,
                    phone: controller.customerInfo.value?.phone ?? controller.customerItem.value?.phone,
                    totalBaki: controller.totalBaki.value,
                  );

                  CollectPaymentBottomSheet.show(
                    context: context,
                    customer: bakiCustomer,
                    onSuccess: () => controller.loadLedger(refresh: true),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                label: Text(
                  'baki.collectPayment'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Add Baki
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  final bakiCustomer = BakiCustomerItem(
                    customerId: controller.customerId,
                    name: controller.customerInfo.value?.name ?? controller.customerItem.value?.name,
                    phone: controller.customerInfo.value?.phone ?? controller.customerItem.value?.phone,
                    totalBaki: controller.totalBaki.value,
                  );

                  QuickAddBakiBottomSheet.show(
                    context: context,
                    customer: bakiCustomer,
                    onSuccess: () => controller.loadLedger(refresh: true),
                  );
                },
                icon: const Icon(Icons.add_circle_outline, color: Color(0xFFF59E0B), size: 18),
                label: Text(
                  'baki.addBaki'.tr,
                  style: const TextStyle(
                    color: Color(0xFFF59E0B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
