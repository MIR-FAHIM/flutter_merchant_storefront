import 'package:ecom_delivery_flutter/app/models/chat_model.dart';
import 'package:ecom_delivery_flutter/app/models/order/order_list_model.dart';
import 'package:ecom_delivery_flutter/app/modules/shop_chat/controllers/shop_chat_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/common/payment_method_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'order_status_badge.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    this.order,
    this.item,
    required this.onTap,
  }) : assert(order != null || item != null, 'Either order or item must be provided');

  final OrderInfo? order;
  final ShopOrderItem? item;
  final VoidCallback onTap;

  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _borderColor = Color(0xFF2E3033);

  @override
  Widget build(BuildContext context) {
    final effectiveOrder = order ??
        item?.order ??
        OrderInfo(
          id: item?.orderId ?? item?.id,
          status: item?.status,
          createdAt: item?.createdAt,
          total: item?.lineTotal,
        );

    final List<ShopOrderItem> items =
        (effectiveOrder.items != null && effectiveOrder.items!.isNotEmpty)
            ? effectiveOrder.items!
            : (item != null ? [item!] : []);

    final String statusStr = effectiveOrder.status ?? item?.status ?? 'N/A';
    final DateTime? createdDate = effectiveOrder.createdAt ?? item?.createdAt;
    final String dateStr = _formatDate(createdDate);

    final String customerName = (effectiveOrder.customerName ??
            effectiveOrder.user?.name ??
            '')
        .trim()
        .isNotEmpty
        ? (effectiveOrder.customerName ?? effectiveOrder.user?.name)!.trim()
        : 'Customer';

    final String customerPhone = (effectiveOrder.customerPhone ??
            effectiveOrder.user?.phone ??
            '')
        .trim();

    final String address = (effectiveOrder.shippingAddress ?? '').trim();

    final String orderNum = effectiveOrder.orderNumber ??
        (effectiveOrder.id != null
            ? 'ORD-${effectiveOrder.id}'
            : (item?.orderId != null ? 'ORD-${item!.orderId}' : 'Order'));

    final bool isPos =
        (effectiveOrder.orderType ?? '').toLowerCase() == 'pos' ||
            orderNum.toUpperCase().startsWith('POS-');

    final String paymentMethod =
        paymentMethodLabel(effectiveOrder.paymentMethod);
    final String paymentStatus =
        (effectiveOrder.paymentStatus ?? 'N/A').toUpperCase();

    final double dueAmount = effectiveOrder.dueAmount ?? 0;
    final double paidAmount = effectiveOrder.paidAmount ?? 0;
    final double totalAmount = effectiveOrder.total ?? item?.lineTotal ?? 0;
    final double subtotal = effectiveOrder.subtotal ?? 0;
    final double shippingFee = effectiveOrder.shippingFee ?? 0;

    return Material(
      color: _cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.white10,
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order Number + Channel + Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                orderNum,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: orderNum));
                                Get.snackbar(
                                  'Copied',
                                  'Order number copied to clipboard',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: const Color(0xFF1B1C1E),
                                  colorText: Colors.white,
                                  duration: const Duration(seconds: 2),
                                );
                              },
                              borderRadius: BorderRadius.circular(4),
                              child: const Padding(
                                padding: EdgeInsets.all(2.0),
                                child: Icon(
                                  Icons.copy_rounded,
                                  size: 13,
                                  color: Color(0xFF9CA3AF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (dateStr.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: Color(0xFF9CA3AF),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dateStr,
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Channel Tag (POS vs ONLINE)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: isPos
                              ? const Color(0x2614B8A6)
                              : const Color(0x2638BDF8),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isPos
                                ? const Color(0xFF14B8A6)
                                : const Color(0xFF38BDF8),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPos
                                  ? Icons.point_of_sale_rounded
                                  : Icons.language_rounded,
                              size: 10,
                              color: isPos
                                  ? const Color(0xFF2DD4BF)
                                  : const Color(0xFF38BDF8),
                            ),
                            const SizedBox(width: 3.5),
                            Text(
                              isPos ? 'POS' : 'ONLINE',
                              style: TextStyle(
                                color: isPos
                                    ? const Color(0xFF2DD4BF)
                                    : const Color(0xFF38BDF8),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      OrderStatusBadge(status: statusStr, isCompact: true),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Payment Method, Payment Status, and Due Amount Badges
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF26282B),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFF373A40)),
                    ),
                    child: Text(
                      paymentMethod,
                      style: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: paymentStatus == 'PAID'
                          ? const Color(0x2610B981)
                          : (paymentStatus == 'UNPAID'
                              ? const Color(0x26EF4444)
                              : const Color(0x26F59E0B)),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      paymentStatus,
                      style: TextStyle(
                        color: paymentStatus == 'PAID'
                            ? const Color(0xFF34D399)
                            : (paymentStatus == 'UNPAID'
                                ? const Color(0xFFF87171)
                                : const Color(0xFFFBBF24)),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (dueAmount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0x33F59E0B),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 0.8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 11, color: Color(0xFFFBBF24)),
                          const SizedBox(width: 3),
                          Text(
                            'Due: ৳${dueAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFFFBBF24),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: _borderColor),
              const SizedBox(height: 12),

              // Items Section (Single or Multi-item)
              if (items.length > 1) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF222427),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF2E3033)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFF34D399)),
                              const SizedBox(width: 6),
                              Text(
                                '${items.length} Items in Order',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2C30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${effectiveOrder.totalItems ?? effectiveOrder.totalItemCount ?? items.fold<int>(0, (s, i) => s + (i.qty ?? 1))} pcs total',
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(height: 1, color: Color(0xFF2E3033)),
                      const SizedBox(height: 8),
                      for (int i = 0; i < (items.length > 3 ? 3 : items.length); i++) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF34D399),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  items[i].productName ?? 'Product item',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFE5E7EB),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E3033),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'x${items[i].qty ?? 1}',
                                  style: const TextStyle(
                                    color: Color(0xFF9CA3AF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _money(items[i].lineTotal ?? ((items[i].unitPrice ?? 0) * (items[i].qty ?? 1))),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (items.length > 3) ...[
                        const SizedBox(height: 4),
                        Text(
                          '+${items.length - 3} more items...',
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ] else if (items.length == 1) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFF26282B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF373A40)),
                      ),
                      child: const Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFF34D399),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            items.first.productName ?? 'Product item',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFFF3F4F6),
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          if (items.first.sku != null && items.first.sku!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2A2C30),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'SKU: ${items.first.sku}',
                                style: const TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _MetricChip(
                        icon: Icons.tag_rounded,
                        label: 'Qty',
                        value: 'x${items.first.qty ?? 1}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricChip(
                        icon: Icons.sell_outlined,
                        label: 'Unit',
                        value: _money(items.first.unitPrice ?? 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _MetricChip(
                        icon: Icons.payments_outlined,
                        label: 'Line Total',
                        value: _money(items.first.lineTotal ?? 0),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, color: Color(0xFF9CA3AF), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Order #${effectiveOrder.id ?? '-'}',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              const Divider(height: 1, color: _borderColor),
              const SizedBox(height: 10),

              // Customer Details & Quick Actions Row
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF26282B),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF373A40)),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Color(0xFF9CA3AF),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFF3F4F6),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        if (customerPhone.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            customerPhone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (address.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 10, color: Color(0xFF6B7280)),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF6B7280),
                                    fontSize: 10.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Call Button
                  _OrderActionButton(
                    icon: Icons.phone_rounded,
                    label: 'Call',
                    color: customerPhone.isNotEmpty
                        ? const Color(0xFF34D399)
                        : const Color(0xFF6B7280),
                    backgroundColor: customerPhone.isNotEmpty
                        ? const Color(0x1F34D399)
                        : const Color(0xFF222427),
                    onTap: () => _makeCall(customerPhone),
                  ),
                  const SizedBox(width: 6),

                  // Message Button
                  _OrderActionButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    label: 'Message',
                    color: const Color(0xFF38BDF8),
                    backgroundColor: const Color(0x1F38BDF8),
                    onTap: () => _openCustomerChat(effectiveOrder),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(height: 1, color: _borderColor),
              const SizedBox(height: 10),

              // Total Order & View Details Footer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          if (subtotal > 0)
                            Text(
                              'Subtotal: ৳${subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          if (subtotal > 0 && shippingFee > 0)
                            const Text(
                              ' • ',
                              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                            ),
                          if (shippingFee > 0)
                            Text(
                              'Fee: ৳${shippingFee.toStringAsFixed(0)}',
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      if (dueAmount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Paid: ৳${paidAmount.toStringAsFixed(0)} • Due: ৳${dueAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _money(totalAmount),
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF6B7280),
                        size: 18,
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
  }

  static String _money(double value) {
    return '৳${value.toStringAsFixed(2)}';
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '';
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

  static Future<void> _makeCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) {
      Get.snackbar(
        'Phone Number',
        'No phone number available for this customer',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1B1C1E),
        colorText: Colors.white,
      );
      return;
    }
    final Uri uri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar(
          'Call Failed',
          'Could not launch dialer for $cleanPhone',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1B1C1E),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Call Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1B1C1E),
        colorText: Colors.white,
      );
    }
  }

  static Future<void> _openCustomerChat(OrderInfo? order) async {
    final int? customerId = order?.userId ?? order?.user?.id;
    final String customerPhone =
        (order?.customerPhone ?? order?.user?.phone ?? '').trim();
    final String customerName =
        (order?.customerName ?? order?.user?.name ?? '').trim();

    if (!Get.isRegistered<ShopChatController>()) {
      Get.put(ShopChatController());
    }
    final chatController = Get.find<ShopChatController>();

    if (chatController.conversations.isEmpty &&
        !chatController.isConversationLoading.value) {
      try {
        await chatController.loadConversations();
      } catch (_) {}
    }

    Conversation? match;
    if (customerId != null && customerId > 0) {
      match = chatController.conversations.firstWhereOrNull(
        (c) => c.customerId == customerId || c.customer?.id == customerId,
      );
    }
    if (match == null && customerPhone.isNotEmpty) {
      final cleanPhone = customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPhone.isNotEmpty) {
        match = chatController.conversations.firstWhereOrNull(
          (c) =>
              (c.customer?.phone ?? '').replaceAll(RegExp(r'[^0-9]'), '') ==
              cleanPhone,
        );
      }
    }
    if (match == null && customerName.isNotEmpty) {
      match = chatController.conversations.firstWhereOrNull(
        (c) =>
            (c.customer?.name ?? '').trim().toLowerCase() ==
            customerName.toLowerCase(),
      );
    }

    if (match != null) {
      Get.toNamed(
        Routes.SHOP_CHAT_THREAD,
        arguments: {'conversation': match},
      );
      return;
    }

    // If no conversation exists, open a new conversation with user_id
    if (customerId != null && customerId > 0) {
      try {
        final newConversation = await chatController.openConversationWithUser(
          userId: customerId,
        );
        if (newConversation != null) {
          Get.toNamed(
            Routes.SHOP_CHAT_THREAD,
            arguments: {'conversation': newConversation},
          );
          return;
        }
      } catch (_) {}
    }

    Get.toNamed(
      Routes.SHOP_CHAT_CONVERSATIONS,
      arguments: {
        'customer_id': customerId,
        'user_id': customerId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
      },
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF222427),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF303236)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 11, color: const Color(0xFF9CA3AF)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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

class _OrderActionButton extends StatelessWidget {
  const _OrderActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        splashColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
