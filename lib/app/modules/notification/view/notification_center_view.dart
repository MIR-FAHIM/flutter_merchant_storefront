
import 'package:ecom_delivery_flutter/app/models/notification/notification_center_model.dart';
import 'package:ecom_delivery_flutter/app/modules/notification/controller/notification_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/common/Color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationCenterView extends GetView<NotificationController> {
  const NotificationCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Obx(() => controller.unreadCount.value == 0
              ? const SizedBox.shrink()
              : TextButton(
                  onPressed: controller.markAllAsRead,
                  child: const Text('Mark all as read', style: TextStyle(color: Colors.white)),
                )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.visibleItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.refreshNotifications,
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 180) {
                controller.fetchNotifications(reset: false);
              }
              return false;
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _Summary()),
                SliverToBoxAdapter(child: _Tabs()),
                if (controller.error.value.isNotEmpty && controller.visibleItems.isEmpty)
                  SliverFillRemaining(hasScrollBody: false, child: _ErrorState())
                else if (controller.visibleItems.isEmpty)
                  SliverFillRemaining(hasScrollBody: false, child: _EmptyState())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => _NotificationTile(item: controller.visibleItems[index]),
                      childCount: controller.visibleItems.length,
                    ),
                  ),
                if (controller.isLoadingMore.value)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _Summary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
          child: Text(
            controller.unreadCount.value == 0
                ? "You're all caught up"
                : '${controller.unreadCount.value} unread notifications',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ));
  }
}

class _Tabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: SegmentedButton<int>(
            style: ButtonStyle(
              foregroundColor: WidgetStateProperty.resolveWith<Color?>((states) => Colors.white),
              iconColor: WidgetStateProperty.resolveWith<Color?>((states) => Colors.white),
            ),
            segments: const [
              ButtonSegment(
                value: 0,
                label: Text('All', style: TextStyle(color: Colors.white)),
              ),
              ButtonSegment(
                value: 1,
                label: Text('Orders', style: TextStyle(color: Colors.white)),
              ),
              ButtonSegment(
                value: 2,
                label: Text('General', style: TextStyle(color: Colors.white)),
              ),
            ],
            selected: {controller.selectedTab.value},
            onSelectionChanged: (value) => controller.selectedTab.value = value.first,
          ),
        ));
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});
  final Object item;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<NotificationController>();
    final isOrder = item is OrderNotificationGroup;
    final group = isOrder ? item as OrderNotificationGroup : null;
    final notification = group?.latest ?? item as NotificationItem;
    final unread = group?.isUnread ?? !notification.isRead;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      elevation: unread ? 2 : 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          if (group != null) {
            await Get.toNamed(Routes.ORDER_NOTIFICATION, arguments: {
              'orderId': group.orderId,
              'title': group.title,
            });
          } else {
            await Get.toNamed(Routes.GENERAL_NOTIFICATION, arguments: notification);
            await controller.fetchUnreadCount();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primaryColor.withOpacity(0.10),
                child: Icon(isOrder ? Icons.shopping_bag_outlined : Icons.notifications_none_rounded,
                    color: AppColors.primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(group?.title ?? notification.title, style: const TextStyle(fontWeight: FontWeight.w800))),
                    if (unread) const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.circle, size: 9, color: Colors.red)),
                  ]),
                  const SizedBox(height: 5),
                  Text(notification.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (notification.message.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(notification.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                  const SizedBox(height: 7),
                  Text(
                    '${group == null ? '' : '${group.notifications.isEmpty ? 1 : group.notifications.length} update · '}${_time(notification.createdAt)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.notifications_off_outlined, size: 56, color: Colors.black38),
          SizedBox(height: 12),
          Text('No notifications yet', style: TextStyle(fontWeight: FontWeight.w700)),
          SizedBox(height: 4),
          Text("You're all caught up."),
        ]),
      );
}

class _ErrorState extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.cloud_off_outlined, size: 52),
            const SizedBox(height: 12),
            const Text('Unable to load notifications'),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: () => Get.find<NotificationController>().fetchNotifications(), child: const Text('Try again')),
          ]),
        ),
      );
}

String _time(DateTime? date) => date == null ? '' : DateFormat('h:mm a').format(date.toLocal());
