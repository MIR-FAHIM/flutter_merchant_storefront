import 'package:ecom_delivery_flutter/app/models/chat_model.dart';
import 'package:ecom_delivery_flutter/app/models/order/order_list_model.dart';
import 'package:ecom_delivery_flutter/app/modules/shop_chat/controllers/shop_chat_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'order_status_badge.dart';

class OrderCard extends StatelessWidget {
  const OrderCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final ShopOrderItem item;
  final VoidCallback onTap;

  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _borderColor = Color(0xFF2E3033);

  @override
  Widget build(BuildContext context) {
    final order = item.order;
    final String statusStr = item.status ?? order?.status ?? 'N/A';
    final DateTime? createdDate = item.createdAt ?? order?.createdAt;
    final String dateStr = _formatDate(createdDate);
    final String customerName =
        (order?.customerName ?? order?.user?.name ?? '').trim().isNotEmpty
            ? (order?.customerName ?? order?.user?.name)!.trim()
            : 'Customer';
    final String customerPhone =
        (order?.customerPhone ?? order?.user?.phone ?? '').trim();

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
              // Header: Order Number + Date + Status Badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order?.orderNumber ?? 'Order #${item.orderId ?? item.id ?? '-'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            letterSpacing: 0.2,
                          ),
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
                  OrderStatusBadge(status: statusStr, isCompact: true),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1, color: _borderColor),
              const SizedBox(height: 12),

              // Product Info Block
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
                          item.productName ?? 'Unnamed Product',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFFF3F4F6),
                            height: 1.3,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                        if (item.sku != null && item.sku!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2C30),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'SKU: ${item.sku}',
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

              const SizedBox(height: 12),

              // Metric Chips Row
              Row(
                children: [
                  Expanded(
                    child: _MetricChip(
                      icon: Icons.tag_rounded,
                      label: 'Qty',
                      value: 'x${item.qty ?? 0}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricChip(
                      icon: Icons.sell_outlined,
                      label: 'Unit',
                      value: _money(item.unitPrice ?? 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MetricChip(
                      icon: Icons.payments_outlined,
                      label: 'Line Total',
                      value: _money(item.lineTotal ?? 0),
                    ),
                  ),
                ],
              ),

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
                    onTap: () => _openCustomerChat(order),
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
                  const Text(
                    'Total Order',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _money(order?.total ?? item.lineTotal ?? 0),
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontWeight: FontWeight.w900,
                          fontSize: 14.5,
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