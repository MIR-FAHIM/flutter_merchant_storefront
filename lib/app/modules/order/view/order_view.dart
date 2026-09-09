import 'package:ecom_delivery_flutter/app/modules/order/controller/order_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widgets/order_card.dart';

class OrderListView extends StatefulWidget {
  const OrderListView({super.key});

  static const Color bgColor = Color(0xFF111213);
  static const Color cardColor = Color(0xFF1B1C1E);
  static const Color borderColor = Color(0xFF2E3033);

  @override
  State<OrderListView> createState() => _OrderListViewState();
}

class _OrderListViewState extends State<OrderListView> {
  final OrderController controller = Get.find<OrderController>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilterStatus = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrderListView.bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: OrderListView.bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Orders Overview',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isInitialLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF34D399)),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.orderItems.isEmpty) {
          return _OrderErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.refreshOrders,
          );
        }

        final filteredItems = controller.orderItems.where((item) {
          final order = item.order;

          // Status filter
          if (_selectedFilterStatus != 'all') {
            final status = (item.status ?? order?.status ?? '').toLowerCase();
            if (_selectedFilterStatus == 'pending' &&
                status != 'pending' &&
                status != 'unpaid') {
              return false;
            } else if (_selectedFilterStatus == 'processing' &&
                status != 'processing' &&
                status != 'confirmed' &&
                status != 'accepted') {
              return false;
            } else if (_selectedFilterStatus == 'delivered' &&
                status != 'delivered' &&
                status != 'completed') {
              return false;
            } else if (_selectedFilterStatus == 'cancelled' &&
                status != 'cancelled' &&
                status != 'canceled' &&
                status != 'failed') {
              return false;
            }
          }

          // Search filter
          if (_searchQuery.trim().isNotEmpty) {
            final query = _searchQuery.trim().toLowerCase();
            final orderNum = (order?.orderNumber ?? '').toLowerCase();
            final orderId = (item.orderId ?? item.id ?? '').toString().toLowerCase();
            final product = (item.productName ?? '').toLowerCase();
            final customer = (order?.customerName ?? order?.user?.name ?? '').toLowerCase();
            final sku = (item.sku ?? '').toLowerCase();

            return orderNum.contains(query) ||
                orderId.contains(query) ||
                product.contains(query) ||
                customer.contains(query) ||
                sku.contains(query);
          }

          return true;
        }).toList();

        return RefreshIndicator(
          onRefresh: controller.refreshOrders,
          color: const Color(0xFF34D399),
          backgroundColor: OrderListView.cardColor,
          child: CustomScrollView(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Search & Filter Header Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                  child: Column(
                    children: [
                      // Overview Header Card
                      _OrderHeader(
                        total: controller.totalOrders.value,
                        showing: filteredItems.length,
                      ),
                      const SizedBox(height: 12),

                      // Search Input Field
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search order #, product, customer, SKU...',
                          hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: Color(0xFF9CA3AF), size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: OrderListView.cardColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: OrderListView.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF34D399), width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Filter Status Horizontal Scroll Bar
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _FilterPill(
                              label: 'All Orders',
                              isSelected: _selectedFilterStatus == 'all',
                              onTap: () => setState(() => _selectedFilterStatus = 'all'),
                            ),
                            const SizedBox(width: 8),
                            _FilterPill(
                              label: 'Pending',
                              isSelected: _selectedFilterStatus == 'pending',
                              color: const Color(0xFFF59E0B),
                              onTap: () => setState(() => _selectedFilterStatus = 'pending'),
                            ),
                            const SizedBox(width: 8),
                            _FilterPill(
                              label: 'Processing',
                              isSelected: _selectedFilterStatus == 'processing',
                              color: const Color(0xFF3B82F6),
                              onTap: () => setState(() => _selectedFilterStatus = 'processing'),
                            ),
                            const SizedBox(width: 8),
                            _FilterPill(
                              label: 'Delivered',
                              isSelected: _selectedFilterStatus == 'delivered',
                              color: const Color(0xFF10B981),
                              onTap: () => setState(() => _selectedFilterStatus = 'delivered'),
                            ),
                            const SizedBox(width: 8),
                            _FilterPill(
                              label: 'Cancelled',
                              isSelected: _selectedFilterStatus == 'cancelled',
                              color: const Color(0xFFEF4444),
                              onTap: () => setState(() => _selectedFilterStatus = 'cancelled'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Empty Filter State
              if (filteredItems.isEmpty && controller.orderItems.isNotEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.search_off_rounded, color: Color(0xFF6B7280), size: 54),
                          const SizedBox(height: 12),
                          const Text(
                            'No matching orders found',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try adjusting your search query or filter chip.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12.5),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF34D399)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _selectedFilterStatus = 'all';
                              });
                            },
                            child: const Text('Reset Filters', style: TextStyle(color: Color(0xFF34D399))),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (controller.orderItems.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _OrderEmptyView(onRefresh: controller.refreshOrders),
                )
              else
                // Orders List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == filteredItems.length) {
                          return Obx(() {
                            if (controller.isMoreLoading.value) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(color: Color(0xFF34D399)),
                                ),
                              );
                            }

                            if (!controller.hasMore && controller.orderItems.isNotEmpty) {
                              return const Padding(
                                padding: EdgeInsets.only(top: 16, bottom: 8),
                                child: Center(
                                  child: Text(
                                    'No more orders to load',
                                    style: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          });
                        }

                        final item = filteredItems[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: OrderCard(
                            item: item,
                            onTap: () => controller.openOrderDetail(item),
                          ),
                        );
                      },
                      childCount: filteredItems.length + 1,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? const Color(0xFF34D399);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.18) : OrderListView.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : OrderListView.borderColor,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : const Color(0xFF9CA3AF),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OrderListView.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: OrderListView.borderColor),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              color: Color(0xFF34D399),
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shop Orders Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Showing $showing of $total total orders',
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: OrderListView.cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: OrderListView.borderColor),
              ),
              child: const Icon(
                Icons.inbox_rounded,
                color: Color(0xFF6B7280),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Orders Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'When customers place orders, they will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34D399),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh Orders', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: OrderListView.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: OrderListView.borderColor),
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
            const Text(
              'Failed to Load Orders',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD1D5DB),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF34D399),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}