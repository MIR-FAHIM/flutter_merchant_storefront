import 'package:ecom_delivery_flutter/app/modules/order/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class OrderDetailView extends GetView<OrderController> {
  const OrderDetailView({super.key});

  static const Color _bgColor = Color(0xFF111213);
  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _borderColor = Color(0xFF2E3033);

  @override
  Widget build(BuildContext context) {
    if (controller.orderStatusOptions.isEmpty && !controller.isStatusLoading.value) {
      controller.loadOrderStatuses();
    }

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Order Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Obx(() {
        final item = controller.selectedOrderItem.value;
        final order = controller.selectedOrder.value ?? item?.order;

        if (item == null && order == null && controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (item == null && order == null) {
          return const Center(
            child: Text(
              'Order details not found',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.isDetailLoading.value)
                const LinearProgressIndicator(),

              if (controller.detailErrorMessage.value.isNotEmpty) ...[
                const SizedBox(height: 12),
                _ErrorBanner(message: controller.detailErrorMessage.value),
              ],

              const SizedBox(height: 12),

              _HeroOrderCard(
                orderNumber: order?.orderNumber ?? 'Order #${item?.orderId ?? '-'}',
                total: order?.total ?? item?.lineTotal ?? 0,
                status: order?.status ?? item?.status ?? 'N/A',
                paymentStatus: order?.paymentStatus ?? 'N/A',
              ),

              const SizedBox(height: 16),

              _StatusUpdateCard(
                statusOptions: controller.orderStatusOptions,
                selectedStatus: controller.selectedOrderStatus.value,
                onChanged: (value) {
                  if (value != null) {
                    controller.selectedOrderStatus.value = value.toLowerCase();
                  }
                },
                onUpdate: () {
                  final String orderId = (order?.id ?? item?.orderId ?? 0).toString();
                  if (orderId == '0' || orderId.isEmpty) {
                    return;
                  }

                  controller.changeOrderStatus(
                    orderId: orderId,
                    status: controller.selectedOrderStatus.value.toLowerCase(),
                  );
                },
                isUpdating: controller.isUpdatingStatus.value,
                errorMessage: controller.statusErrorMessage.value,
                successMessage: controller.statusUpdateMessage.value,
              ),

              const SizedBox(height: 16),

              _SectionTitle(title: 'Product Information'),

              const SizedBox(height: 10),

              _InfoCard(
                children: [
                  _InfoRow(label: 'Product', value: item?.productName),
                  _InfoRow(label: 'SKU', value: item?.sku),
                  _InfoRow(label: 'Quantity', value: '${item?.qty ?? 0}'),
                  _InfoRow(label: 'Unit Price', value: _money(item?.unitPrice ?? 0)),
                  _InfoRow(label: 'Line Total', value: _money(item?.lineTotal ?? 0)),
                  _InfoRow(label: 'Item Status', value: item?.status),
                  _InfoRow(
                    label: 'Seller Settled',
                    value: item?.isSettleWithSeller == 1 ? 'Yes' : 'No',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              _SectionTitle(title: 'Customer Information'),

              const SizedBox(height: 10),

              _InfoCard(
                children: [
                  _InfoRow(label: 'Customer', value: order?.customerName ?? order?.user?.name),
                  _InfoRow(label: 'Phone', value: order?.customerPhone ?? order?.user?.phone),
                  _InfoRow(label: 'Email', value: order?.user?.email),
                  _InfoRow(label: 'Shipping Address', value: order?.shippingAddress),
                  _InfoRow(label: 'Zone', value: order?.zone),
                  _InfoRow(label: 'Note', value: order?.note),
                ],
              ),

              const SizedBox(height: 16),

              _SectionTitle(title: 'Payment Summary'),

              const SizedBox(height: 10),

              _InfoCard(
                children: [
                  _InfoRow(label: 'Subtotal', value: _money(order?.subtotal ?? 0)),
                  _InfoRow(label: 'Shipping Fee', value: _money(order?.shippingFee ?? 0)),
                  _InfoRow(label: 'Discount', value: _money(order?.discount ?? 0)),
                  _InfoRow(label: 'Total', value: _money(order?.total ?? 0)),
                  _InfoRow(label: 'Payment Status', value: order?.paymentStatus),
                  _InfoRow(label: 'Platform', value: order?.platform),
                ],
              ),

              const SizedBox(height: 16),

              _SectionTitle(title: 'Order Timeline'),

              const SizedBox(height: 10),

              _InfoCard(
                children: [
                  _InfoRow(label: 'Created At', value: _formatDateTime(order?.createdAt ?? item?.createdAt)),
                  _InfoRow(label: 'Updated At', value: _formatDateTime(order?.updatedAt ?? item?.updatedAt)),
                  _InfoRow(label: 'Payment Group', value: order?.paymentGroupId),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  static String _money(double value) {
    return '৳${value.toStringAsFixed(2)}';
  }

  static String _formatDateTime(DateTime? date) {
    if (date == null) return 'N/A';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusUpdateCard extends StatelessWidget {
  const _StatusUpdateCard({
    required this.statusOptions,
    required this.selectedStatus,
    required this.onChanged,
    required this.onUpdate,
    required this.isUpdating,
    required this.errorMessage,
    required this.successMessage,
  });

  final List<OrderStatusOption> statusOptions;
  final String selectedStatus;
  final ValueChanged<String?> onChanged;
  final VoidCallback onUpdate;
  final bool isUpdating;
  final String errorMessage;
  final String successMessage;

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuItem<String>> items = statusOptions
        .map(
          (item) => DropdownMenuItem<String>(
            value: item.name.toLowerCase(),
            child: Text(item.name),
          ),
        )
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OrderDetailView._cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OrderDetailView._borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedStatus.isNotEmpty && items.any((entry) => entry.value == selectedStatus)
                ? selectedStatus
                : (items.isNotEmpty ? items.first.value : null),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF121417),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2E3033)),
              ),
            ),
            dropdownColor: const Color(0xFF1B1C1E),
            style: const TextStyle(color: Colors.white),
            iconEnabledColor: Colors.white,
            items: items,
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isUpdating ? null : onUpdate,
              icon: isUpdating
                  ? const SizedBox(
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.sync_rounded),
              label: Text(isUpdating ? 'Updating...' : 'Update Status'),
            ),
          ),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
              ),
            ),
          if (successMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                successMessage,
                style: const TextStyle(color: Color(0xFF34D399), fontSize: 12.5),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeroOrderCard extends StatelessWidget {
  const _HeroOrderCard({
    required this.orderNumber,
    required this.total,
    required this.status,
    required this.paymentStatus,
  });

  final String orderNumber;
  final double total;
  final String status;
  final String paymentStatus;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F766E),
            Color(0xFF14532D),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            orderNumber,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '৳${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeroChip(label: status, icon: Icons.inventory_outlined),
              _HeroChip(label: paymentStatus, icon: Icons.payments_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: OrderDetailView._cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OrderDetailView._borderColor),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final String finalValue =
    value == null || value!.trim().isEmpty ? 'N/A' : value!.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              finalValue,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.35)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.w700,
          fontSize: 12.5,
        ),
      ),
    );
  }
}