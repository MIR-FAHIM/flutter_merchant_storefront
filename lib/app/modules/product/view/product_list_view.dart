import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widgets/product_card.dart';

class ProductListView extends GetView<ProductController> {
  const ProductListView({super.key});

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
          'Products',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Marketplace Categories',
            onPressed: () {
              Get.toNamed(
                Routes.MARKETPLACE_CATEGORIES,
                arguments: {'storeId': controller.shopId},
              );
            },
            icon: const Icon(Icons.category_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.PRODUCT_ADD),
        backgroundColor: const Color(0xFF34D399),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Product',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          _ProductFilterBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isInitialLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.errorMessage.value.isNotEmpty &&
                  controller.products.isEmpty) {
                return _ProductErrorView(
                  message: controller.errorMessage.value,
                  onRetry: controller.refreshProducts,
                );
              }

              if (controller.products.isEmpty) {
                return _ProductEmptyView(
                  onRefresh: controller.refreshProducts,
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshProducts,
                child: CustomScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _ProductListHeader(
                        total: controller.totalProducts.value,
                        showing: controller.products.length,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = controller.products[index];

                            return ProductCard(
                              product: product,
                              onTap: () {
                                Get.toNamed(
                                  Routes.PRODUCT_DETAILS,
                                  arguments: {
                                    'product_id': product.id,
                                  },
                                );
                              },
                            );
                          },
                          childCount: controller.products.length,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.62,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Obx(() {
                        if (!controller.isMoreLoading.value) {
                          return const SizedBox(height: 24);
                        }

                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }),
                    ),
                    SliverToBoxAdapter(
                      child: Obx(() {
                        if (controller.hasMore) {
                          return const SizedBox.shrink();
                        }

                        return const Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Center(
                            child: Text(
                              'No more products',
                              style: TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ProductFilterBar extends StatelessWidget {
  const _ProductFilterBar({
    required this.controller,
  });

  final ProductController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ProductListView._cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ProductListView._borderColor),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller.productSearchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => controller.applyProductFilters(),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search product name or slug',
              hintStyle: const TextStyle(color: Color(0xFF6B7280)),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF9CA3AF),
              ),
              suffixIcon: IconButton(
                tooltip: 'Search',
                onPressed: controller.applyProductFilters,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
              filled: true,
              fillColor: const Color(0xFF111213),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Obx(() {
            return Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: controller.productFilterCategoryId.value,
                    dropdownColor: ProductListView._cardColor,
                    isExpanded: true,
                    decoration: _filterDecoration(
                      icon: Icons.category_outlined,
                      hint: 'Category',
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('All Categories'),
                      ),
                      ...controller.activeCategories.map(
                        (category) => DropdownMenuItem<String>(
                          value: category.id.toString(),
                          child: Text(
                            category.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      controller.setProductFilterCategory(value ?? '');
                      controller.applyProductFilters();
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 132,
                  child: DropdownButtonFormField<String>(
                    value: controller.productFilterIsActive.value == null
                        ? 'all'
                        : controller.productFilterIsActive.value == true
                            ? 'active'
                            : 'inactive',
                    dropdownColor: ProductListView._cardColor,
                    decoration: _filterDecoration(
                      icon: Icons.tune_rounded,
                      hint: 'Status',
                    ),
                    items: const [
                      DropdownMenuItem<String>(
                        value: 'all',
                        child: Text('All'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'active',
                        child: Text('Active'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'inactive',
                        child: Text('Inactive'),
                      ),
                    ],
                    onChanged: (value) {
                      controller.setProductFilterStatus(
                        value == 'all' ? null : value == 'active',
                      );
                      controller.applyProductFilters();
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Clear filters',
                  onPressed: controller.clearProductFilters,
                  icon: const Icon(Icons.close_rounded),
                  color: const Color(0xFF9CA3AF),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  InputDecoration _filterDecoration({
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
      prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 18),
      filled: true,
      fillColor: const Color(0xFF111213),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    );
  }
}

class _ProductListHeader extends StatelessWidget {
  const _ProductListHeader({
    required this.total,
    required this.showing,
  });

  final int total;
  final int showing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ProductListView._cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ProductListView._borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF60A5FA),
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shop Products',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Showing $showing of $total products',
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

class _ProductEmptyView extends StatelessWidget {
  const _ProductEmptyView({
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
            Icons.inventory_2_outlined,
            color: Color(0xFF6B7280),
            size: 64,
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'No products found',
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

class _ProductErrorView extends StatelessWidget {
  const _ProductErrorView({
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
          color: ProductListView._cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: ProductListView._borderColor,
          ),
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
