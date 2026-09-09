import 'package:ecom_delivery_flutter/app/modules/order/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/order_status_badge.dart';

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
    final requestedOrderId = _orderIdFromArguments(Get.arguments);

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
            fontSize: 20,
          ),
        ),
      ),
      body: Obx(() {
        final item = controller.selectedOrderItem.value;
        final order = controller.selectedOrder.value ?? item?.order;

        if (item == null &&
            order == null &&
            requestedOrderId != null &&
            !controller.isDetailLoading.value &&
            controller.detailErrorMessage.value.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!controller.isDetailLoading.value &&
                controller.detailErrorMessage.value.isEmpty) {
              controller.getOrderDetails(requestedOrderId.toString());
            }
          });
        }

        if (item == null && order == null && controller.isDetailLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF34D399)),
          );
        }

        if (item == null &&
            order == null &&
            requestedOrderId != null &&
            controller.detailErrorMessage.value.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF34D399)),
          );
        }

        if (item == null && order == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Color(0xFF6B7280), size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Order details not found',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF34D399),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Go Back'),
                ),
              ],
            ),
          );
        }

        final DateTime? createdDate = item?.createdAt ?? order?.createdAt;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.isDetailLoading.value)
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: LinearProgressIndicator(color: Color(0xFF34D399), backgroundColor: Color(0xFF1B1C1E)),
                ),

              if (controller.detailErrorMessage.value.isNotEmpty) ...[
                _ErrorBanner(message: controller.detailErrorMessage.value),
                const SizedBox(height: 14),
              ],

              // Top Order Hero Header Card
              _HeroOrderCard(
                orderNumber: order?.orderNumber ?? 'Order #${item?.orderId ?? item?.id ?? '-'}',
                dateStr: _formatDateTime(createdDate),
                total: order?.total ?? item?.lineTotal ?? 0,
                status: order?.status ?? item?.status ?? 'N/A',
                paymentStatus: order?.paymentStatus ?? 'N/A',
              ),

              const SizedBox(height: 16),

              // Smart Status Manager Card
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
                  if (orderId == '0' || orderId.isEmpty) return;

                  controller.changeOrderStatus(
                    orderId: orderId,
                    status: controller.selectedOrderStatus.value.toLowerCase(),
                  );
                },
                isUpdating: controller.isUpdatingStatus.value,
                errorMessage: controller.statusErrorMessage.value,
                successMessage: controller.statusUpdateMessage.value,
              ),

              const SizedBox(height: 18),

              // Product Information Card
              _SectionHeader(
                title: 'Product Information',
                icon: Icons.inventory_2_outlined,
              ),
              const SizedBox(height: 10),
              _ProductInfoCard(item: item),

              const SizedBox(height: 18),

              // Customer & Delivery Information Card
              _SectionHeader(
                title: 'Customer Details',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 10),
              _CustomerInfoCard(order: order),

              const SizedBox(height: 18),

              // Payment & Financial Summary Card
              _SectionHeader(
                title: 'Payment Breakdown',
                icon: Icons.receipt_long_outlined,
              ),
              const SizedBox(height: 10),
              _PaymentSummaryCard(order: order, item: item),

              const SizedBox(height: 18),

              // Order Timeline Card
              _SectionHeader(
                title: 'Order Timeline',
                icon: Icons.history_rounded,
              ),
              const SizedBox(height: 10),
              _TimelineCard(order: order, item: item),
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

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final String month = months[date.month - 1];
    final String day = date.day.toString().padLeft(2, '0');
    final String hour = (date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour)).toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');
    final String period = date.hour >= 12 ? 'PM' : 'AM';

    return '$day $month ${date.year}, $hour:$minute $period';
  }

  int? _orderIdFromArguments(dynamic args) {
    if (args is Map) {
      return int.tryParse((args['order_id'] ?? args['id'] ?? '').toString());
    }
    return int.tryParse((args ?? '').toString());
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF34D399), size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _HeroOrderCard extends StatelessWidget {
  const _HeroOrderCard({
    required this.orderNumber,
    required this.dateStr,
    required this.total,
    required this.status,
    required this.paymentStatus,
  });

  final String orderNumber;
  final String dateStr;
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F766E),
            Color(0xFF064E3B),
            Color(0xFF14532D),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                orderNumber,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (dateStr.isNotEmpty && dateStr != 'N/A')
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '৳${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OrderStatusBadge(status: status),
              if (paymentStatus.isNotEmpty) ...[
                _HeroChip(label: 'Payment: $paymentStatus', icon: Icons.payments_outlined),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
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
            child: Row(
              children: [
                OrderStatusBadge(status: item.name, isCompact: true),
              ],
            ),
          ),
        )
        .toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrderDetailView._cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OrderDetailView._borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: Color(0xFF34D399), size: 20),
              const SizedBox(width: 8),
              const Text(
                'Update Order Status',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: selectedStatus.isNotEmpty && items.any((entry) => entry.value == selectedStatus)
                ? selectedStatus
                : (items.isNotEmpty ? items.first.value : null),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF141517),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2E3033)),
              ),
              enabledBorder: OutlineInputBorder(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34D399),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: isUpdating ? null : onUpdate,
              icon: isUpdating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Icon(Icons.sync_rounded, size: 18),
              label: Text(
                isUpdating ? 'Updating Status...' : 'Apply Status Change',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
              ),
            ),
          ),
          if (errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
                    ),
                  ),
                ],
              ),
            ),
          if (successMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF34D399), size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      successMessage,
                      style: const TextStyle(color: Color(0xFF34D399), fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductInfoCard extends StatelessWidget {
  const _ProductInfoCard({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    if (item == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrderDetailView._cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OrderDetailView._borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF26282B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF373A40)),
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: Color(0xFF34D399),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName ?? 'Unnamed Product',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    if (item.sku != null && item.sku!.toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'SKU: ${item.sku}',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: OrderDetailView._borderColor),
          const SizedBox(height: 14),
          _DetailRow(label: 'Quantity', value: '${item.qty ?? 0} pcs'),
          _DetailRow(label: 'Unit Price', value: OrderDetailView._money(item.unitPrice ?? 0)),
          _DetailRow(label: 'Line Total', value: OrderDetailView._money(item.lineTotal ?? 0), isHighlighted: true),
          _DetailRow(
            label: 'Seller Settlement',
            valueWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: item.isSettleWithSeller == 1
                    ? const Color(0x2610B981)
                    : const Color(0x26F59E0B),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.isSettleWithSeller == 1 ? 'Settled' : 'Pending Settlement',
                style: TextStyle(
                  color: item.isSettleWithSeller == 1
                      ? const Color(0xFF10B981)
                      : const Color(0xFFF59E0B),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomerInfoCard extends StatelessWidget {
  const _CustomerInfoCard({required this.order});

  final dynamic order;

  Future<void> _makeCall(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String customerName = order?.customerName ?? order?.user?.name ?? 'N/A';
    final String phone = order?.customerPhone ?? order?.user?.phone ?? '';
    final String email = order?.user?.email ?? '';
    final String address = order?.shippingAddress ?? '';
    final String zone = order?.zone ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrderDetailView._cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OrderDetailView._borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(label: 'Name', value: customerName, icon: Icons.person_rounded),
          if (phone.isNotEmpty)
            _DetailRow(
              label: 'Phone',
              value: phone,
              icon: Icons.phone_rounded,
              actionWidget: InkWell(
                onTap: () => _makeCall(phone),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0x2634D399),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.call, size: 12, color: Color(0xFF34D399)),
                      SizedBox(width: 4),
                      Text('Call', style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          if (email.isNotEmpty)
            _DetailRow(label: 'Email', value: email, icon: Icons.email_rounded),
          if (address.isNotEmpty)
            _DetailRow(
              label: 'Address',
              value: address,
              icon: Icons.location_on_rounded,
              actionWidget: InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: address));
                  Get.snackbar(
                    'Copied',
                    'Address copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF1B1C1E),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
                child: const Icon(Icons.copy_rounded, size: 16, color: Color(0xFF9CA3AF)),
              ),
            ),
          if (zone.isNotEmpty)
            _DetailRow(label: 'Zone', value: zone, icon: Icons.map_rounded),
          if (order?.note != null && order!.note.toString().isNotEmpty)
            _DetailRow(label: 'Customer Note', value: order.note, icon: Icons.note_rounded),
        ],
      ),
    );
  }
}

class _PaymentSummaryCard extends StatelessWidget {
  const _PaymentSummaryCard({
    required this.order,
    required this.item,
  });

  final dynamic order;
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final double subtotal = order?.subtotal ?? item?.lineTotal ?? 0;
    final double shippingFee = order?.shippingFee ?? 0;
    final double discount = order?.discount ?? 0;
    final double total = order?.total ?? item?.lineTotal ?? 0;
    final String paymentStatus = order?.paymentStatus ?? 'N/A';
    final String platform = order?.platform ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrderDetailView._cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OrderDetailView._borderColor),
      ),
      child: Column(
        children: [
          _DetailRow(label: 'Subtotal', value: OrderDetailView._money(subtotal)),
          _DetailRow(label: 'Shipping Fee', value: OrderDetailView._money(shippingFee)),
          if (discount > 0)
            _DetailRow(label: 'Discount', value: '-${OrderDetailView._money(discount)}'),
          const Divider(height: 16, color: OrderDetailView._borderColor),
          _DetailRow(
            label: 'Total Amount',
            value: OrderDetailView._money(total),
            isHighlighted: true,
          ),
          const SizedBox(height: 6),
          _DetailRow(
            label: 'Payment Status',
            valueWidget: OrderStatusBadge(status: paymentStatus, isCompact: true),
          ),
          _DetailRow(label: 'Payment Platform', value: platform),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.order,
    required this.item,
  });

  final dynamic order;
  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final DateTime? created = order?.createdAt ?? item?.createdAt;
    final DateTime? updated = order?.updatedAt ?? item?.updatedAt;
    final String paymentGroupId = order?.paymentGroupId ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrderDetailView._cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OrderDetailView._borderColor),
      ),
      child: Column(
        children: [
          _TimelineItem(
            title: 'Order Placed',
            subtitle: OrderDetailView._formatDateTime(created),
            icon: Icons.add_shopping_cart_rounded,
            isFirst: true,
          ),
          _TimelineItem(
            title: 'Last Updated',
            subtitle: OrderDetailView._formatDateTime(updated),
            icon: Icons.update_rounded,
          ),
          if (paymentGroupId != 'N/A' && paymentGroupId.isNotEmpty)
            _TimelineItem(
              title: 'Payment Group ID',
              subtitle: paymentGroupId,
              icon: Icons.numbers_rounded,
              isLast: true,
            ),
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isFirst = false,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF26282B),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: const Color(0xFF34D399)),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 24,
                color: const Color(0xFF2E3033),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.icon,
    this.actionWidget,
    this.isHighlighted = false,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final IconData? icon;
  final Widget? actionWidget;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: const Color(0xFF9CA3AF)),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: valueWidget ??
                Text(
                  value == null || value!.trim().isEmpty ? 'N/A' : value!.trim(),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isHighlighted ? const Color(0xFF34D399) : Colors.white,
                    fontSize: isHighlighted ? 14 : 13,
                    fontWeight: isHighlighted ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
          ),
          if (actionWidget != null) ...[
            const SizedBox(width: 8),
            actionWidget!,
          ],
        ],
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
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w700,
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
