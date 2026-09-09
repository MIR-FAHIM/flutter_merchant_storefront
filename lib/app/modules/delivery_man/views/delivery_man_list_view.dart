import 'package:ecom_delivery_flutter/app/models/delivery/delivery_man_model.dart';
import 'package:ecom_delivery_flutter/app/modules/delivery_man/controllers/delivery_man_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class DeliveryManListView extends StatefulWidget {
  const DeliveryManListView({super.key});

  static const Color bgColor = Color(0xFF111213);
  static const Color cardColor = Color(0xFF1B1C1E);
  static const Color borderColor = Color(0xFF2E3033);
  static const Color accentColor = Color(0xFF34D399);

  @override
  State<DeliveryManListView> createState() => _DeliveryManListViewState();
}

class _DeliveryManListViewState extends State<DeliveryManListView> {
  final DeliveryManController controller = Get.find<DeliveryManController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DeliveryManListView.bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: DeliveryManListView.bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Delivery Men',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryManListView.accentColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Get.toNamed(Routes.DELIVERY_MAN_ADD),
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text(
                'Add',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: DeliveryManListView.accentColor,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Delivery Man', style: TextStyle(fontWeight: FontWeight.w800)),
        onPressed: () => Get.toNamed(Routes.DELIVERY_MAN_ADD),
      ),
      body: Obx(() {
        if (controller.isLoadingList.value) {
          return const Center(
            child: CircularProgressIndicator(color: DeliveryManListView.accentColor),
          );
        }

        if (controller.listErrorMessage.value.isNotEmpty &&
            controller.deliveryMenList.isEmpty) {
          return _ListErrorView(
            message: controller.listErrorMessage.value,
            onRetry: () => controller.fetchDeliveryMenList(isRefresh: true),
          );
        }

        final items = controller.deliveryMenList;

        return RefreshIndicator(
          onRefresh: () => controller.fetchDeliveryMenList(isRefresh: true),
          color: DeliveryManListView.accentColor,
          backgroundColor: DeliveryManListView.cardColor,
          child: CustomScrollView(
            controller: controller.listScrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // Header & Search Filter
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                  child: Column(
                    children: [
                      // Header Stats Box
                      _OverviewHeader(
                        total: controller.totalDeliveryMen.value,
                        showing: items.length,
                      ),
                      const SizedBox(height: 12),

                      // Search Input
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.white, fontSize: 13.5),
                        onChanged: (val) {
                          controller.searchFilter.value = val;
                          controller.fetchDeliveryMenList(isRefresh: true);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search by name, phone, email...',
                          hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 20),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: Color(0xFF9CA3AF), size: 18),
                                  onPressed: () {
                                    _searchController.clear();
                                    controller.searchFilter.value = '';
                                    controller.fetchDeliveryMenList(isRefresh: true);
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: DeliveryManListView.cardColor,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: DeliveryManListView.borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: DeliveryManListView.accentColor, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Status Filter Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _StatusFilterPill(
                              label: 'All',
                              isSelected: controller.statusFilter.value == 'all',
                              onTap: () {
                                controller.statusFilter.value = 'all';
                                controller.fetchDeliveryMenList(isRefresh: true);
                              },
                            ),
                            const SizedBox(width: 8),
                            _StatusFilterPill(
                              label: 'Active',
                              isSelected: controller.statusFilter.value == 'active',
                              color: const Color(0xFF10B981),
                              onTap: () {
                                controller.statusFilter.value = 'active';
                                controller.fetchDeliveryMenList(isRefresh: true);
                              },
                            ),
                            const SizedBox(width: 8),
                            _StatusFilterPill(
                              label: 'Inactive',
                              isSelected: controller.statusFilter.value == 'inactive',
                              color: const Color(0xFFEF4444),
                              onTap: () {
                                controller.statusFilter.value = 'inactive';
                                controller.fetchDeliveryMenList(isRefresh: true);
                              },
                            ),
                            const SizedBox(width: 8),
                            _StatusFilterPill(
                              label: 'Pending',
                              isSelected: controller.statusFilter.value == 'pending',
                              color: const Color(0xFFF59E0B),
                              onTap: () {
                                controller.statusFilter.value = 'pending';
                                controller.fetchDeliveryMenList(isRefresh: true);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Empty View
              if (items.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyListView(
                    onAddPressed: () => Get.toNamed(Routes.DELIVERY_MAN_ADD),
                  ),
                )
              else
                // Delivery Men List
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 80),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == items.length) {
                          return Obx(() {
                            if (controller.isMoreLoading.value) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(color: DeliveryManListView.accentColor),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          });
                        }

                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _DeliveryManCard(item: item),
                        );
                      },
                      childCount: items.length + 1,
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

class _OverviewHeader extends StatelessWidget {
  const _OverviewHeader({
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
        color: DeliveryManListView.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DeliveryManListView.borderColor),
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
              Icons.local_shipping_rounded,
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
                  'Shop Delivery Personnel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Showing $showing of $total assigned agents',
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

class _StatusFilterPill extends StatelessWidget {
  const _StatusFilterPill({
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
    final activeColor = color ?? DeliveryManListView.accentColor;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.18) : DeliveryManListView.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : DeliveryManListView.borderColor,
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

class _DeliveryManCard extends StatelessWidget {
  const _DeliveryManCard({required this.item});

  final DeliveryManItem item;

  Future<void> _makeCall(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String name = item.name ?? 'Unnamed Agent';
    final String mobile = item.mobile ?? 'No phone';
    final String status = (item.status ?? 'active').toLowerCase();
    final String type = (item.type ?? 'in_house').replaceAll('_', ' ').toUpperCase();

    Color statusColor = const Color(0xFF10B981);
    if (status == 'inactive') {
      statusColor = const Color(0xFFEF4444);
    } else if (status == 'pending') {
      statusColor = const Color(0xFFF59E0B);
    }

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: DeliveryManListView.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: DeliveryManListView.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF26282B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF373A40)),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: DeliveryManListView.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 12, color: Color(0xFF9CA3AF)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            mobile,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (item.mobile != null && item.mobile!.isNotEmpty)
                IconButton(
                  onPressed: () => _makeCall(item.mobile!),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0x2634D399),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.call, color: DeliveryManListView.accentColor, size: 16),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: DeliveryManListView.borderColor),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Delivery Type Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF26282B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF373A40)),
                ),
                child: Text(
                  type,
                  style: const TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (item.address != null && item.address!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    item.address!.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyListView extends StatelessWidget {
  const _EmptyListView({required this.onAddPressed});

  final VoidCallback onAddPressed;

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
                color: DeliveryManListView.cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: DeliveryManListView.borderColor),
              ),
              child: const Icon(
                Icons.local_shipping_outlined,
                color: Color(0xFF6B7280),
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Delivery Men Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Add your first delivery agent to start dispatching shop orders.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: DeliveryManListView.accentColor,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: onAddPressed,
              icon: const Icon(Icons.person_add_rounded, size: 18),
              label: const Text('Add Delivery Man', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListErrorView extends StatelessWidget {
  const _ListErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(18),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: DeliveryManListView.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: DeliveryManListView.borderColor),
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
              'Failed to Load Delivery Men',
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
                backgroundColor: DeliveryManListView.accentColor,
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
