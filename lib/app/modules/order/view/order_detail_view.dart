import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';
import 'package:ecom_delivery_flutter/app/models/chat_model.dart';
import 'package:ecom_delivery_flutter/app/models/order/order_list_model.dart';
import 'package:ecom_delivery_flutter/app/modules/order/controller/order_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/shop_chat/controllers/shop_chat_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'widgets/order_status_badge.dart';

class OrderDetailView extends GetView<OrderController> {
  const OrderDetailView({super.key});

  static const Color bgColor = Color(0xFF111213);
  static const Color cardColor = Color(0xFF1B1C1E);
  static const Color secondaryCardColor = Color(0xFF222427);
  static const Color borderColor = Color(0xFF2E3033);
  static const Color emeraldColor = Color(0xFF34D399);
  static const Color amberColor = Color(0xFFF59E0B);
  static const Color blueColor = Color(0xFF38BDF8);

  @override
  Widget build(BuildContext context) {
    if (controller.orderStatusOptions.isEmpty && !controller.isStatusLoading.value) {
      controller.loadOrderStatuses();
    }
    final requestedOrderId = _orderIdFromArguments(Get.arguments);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Obx(() {
          final item = controller.selectedOrderItem.value;
          final order = controller.selectedOrder.value ?? item?.order;
          final String orderNum = order?.orderNumber ??
              (order?.id != null
                  ? 'ORD-${order!.id}'
                  : (item?.orderId != null ? 'ORD-${item!.orderId}' : 'Order Details'));
          final bool isPos = (order?.orderType ?? '').toLowerCase() == 'pos' ||
              orderNum.toUpperCase().startsWith('POS-');

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                orderNum,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16.5,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: isPos
                          ? const Color(0x2614B8A6)
                          : const Color(0x2638BDF8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      isPos ? 'POS SALE' : 'ONLINE ORDER',
                      style: TextStyle(
                        color: isPos ? const Color(0xFF2DD4BF) : const Color(0xFF38BDF8),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  if (order?.createdAt != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      _formatDateOnly(order!.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          );
        }),
        actions: [
          // Copy / Share Receipt Quick Action
          IconButton(
            tooltip: 'Share Order Receipt',
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              final item = controller.selectedOrderItem.value;
              final order = controller.selectedOrder.value ?? item?.order;
              _shareReceipt(order, item);
            },
          ),
          // Refresh Order Details
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () {
              final item = controller.selectedOrderItem.value;
              final order = controller.selectedOrder.value ?? item?.order;
              final orderId = (order?.id ?? item?.orderId ?? requestedOrderId)?.toString();
              if (orderId != null && orderId.isNotEmpty) {
                controller.getOrderDetails(orderId);
              }
            },
          ),
        ],
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
            child: CircularProgressIndicator(color: emeraldColor),
          );
        }

        if (item == null &&
            order == null &&
            requestedOrderId != null &&
            controller.detailErrorMessage.value.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: emeraldColor),
          );
        }

        if (item == null && order == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.receipt_long_outlined, color: Color(0xFF6B7280), size: 52),
                  const SizedBox(height: 14),
                  const Text(
                    'Order Details Not Found',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'The requested order could not be loaded or may have been deleted.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: emeraldColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    label: const Text('Return to Orders', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ),
          );
        }

        final DateTime? createdDate = item?.createdAt ?? order?.createdAt;
        final String effectiveOrderId =
            (order?.id ?? item?.orderId ?? requestedOrderId ?? '').toString();

        return RefreshIndicator(
          color: emeraldColor,
          backgroundColor: cardColor,
          onRefresh: () async {
            if (effectiveOrderId.isNotEmpty) {
              await controller.getOrderDetails(effectiveOrderId);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.isDetailLoading.value)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(
                      color: emeraldColor,
                      backgroundColor: cardColor,
                    ),
                  ),

                if (controller.detailErrorMessage.value.isNotEmpty) ...[
                  _ErrorBanner(message: controller.detailErrorMessage.value),
                  const SizedBox(height: 14),
                ],

                // 1. SMART ORDER HERO CARD
                _OrderHeroCard(
                  order: order,
                  item: item,
                  createdDate: createdDate,
                ),

                const SizedBox(height: 14),

                // 2. QUICK ACTION TOOLBAR (Call, Chat, Receipt, Directions)
                _QuickActionBar(
                  order: order,
                  item: item,
                ),

                const SizedBox(height: 16),

                // 3. SMART LIFECYCLE TRACKER & FAST STATUS CONTROLS
                _OrderLifecycleCard(
                  order: order,
                  item: item,
                  controller: controller,
                ),

                const SizedBox(height: 20),

                // 4. ITEMIZED PRODUCTS
                _SectionTitle(
                  title: (order?.items != null && order!.items!.isNotEmpty)
                      ? 'Order Items (${order.items!.length})'
                      : 'Product Information',
                  icon: Icons.inventory_2_outlined,
                  action: Text(
                    '${order?.totalItems ?? order?.totalItemCount ?? (order?.items?.fold<int>(0, (s, i) => s + (i.qty ?? 1)) ?? item?.qty ?? 1)} pcs total',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _OrderProductsCard(order: order, item: item),

                const SizedBox(height: 20),

                // 5. CUSTOMER & DELIVERY CARD
                const _SectionTitle(
                  title: 'Customer & Delivery',
                  icon: Icons.person_pin_circle_outlined,
                ),
                const SizedBox(height: 10),
                _CustomerDeliveryCard(order: order),

                const SizedBox(height: 20),

                // 6. FINANCIAL & PAYMENT BREAKDOWN
                const _SectionTitle(
                  title: 'Payment & Accounting',
                  icon: Icons.account_balance_wallet_outlined,
                ),
                const SizedBox(height: 10),
                _FinancialSummaryCard(order: order, item: item),

                const SizedBox(height: 20),

                // 7. ORDER ACTIVITY & METADATA
                const _SectionTitle(
                  title: 'Order Timeline',
                  icon: Icons.history_rounded,
                ),
                const SizedBox(height: 10),
                _OrderTimelineCard(order: order, item: item),
              ],
            ),
          ),
        );
      }),
    );
  }

  static String money(double value) {
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
    final String hour = (date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour))
        .toString()
        .padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');
    final String period = date.hour >= 12 ? 'PM' : 'AM';

    return '$day $month ${date.year}, $hour:$minute $period';
  }

  static String _formatDateOnly(DateTime? date) {
    if (date == null) return '';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final String month = months[date.month - 1];
    final String day = date.day.toString().padLeft(2, '0');
    return '$day $month ${date.year}';
  }

  static int? _orderIdFromArguments(dynamic args) {
    if (args is Map) {
      return int.tryParse((args['order_id'] ?? args['id'] ?? '').toString());
    }
    return int.tryParse((args ?? '').toString());
  }

  static Future<void> makeCall(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) {
      Get.snackbar(
        'Phone Number',
        'No phone number available for this customer',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: cardColor,
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
          backgroundColor: cardColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Call Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: cardColor,
        colorText: Colors.white,
      );
    }
  }

  static Future<void> openMap(String address) async {
    final clean = address.trim();
    if (clean.isEmpty) {
      Get.snackbar(
        'No Address',
        'No shipping address provided for this order',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: cardColor,
        colorText: Colors.white,
      );
      return;
    }
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(clean)}',
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        Clipboard.setData(ClipboardData(text: clean));
        Get.snackbar(
          'Address Copied',
          'Could not open Maps app, address copied to clipboard',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: cardColor,
          colorText: Colors.white,
        );
      }
    } catch (_) {
      Clipboard.setData(ClipboardData(text: clean));
      Get.snackbar(
        'Address Copied',
        'Address copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: cardColor,
        colorText: Colors.white,
      );
    }
  }

  static Future<void> openCustomerChat(OrderInfo? order) async {
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

  static void _shareReceipt(OrderInfo? order, ShopOrderItem? item) {
    if (order == null && item == null) return;

    final String orderNum = order?.orderNumber ??
        (order?.id != null
            ? 'ORD-${order!.id}'
            : 'Order #${item?.orderId ?? item?.id ?? '-'}');
    final String customerName =
        (order?.customerName ?? order?.user?.name ?? 'Customer').trim();
    final String customerPhone =
        (order?.customerPhone ?? order?.user?.phone ?? '').trim();
    final String address = (order?.shippingAddress ?? '').trim();
    final double total = order?.total ?? item?.lineTotal ?? 0;
    final double subtotal = order?.subtotal ?? 0;
    final double shippingFee = order?.shippingFee ?? 0;
    final double discount = order?.discount ?? 0;
    final double paidAmount = order?.paidAmount ?? 0;
    final double dueAmount = order?.dueAmount ?? 0;
    final String paymentMethod = (order?.paymentMethod ?? 'N/A').toUpperCase();
    final String paymentStatus = (order?.paymentStatus ?? 'N/A').toUpperCase();

    final buffer = StringBuffer();
    buffer.writeln('🧾 ORDER RECEIPT');
    buffer.writeln('---------------------------');
    buffer.writeln('Order: $orderNum');
    if (order?.createdAt != null) {
      buffer.writeln('Date: ${_formatDateTime(order!.createdAt)}');
    }
    buffer.writeln('Customer: $customerName');
    if (customerPhone.isNotEmpty) {
      buffer.writeln('Phone: $customerPhone');
    }
    if (address.isNotEmpty) {
      buffer.writeln('Delivery Address: $address');
    }
    buffer.writeln('---------------------------');
    buffer.writeln('ITEMS:');

    final items = (order?.items != null && order!.items!.isNotEmpty)
        ? order.items!
        : (item != null ? [item] : <ShopOrderItem>[]);

    if (items.isNotEmpty) {
      for (final it in items) {
        final String name = it.productName ?? 'Product item';
        final int qty = it.qty ?? 1;
        final double price = it.unitPrice ?? 0;
        final double lineTotal = it.lineTotal ?? (price * qty);
        buffer.writeln('• $name x$qty - ৳${lineTotal.toStringAsFixed(2)}');
      }
    } else {
      buffer.writeln('• Order Total: ৳${total.toStringAsFixed(2)}');
    }

    buffer.writeln('---------------------------');
    if (subtotal > 0) buffer.writeln('Subtotal: ৳${subtotal.toStringAsFixed(2)}');
    if (shippingFee > 0) buffer.writeln('Shipping Fee: ৳${shippingFee.toStringAsFixed(2)}');
    if (discount > 0) buffer.writeln('Discount: -৳${discount.toStringAsFixed(2)}');
    buffer.writeln('Total: ৳${total.toStringAsFixed(2)}');
    buffer.writeln('Payment: $paymentMethod ($paymentStatus)');
    if (paidAmount > 0) buffer.writeln('Paid: ৳${paidAmount.toStringAsFixed(2)}');
    if (dueAmount > 0) buffer.writeln('Due Amount (Baki): ৳${dueAmount.toStringAsFixed(2)}');
    buffer.writeln('---------------------------');
    buffer.writeln('Thank you for your order!');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    Get.snackbar(
      'Receipt Copied',
      'Order receipt copied to clipboard! Ready to share via WhatsApp or SMS.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: cardColor,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      icon: const Icon(Icons.receipt_long_rounded, color: emeraldColor),
    );
  }
}

// ==========================================
// 1. SMART ORDER HERO CARD
// ==========================================
class _OrderHeroCard extends StatelessWidget {
  const _OrderHeroCard({
    required this.order,
    required this.item,
    required this.createdDate,
  });

  final OrderInfo? order;
  final ShopOrderItem? item;
  final DateTime? createdDate;

  @override
  Widget build(BuildContext context) {
    final String orderNum = order?.orderNumber ??
        (order?.id != null
            ? 'ORD-${order!.id}'
            : (item?.orderId != null ? 'ORD-${item!.orderId}' : 'Order'));
    final double total = order?.total ?? item?.lineTotal ?? 0;
    final String status = order?.status ?? item?.status ?? 'N/A';
    final String paymentStatus = (order?.paymentStatus ?? 'N/A').toUpperCase();
    final String paymentMethod = (order?.paymentMethod ?? 'N/A').toUpperCase();
    final double dueAmount = order?.dueAmount ?? 0;
    final double paidAmount = order?.paidAmount ?? 0;
    final bool isPos = (order?.orderType ?? '').toLowerCase() == 'pos' ||
        orderNum.toUpperCase().startsWith('POS-');

    return Container(
      width: double.infinity,
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
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Channel Badge + Order # with Copy + Status Badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPos
                            ? const Color(0x2614B8A6)
                            : const Color(0x2638BDF8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isPos
                              ? const Color(0xFF2DD4BF)
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
                            size: 11,
                            color: isPos
                                ? const Color(0xFF2DD4BF)
                                : const Color(0xFF38BDF8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isPos ? 'POS' : 'ONLINE',
                            style: TextStyle(
                              color: isPos
                                  ? const Color(0xFF2DD4BF)
                                  : const Color(0xFF38BDF8),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              orderNum,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: orderNum));
                              Get.snackbar(
                                'Copied',
                                'Order number copied to clipboard',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: OrderDetailView.cardColor,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 2),
                              );
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.copy_rounded, size: 13, color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    OrderStatusBadge(status: status),
                  ],
                ),

                const SizedBox(height: 14),

                // Amount & Date
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TOTAL ORDER AMOUNT',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          OrderDetailView.money(total),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    if (createdDate != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.access_time_rounded, size: 12, color: Colors.white60),
                            const SizedBox(width: 4),
                            Text(
                              OrderDetailView._formatDateTime(createdDate),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Payment Info Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _HeroPill(
                      label: paymentMethod,
                      icon: Icons.payments_outlined,
                    ),
                    _HeroPill(
                      label: paymentStatus,
                      icon: paymentStatus == 'PAID'
                          ? Icons.check_circle_outline_rounded
                          : Icons.hourglass_top_rounded,
                      color: paymentStatus == 'PAID'
                          ? const Color(0xFF34D399)
                          : (paymentStatus == 'UNPAID'
                              ? const Color(0xFFF87171)
                              : const Color(0xFFFBBF24)),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Baki / Due Amount Alert Banner
          if (dueAmount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: const BoxDecoration(
                color: Color(0x33F59E0B),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
                border: Border(
                  top: BorderSide(color: Color(0x40F59E0B), width: 1),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFFBBF24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Due Amount (Baki): ',
                              style: TextStyle(
                                color: Color(0xFFFDE68A),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              OrderDetailView.money(dueAmount),
                              style: const TextStyle(
                                color: Color(0xFFFBBF24),
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Paid: ${OrderDetailView.money(paidAmount)}${order?.dueDate != null ? " • Due by ${OrderDetailView._formatDateOnly(order!.dueDate)}" : ""}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

class _HeroPill extends StatelessWidget {
  const _HeroPill({
    required this.label,
    required this.icon,
    this.color,
  });

  final String label;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color ?? Colors.white, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 2. QUICK ACTION TOOLBAR (Call, Chat, Receipt, Map)
// ==========================================
class _QuickActionBar extends StatelessWidget {
  const _QuickActionBar({
    required this.order,
    required this.item,
  });

  final OrderInfo? order;
  final ShopOrderItem? item;

  @override
  Widget build(BuildContext context) {
    final String customerPhone =
        (order?.customerPhone ?? order?.user?.phone ?? '').trim();
    final String address = (order?.shippingAddress ?? '').trim();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: OrderDetailView.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OrderDetailView.borderColor),
      ),
      child: Row(
        children: [
          // 1. Call Customer
          Expanded(
            child: _QuickActionButton(
              icon: Icons.call_rounded,
              label: 'Call',
              color: customerPhone.isNotEmpty
                  ? const Color(0xFF34D399)
                  : const Color(0xFF6B7280),
              bgColor: customerPhone.isNotEmpty
                  ? const Color(0x1F34D399)
                  : const Color(0xFF222427),
              onTap: customerPhone.isNotEmpty
                  ? () => OrderDetailView.makeCall(customerPhone)
                  : null,
            ),
          ),
          const SizedBox(width: 8),

          // 2. In-App Message
          Expanded(
            child: _QuickActionButton(
              icon: Icons.chat_bubble_outline_rounded,
              label: 'Message',
              color: const Color(0xFF38BDF8),
              bgColor: const Color(0x1F38BDF8),
              onTap: () => OrderDetailView.openCustomerChat(order),
            ),
          ),
          const SizedBox(width: 8),

          // 3. Share / Copy Receipt
          Expanded(
            child: _QuickActionButton(
              icon: Icons.receipt_long_rounded,
              label: 'Receipt',
              color: const Color(0xFFF59E0B),
              bgColor: const Color(0x1FF59E0B),
              onTap: () => OrderDetailView._shareReceipt(order, item),
            ),
          ),
          const SizedBox(width: 8),

          // 4. Open Map / Directions
          Expanded(
            child: _QuickActionButton(
              icon: Icons.navigation_rounded,
              label: 'Map',
              color: address.isNotEmpty
                  ? const Color(0xFFA78BFA)
                  : const Color(0xFF6B7280),
              bgColor: address.isNotEmpty
                  ? const Color(0x1FA78BFA)
                  : const Color(0xFF222427),
              onTap: address.isNotEmpty
                  ? () => OrderDetailView.openMap(address)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 3. SMART LIFECYCLE TRACKER & FAST STATUS ACTION
// ==========================================
class _OrderLifecycleCard extends StatefulWidget {
  const _OrderLifecycleCard({
    required this.order,
    required this.item,
    required this.controller,
  });

  final OrderInfo? order;
  final ShopOrderItem? item;
  final OrderController controller;

  @override
  State<_OrderLifecycleCard> createState() => _OrderLifecycleCardState();
}

class _OrderLifecycleCardState extends State<_OrderLifecycleCard> {
  bool _showAllOptions = false;

  int _calculateStepIndex(String status) {
    final s = status.toLowerCase().trim();
    if (['cancelled', 'canceled', 'rejected', 'failed'].contains(s)) {
      return -1;
    }
    if (['delivered', 'completed', 'fulfilled'].contains(s)) {
      return 3;
    }
    if (['processing', 'shipping', 'shipped', 'in_transit', 'packed', 'picked_up'].contains(s)) {
      return 2;
    }
    if (['confirmed', 'accepted', 'approved'].contains(s)) {
      return 1;
    }
    return 0; // pending, unpaid, placed
  }

  Future<void> _updateStatus(String targetStatus) async {
    final orderId = (widget.order?.id ?? widget.item?.orderId ?? 0).toString();
    if (orderId == '0' || orderId.isEmpty) return;

    await widget.controller.changeOrderStatus(
      orderId: orderId,
      status: targetStatus.toLowerCase().trim(),
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: OrderDetailView.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 22),
            SizedBox(width: 8),
            Text(
              'Cancel Order?',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to cancel this order? This action will mark the order as Cancelled.',
          style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Back', style: TextStyle(color: Color(0xFF9CA3AF))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _updateStatus('cancelled');
            },
            child: const Text('Yes, Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentStatus = widget.order?.status ?? widget.item?.status ?? 'pending';
      final int stepIndex = _calculateStepIndex(currentStatus);
      final bool isUpdating = widget.controller.isUpdatingStatus.value;
      final List<OrderStatusOption> statusOptions = widget.controller.orderStatusOptions;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OrderDetailView.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: OrderDetailView.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.alt_route_rounded, color: OrderDetailView.emeraldColor, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Order Progress',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                OrderStatusBadge(status: currentStatus, isCompact: true),
              ],
            ),

            const SizedBox(height: 18),

            // Lifecycle Stepper Visual
            if (stepIndex == -1) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'This order has been cancelled',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              _ProgressStepper(currentStep: stepIndex),
            ],

            const SizedBox(height: 16),

            // Fast 1-Tap Action Button based on current stage
            if (stepIndex == 0) ...[
              // Status: Placed / Pending
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: OrderDetailView.emeraldColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isUpdating ? null : () => _updateStatus('confirmed'),
                      icon: isUpdating
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                            )
                          : const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text(
                        'Confirm Order',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isUpdating ? null : () => _showCancelConfirmation(context),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ] else if (stepIndex == 1) ...[
              // Status: Confirmed -> Next: Processing / Out for Delivery
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isUpdating ? null : () => _updateStatus('processing'),
                  icon: isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.local_shipping_rounded, size: 18),
                  label: const Text(
                    'Mark Out for Delivery',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                  ),
                ),
              ),
            ] else if (stepIndex == 2) ...[
              // Status: Processing -> Next: Delivered / Completed
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: OrderDetailView.emeraldColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isUpdating ? null : () => _updateStatus('delivered'),
                  icon: isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.task_alt_rounded, size: 18),
                  label: const Text(
                    'Complete & Mark Delivered',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                  ),
                ),
              ),
            ] else if (stepIndex == 3) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: OrderDetailView.emeraldColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: OrderDetailView.emeraldColor.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_rounded, color: OrderDetailView.emeraldColor, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Order delivered and fulfilled successfully',
                        style: TextStyle(
                          color: OrderDetailView.emeraldColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Feedback Messages
            if (widget.controller.statusErrorMessage.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.controller.statusErrorMessage.value,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.controller.statusUpdateMessage.value.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded,
                        color: OrderDetailView.emeraldColor, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.controller.statusUpdateMessage.value,
                        style: const TextStyle(
                          color: OrderDetailView.emeraldColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // Advanced Dropdown Expander
            InkWell(
              onTap: () {
                setState(() {
                  _showAllOptions = !_showAllOptions;
                });
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _showAllOptions ? 'Hide custom status selection' : 'Select another custom status...',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      _showAllOptions ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF9CA3AF),
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),

            if (_showAllOptions) ...[
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: widget.controller.selectedOrderStatus.value.isNotEmpty &&
                        statusOptions.any((entry) =>
                            entry.name.toLowerCase() ==
                            widget.controller.selectedOrderStatus.value.toLowerCase())
                    ? widget.controller.selectedOrderStatus.value.toLowerCase()
                    : (statusOptions.isNotEmpty
                        ? statusOptions.first.name.toLowerCase()
                        : null),
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
                items: statusOptions
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item.name.toLowerCase(),
                        child: OrderStatusBadge(status: item.name, isCompact: true),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    widget.controller.selectedOrderStatus.value = value.toLowerCase();
                  }
                },
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: OrderDetailView.emeraldColor,
                    side: const BorderSide(color: OrderDetailView.emeraldColor),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isUpdating
                      ? null
                      : () => _updateStatus(widget.controller.selectedOrderStatus.value),
                  icon: const Icon(Icons.sync_rounded, size: 16),
                  label: const Text('Apply Custom Status', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _ProgressStepper extends StatelessWidget {
  const _ProgressStepper({required this.currentStep});

  final int currentStep;

  static const List<Map<String, String>> steps = [
    {'title': 'Placed', 'subtitle': 'Pending'},
    {'title': 'Confirmed', 'subtitle': 'Accepted'},
    {'title': 'Shipping', 'subtitle': 'In Transit'},
    {'title': 'Delivered', 'subtitle': 'Complete'},
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (i > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i <= currentStep
                              ? OrderDetailView.emeraldColor
                              : const Color(0xFF2E3033),
                        ),
                      )
                    else
                      const Spacer(),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: i < currentStep
                            ? OrderDetailView.emeraldColor
                            : (i == currentStep
                                ? OrderDetailView.emeraldColor.withValues(alpha: 0.25)
                                : const Color(0xFF222427)),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: i <= currentStep
                              ? OrderDetailView.emeraldColor
                              : const Color(0xFF373A40),
                          width: i == currentStep ? 2 : 1.5,
                        ),
                      ),
                      child: Center(
                        child: i < currentStep
                            ? const Icon(Icons.check_rounded, size: 13, color: Colors.black)
                            : (i == currentStep
                                ? Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: OrderDetailView.emeraldColor,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : null),
                      ),
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: i < currentStep
                              ? OrderDetailView.emeraldColor
                              : const Color(0xFF2E3033),
                        ),
                      )
                    else
                      const Spacer(),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  steps[i]['title']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: i <= currentStep ? Colors.white : const Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: i == currentStep ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
                Text(
                  steps[i]['subtitle']!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: i <= currentStep ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
                    fontSize: 9.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ==========================================
// 4. ITEMIZED PRODUCTS CARD
// ==========================================
class _OrderProductsCard extends StatelessWidget {
  const _OrderProductsCard({
    required this.order,
    required this.item,
  });

  final OrderInfo? order;
  final ShopOrderItem? item;

  @override
  Widget build(BuildContext context) {
    final List<ShopOrderItem> items =
        (order?.items != null && order!.items!.isNotEmpty)
            ? order!.items!
            : (item != null ? [item!] : []);

    if (items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: OrderDetailView.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: OrderDetailView.borderColor),
        ),
        child: const Center(
          child: Text(
            'No item details available',
            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          _ProductItemTile(item: items[i]),
          if (i < items.length - 1) const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ProductItemTile extends StatelessWidget {
  const _ProductItemTile({required this.item});

  final ShopOrderItem item;

  @override
  Widget build(BuildContext context) {
    final String? imageUrl = item.fullImageUrl;
    final double unitPrice = item.unitPrice ?? 0;
    final int qty = item.qty ?? 1;
    final double lineTotal = item.lineTotal ?? (unitPrice * qty);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OrderDetailView.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: OrderDetailView.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF26282B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF373A40)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: imageUrl != null && imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(
                              Icons.shopping_bag_outlined,
                              color: OrderDetailView.emeraldColor,
                              size: 24,
                            ),
                          ),
                        )
                      : const Center(
                          child: Icon(
                            Icons.shopping_bag_outlined,
                            color: OrderDetailView.emeraldColor,
                            size: 24,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Product Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName ?? 'Product item',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (item.sku != null && item.sku!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF26282B),
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(color: const Color(0xFF373A40)),
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.isSettleWithSeller == 1
                                ? const Color(0x2610B981)
                                : const Color(0x26F59E0B),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            item.isSettleWithSeller == 1 ? 'Settled' : 'Pending Settlement',
                            style: TextStyle(
                              color: item.isSettleWithSeller == 1
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFF59E0B),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: OrderDetailView.borderColor),
          const SizedBox(height: 10),

          // Price & Quantity Breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222427),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Qty: x$qty',
                      style: const TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '× ${OrderDetailView.money(unitPrice)}',
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Text(
                    'Total: ',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    OrderDetailView.money(lineTotal),
                    style: const TextStyle(
                      color: OrderDetailView.emeraldColor,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 5. CUSTOMER & DELIVERY DETAILS CARD
// ==========================================
class _CustomerDeliveryCard extends StatelessWidget {
  const _CustomerDeliveryCard({required this.order});

  final OrderInfo? order;

  @override
  Widget build(BuildContext context) {
    final String customerName =
        (order?.customerName ?? order?.user?.name ?? 'Guest Customer').trim();
    final String phone =
        (order?.customerPhone ?? order?.user?.phone ?? '').trim();
    final String email = (order?.user?.email ?? '').trim();
    final String address = (order?.shippingAddress ?? '').trim();
    final String zone = (order?.zone ?? '').trim();
    final String district = (order?.district ?? '').trim();
    final String area = (order?.area ?? '').trim();
    final String note = (order?.note ?? '').trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrderDetailView.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OrderDetailView.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Name & Profile
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFF26282B),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    customerName.isNotEmpty ? customerName[0].toUpperCase() : 'C',
                    style: const TextStyle(
                      color: OrderDetailView.emeraldColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, color: OrderDetailView.borderColor),
          const SizedBox(height: 12),

          // Contact Phone with Call + Copy
          if (phone.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.phone_rounded,
              label: 'Phone',
              content: phone,
              actions: [
                InkWell(
                  onTap: () => OrderDetailView.makeCall(phone),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x2634D399),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.call, size: 11, color: OrderDetailView.emeraldColor),
                        SizedBox(width: 3),
                        Text('Call', style: TextStyle(color: OrderDetailView.emeraldColor, fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: phone));
                    Get.snackbar('Copied', 'Phone copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: OrderDetailView.cardColor,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2));
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.copy_rounded, size: 14, color: Color(0xFF9CA3AF)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Shipping Address with Open Map + Copy
          if (address.isNotEmpty) ...[
            _InfoRow(
              icon: Icons.location_on_rounded,
              label: 'Shipping',
              content: address,
              actions: [
                InkWell(
                  onTap: () => OrderDetailView.openMap(address),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0x26A78BFA),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.navigation_rounded, size: 11, color: Color(0xFFA78BFA)),
                        SizedBox(width: 3),
                        Text('Map', style: TextStyle(color: Color(0xFFA78BFA), fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: address));
                    Get.snackbar('Copied', 'Address copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: OrderDetailView.cardColor,
                        colorText: Colors.white,
                        duration: const Duration(seconds: 2));
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(2),
                    child: Icon(Icons.copy_rounded, size: 14, color: Color(0xFF9CA3AF)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          // Zone / Area / District Pills
          if (zone.isNotEmpty || district.isNotEmpty || area.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  if (area.isNotEmpty) _TagPill(label: 'Area: $area'),
                  if (zone.isNotEmpty) _TagPill(label: 'Zone: $zone'),
                  if (district.isNotEmpty) _TagPill(label: 'District: $district'),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],

          // Customer Note
          if (note.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: OrderDetailView.amberColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: OrderDetailView.amberColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.note_alt_outlined, color: OrderDetailView.amberColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Note',
                          style: TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          note,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.content,
    this.actions,
  });

  final IconData icon;
  final String label;
  final String content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (actions != null) Row(mainAxisSize: MainAxisSize.min, children: actions!),
      ],
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: const Color(0xFF26282B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF373A40)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFD1D5DB),
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ==========================================
// 6. FINANCIAL & PAYMENT BREAKDOWN
// ==========================================
class _FinancialSummaryCard extends StatelessWidget {
  const _FinancialSummaryCard({
    required this.order,
    required this.item,
  });

  final OrderInfo? order;
  final ShopOrderItem? item;

  @override
  Widget build(BuildContext context) {
    final double subtotal = order?.subtotal ?? item?.lineTotal ?? 0;
    final double shippingFee = order?.shippingFee ?? 0;
    final double discount = order?.discount ?? 0;
    final double total = order?.total ?? item?.lineTotal ?? 0;
    final double paidAmount = order?.paidAmount ?? 0;
    final double dueAmount = order?.dueAmount ?? 0;
    final String paymentStatus = order?.paymentStatus ?? 'N/A';
    final String paymentMethod = (order?.paymentMethod ?? 'N/A').toUpperCase();
    final String platform = (order?.platform ?? 'Direct').toUpperCase();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrderDetailView.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OrderDetailView.borderColor),
      ),
      child: Column(
        children: [
          _RowItem(label: 'Subtotal', value: OrderDetailView.money(subtotal)),
          _RowItem(label: 'Shipping / Delivery', value: OrderDetailView.money(shippingFee)),
          if (discount > 0)
            _RowItem(
              label: 'Discount',
              value: '-${OrderDetailView.money(discount)}',
              valueColor: const Color(0xFF34D399),
            ),
          const Divider(height: 18, color: OrderDetailView.borderColor),
          _RowItem(
            label: 'Total Amount',
            value: OrderDetailView.money(total),
            isBold: true,
            valueColor: OrderDetailView.emeraldColor,
            fontSize: 15,
          ),
          if (paidAmount > 0) ...[
            const SizedBox(height: 4),
            _RowItem(label: 'Paid Amount', value: OrderDetailView.money(paidAmount)),
          ],
          if (dueAmount > 0) ...[
            const SizedBox(height: 4),
            _RowItem(
              label: 'Due Amount (Baki)',
              value: OrderDetailView.money(dueAmount),
              valueColor: const Color(0xFFFBBF24),
              isBold: true,
            ),
          ],
          if (order?.dueDate != null) ...[
            const SizedBox(height: 4),
            _RowItem(
              label: 'Due Date',
              value: OrderDetailView._formatDateTime(order!.dueDate),
              valueColor: const Color(0xFFFBBF24),
            ),
          ],
          const Divider(height: 18, color: OrderDetailView.borderColor),
          _RowItem(
            label: 'Payment Method',
            value: paymentMethod,
          ),
          _RowItem(
            label: 'Payment Status',
            valueWidget: OrderStatusBadge(status: paymentStatus, isCompact: true),
          ),
          _RowItem(
            label: 'Platform Channel',
            value: platform,
          ),
        ],
      ),
    );
  }
}

class _RowItem extends StatelessWidget {
  const _RowItem({
    required this.label,
    this.value,
    this.valueWidget,
    this.valueColor,
    this.isBold = false,
    this.fontSize = 13,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final Color? valueColor;
  final bool isBold;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.white : const Color(0xFF9CA3AF),
              fontSize: fontSize,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          valueWidget ??
              Text(
                value ?? 'N/A',
                style: TextStyle(
                  color: valueColor ?? (isBold ? Colors.white : const Color(0xFFD1D5DB)),
                  fontSize: fontSize,
                  fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                ),
              ),
        ],
      ),
    );
  }
}

// ==========================================
// 7. ORDER ACTIVITY & METADATA TIMELINE
// ==========================================
class _OrderTimelineCard extends StatelessWidget {
  const _OrderTimelineCard({
    required this.order,
    required this.item,
  });

  final OrderInfo? order;
  final ShopOrderItem? item;

  @override
  Widget build(BuildContext context) {
    final DateTime? created = order?.createdAt ?? item?.createdAt;
    final DateTime? updated = order?.updatedAt ?? item?.updatedAt;
    final String paymentGroupId = (order?.paymentGroupId ?? '').trim();
    final String orderId = (order?.id ?? item?.orderId ?? item?.id ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrderDetailView.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OrderDetailView.borderColor),
      ),
      child: Column(
        children: [
          _TimelineStep(
            icon: Icons.add_shopping_cart_rounded,
            title: 'Order Created',
            subtitle: OrderDetailView._formatDateTime(created),
            isFirst: true,
          ),
          _TimelineStep(
            icon: Icons.update_rounded,
            title: 'Last Activity Updated',
            subtitle: OrderDetailView._formatDateTime(updated),
          ),
          if (paymentGroupId.isNotEmpty)
            _TimelineStep(
              icon: Icons.receipt_long_rounded,
              title: 'Payment Reference',
              subtitle: paymentGroupId,
            ),
          _TimelineStep(
            icon: Icons.numbers_rounded,
            title: 'System Order ID',
            subtitle: '#$orderId',
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
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
              child: Icon(icon, size: 14, color: OrderDetailView.emeraldColor),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 22,
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
                    fontSize: 12.5,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.icon,
    this.action,
  });

  final String title;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: OrderDetailView.emeraldColor, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.1,
          ),
        ),
        if (action != null) ...[
          const Spacer(),
          action!,
        ],
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

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
