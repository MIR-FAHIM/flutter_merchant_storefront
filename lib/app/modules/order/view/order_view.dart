import 'package:ecom_delivery_flutter/app/modules/order/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widgets/order_card.dart';

class OrderListView extends GetView<OrderController> {
  const OrderListView({super.key});

  static const Color _bgColor = Color(0xFF111213);
  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _borderColor = Color(0xFF2E3033);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Orders',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isInitialLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.orderItems.isEmpty) {
          return _OrderErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.refreshOrders,
          );
        }

        if (controller.orderItems.isEmpty) {
          return _OrderEmptyView(
            onRefresh: controller.refreshOrders,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshOrders,
          child: ListView.separated(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            itemCount: controller.orderItems.length + 2,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _OrderHeader(
                  total: controller.totalOrders.value,
                  showing: controller.orderItems.length,
                );
              }

              final int realIndex = index - 1;

              if (realIndex >= controller.orderItems.length) {
                return Obx(() {
                  if (controller.isMoreLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (!controller.hasMore) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Center(
                        child: Text(
                          'No more orders',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                });
              }

              final item = controller.orderItems[realIndex];

              return OrderCard(
                item: item,
                onTap: () {
                  controller.openOrderDetail(item);
                },
              );
            },
          ),
        );
      }),
    );
  }
}

class _OrderHeader extends StatelessWidget {
  const _OrderHeader({
    required this.total,
    required this.showing,
  });

  final int total;
  final int showing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: OrderListView._cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: OrderListView._borderColor),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFF34D399),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shop Orders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Showing $showing of $total orders',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
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

class _OrderEmptyView extends StatelessWidget {
  const _OrderEmptyView({
    required this.onRefresh,
  });

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          Icon(
            Icons.receipt_long_outlined,
            color: Color(0xFF6B7280),
            size: 64,
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'No orders found',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderErrorView extends StatelessWidget {
  const _OrderErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: OrderListView._cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: OrderListView._borderColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 52,
            ),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD1D5DB),
                fontSize: 13.5,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}