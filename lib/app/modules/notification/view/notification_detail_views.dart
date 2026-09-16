
import 'package:ecom_delivery_flutter/app/models/notification/notification_center_model.dart';
import 'package:ecom_delivery_flutter/app/modules/notification/controller/notification_controller.dart';
import 'package:ecom_delivery_flutter/common/Color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class OrderNotificationView extends GetView<NotificationController> {
  const OrderNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments is Map ? Get.arguments as Map : const {};
    final orderId = int.tryParse('${args['orderId']}') ?? 0;
    final title = args['title']?.toString() ?? 'Order #$orderId';
    controller.fetchOrderHistory(orderId);
    return Scaffold(
      appBar: AppBar(
          title: Text(title),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white),
      body: Obx(() {
        if (controller.isDetailLoading.value)
          return const Center(child: CircularProgressIndicator());
        if (controller.orderHistory.isEmpty)
          return const Center(child: Text('No order updates'));
        return RefreshIndicator(
          onRefresh: () => controller.fetchOrderHistory(orderId, force: true),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: controller.orderHistory.length,
            itemBuilder: (_, index) => _TimelineItem(
              item: controller.orderHistory[index],
              isLast: index == controller.orderHistory.length - 1,
            ),
          ),
        );
      }),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({required this.item, required this.isLast});
  final NotificationItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final icon = _iconForType(item.type);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(
          width: 42,
          child: Column(children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: item.isRead
                  ? Colors.grey.shade200
                  : AppColors.primaryColor.withOpacity(0.14),
              child: Icon(icon,
                  size: 19,
                  color: item.isRead
                      ? Colors.grey.shade700
                      : AppColors.primaryColor),
            ),
            if (!isLast)
              Expanded(child: Container(width: 2, color: Colors.grey.shade300)),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            margin: const EdgeInsets.only(bottom: 14),
            elevation: item.isRead ? 0.5 : 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                          child: Text(item.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800))),
                      if (!item.isRead)
                        const Text('Unread',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                    ]),
                    if (item.message.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(item.message),
                    ],
                    const SizedBox(height: 8),
                    Text(_dateTime(item.createdAt),
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class GeneralNotificationView extends GetView<NotificationController> {
  const GeneralNotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    final item = Get.arguments as NotificationItem;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Notification'),
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white),
      body: FutureBuilder<bool>(
        future: controller.markNotificationRead(item),
        builder: (_, snapshot) => Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.primaryColor.withOpacity(0.12),
                child: Icon(Icons.notifications_none,
                    color: AppColors.primaryColor)),
            const SizedBox(height: 18),
            Text(item.title,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text(item.message, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 18),
            Text(_dateTime(item.createdAt),
                style: TextStyle(color: Colors.grey.shade600)),
          ]),
        ),
      ),
    );
  }
}

IconData _iconForType(String type) {
  switch (type.toLowerCase()) {
    case 'order_created':
      return Icons.shopping_bag_outlined;
    case 'order_confirmed':
      return Icons.check_circle_outline;
    case 'order_processing':
      return Icons.access_time;
    case 'order_packed':
      return Icons.inventory_2_outlined;
    case 'order_shipped':
      return Icons.local_shipping_outlined;
    case 'order_delivered':
      return Icons.check_circle;
    case 'order_cancelled':
      return Icons.cancel_outlined;
    case 'payment_received':
      return Icons.payments_outlined;
    case 'promotion':
      return Icons.local_offer_outlined;
    default:
      return Icons.notifications_none;
  }
}

String _dateTime(DateTime? value) => value == null
    ? ''
    : DateFormat('dd MMM yyyy · h:mm a').format(value.toLocal());
