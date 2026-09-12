import 'package:ecom_delivery_flutter/app/models/seller_customer_list_model.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_customers/controllers/seller_customer_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerCustomerDetailView extends StatefulWidget {
  const SellerCustomerDetailView({super.key});

  @override
  State<SellerCustomerDetailView> createState() =>
      _SellerCustomerDetailViewState();
}

class _SellerCustomerDetailViewState extends State<SellerCustomerDetailView> {
  late final SellerCustomerController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<SellerCustomerController>();
    final args = Get.arguments;
    if (args is Map && args['customer'] is SellerPreferredCustomer) {
      controller.setSelectedCustomer(args['customer'] as SellerPreferredCustomer);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final customer = controller.selectedCustomer.value;
      if (customer != null) {
        controller.fetchCustomerOrders(
          shopId: _shopId,
          userId: customer.customer.id,
          refresh: true,
        );
      }
    });
  }

  int get _shopId {
    return Get.find<AuthService>().currentUser.value.data?.user?.shop?.id ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFF111213),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111213),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Obx(() {
            final customer = controller.selectedCustomer.value?.customer;
            return Text(
              customer?.name.trim().isNotEmpty == true
                  ? customer!.name
                  : 'Customer Details',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            );
          }),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFF34D399),
            unselectedLabelColor: Color(0xFF9CA3AF),
            indicatorColor: Color(0xFF34D399),
            tabs: [
              Tab(text: 'Orders'),
              Tab(text: 'Hishab/Nikash'),

              Tab(text: 'Communications'),
              Tab(text: 'Notes'),
            ],
          ),
        ),
        body: Obx(() {
          final customer = controller.selectedCustomer.value;
          if (customer == null) {
            return const _EmptyTabState(
              icon: Icons.person_off_outlined,
              title: 'Customer not found',
              message: 'Please open this page from the customer list.',
            );
          }

          return TabBarView(
            children: [

              _CustomerOrdersTab(
                controller: controller,
                shopId: _shopId,
                userId: customer.customer.id,
              ),
              _PlaceholderTab(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Hishab/Nikash',
                message: 'Customer balance and account records will appear here.',
              ),
              const _PlaceholderTab(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'Communications',
                message: 'Calls, messages, and chat history will appear here.',
              ),
              const _PlaceholderTab(
                icon: Icons.note_alt_outlined,
                title: 'Notes',
                message: 'Seller notes for this customer will appear here.',
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CustomerOrdersTab extends StatelessWidget {
  const _CustomerOrdersTab({
    required this.controller,
    required this.shopId,
    required this.userId,
  });

  final SellerCustomerController controller;
  final int shopId;
  final int userId;

  Future<void> _refresh() {
    return controller.fetchCustomerOrders(
      shopId: shopId,
      userId: userId,
      refresh: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingCustomerOrders.value &&
          controller.customerOrders.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.customerOrdersError.value.isNotEmpty &&
          controller.customerOrders.isEmpty) {
        return _RetryTabState(
          icon: Icons.warning_amber_rounded,
          title: 'Could not load orders',
          message: controller.customerOrdersError.value,
          onRetry: _refresh,
        );
      }

      if (controller.customerOrders.isEmpty) {
        return const _EmptyTabState(
          icon: Icons.receipt_long_outlined,
          title: 'No orders found',
          message: 'This customer has no orders for this shop yet.',
        );
      }

      return RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 24),
          itemCount: controller.customerOrders.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final order = controller.customerOrders[index];
            return _CustomerOrderTile(order: order);
          },
        ),
      );
    });
  }
}

class _CustomerOrderTile extends StatelessWidget {
  const _CustomerOrderTile({required this.order});

  final SellerCustomerOrder order;

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      if ((order.status ?? '').isNotEmpty) order.status!,
      if ((order.paymentStatus ?? '').isNotEmpty) order.paymentStatus!,
      if (order.total != null) '৳${order.total}',
    ].join(' - ');

    return InkWell(
      onTap: () => Get.toNamed(
        Routes.ORDER_SHOP_DETAIL,
        arguments: {'order_id': order.id},
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1C1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2E3033)),
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF063F3A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: Color(0xFF34D399),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.orderNumber ?? 'Order #${order.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF6B7280),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return _EmptyTabState(icon: icon, title: title, message: message);
  }
}

class _RetryTabState extends StatelessWidget {
  const _RetryTabState({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _EmptyTabState(
      icon: icon,
      title: title,
      message: message,
      action: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Retry'),
      ),
    );
  }
}

class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF34D399), size: 46),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w600,
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 14),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
