import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';
import 'package:ecom_delivery_flutter/app/models/product/product_response_model.dart';
import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

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
                  controller.shopProducts.isEmpty) {
                return _ProductErrorView(
                  message: controller.errorMessage.value,
                  onRetry: controller.refreshProducts,
                );
              }

              if (controller.shopProducts.isEmpty) {
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
                        showing: controller.shopProducts.length,
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = controller.shopProducts[index];

                            return ProductCard(
                              product: product,
                              onTap: () {
                                _showProductActions(
                                  context: context,
                                  product: product,
                                  controller: controller,
                                );
                              },
                            );
                          },
                          childCount: controller.shopProducts.length,
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

void _showProductActions({
  required BuildContext context,
  required ProductData product,
  required ProductController controller,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: ProductListView._cardColor,
    barrierColor: Colors.black.withOpacity(0.55),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B5563),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                product.name ?? 'পণ্য',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'একটি অপশন বেছে নিন',
                style: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              _ProductActionTile(
                icon: Icons.visibility_outlined,
                label: 'বিস্তারিত দেখুন',
                color: const Color(0xFF60A5FA),
                onTap: () {
                  Get.back();
                  Get.toNamed(
                    Routes.PRODUCT_DETAILS,
                    arguments: {'product_id': product.id},
                  );
                },
              ),
              _ProductActionTile(
                icon: Icons.copy_rounded,
                label: 'ডুপ্লিকেট করুন',
                color: const Color(0xFF34D399),
                onTap: () {
                  Get.back();
                  controller.prepareDuplicateProduct(product);
                  Get.toNamed(Routes.PRODUCT_ADD);
                },
              ),
              _ProductActionTile(
                icon: Icons.inventory_rounded,
                label: 'স্টক আপডেট করুন',
                color: const Color(0xFFFBBF24),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  Future.microtask(
                    () => _showStockUpdateSheet(
                      context: context,
                      product: product,
                      controller: controller,
                    ),
                  );
                },
              ),
              _ProductActionTile(
                icon: Icons.share_outlined,
                label: 'শেয়ার করুন',
                color: const Color(0xFF2DD4BF),
                onTap: () {
                  Get.back();
                  Share.share(_productShareText(product));
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _productShareText(ProductData product) {
  final name = product.name?.trim().isNotEmpty == true
      ? product.name!.trim()
      : 'Product';
  final price = product.unitPrice == null ? '' : '\nPrice: ৳${product.unitPrice}';
  final storeUrl = product.slug?.trim().isNotEmpty == true
      ? '\n${CompanyData.publicStoreBaseUrl}/${product.slug}'
      : '';

  return '$name$price$storeUrl';
}

void _showStockUpdateSheet({
  required BuildContext context,
  required ProductData product,
  required ProductController controller,
}) {
  int stock = product.currentStock ?? 0;
  bool isSaving = false;

  showModalBottomSheet(
    context: context,
    backgroundColor: ProductListView._cardColor,
    barrierColor: Colors.black.withOpacity(0.55),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4B5563),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    product.name ?? 'পণ্য',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'বর্তমান স্টক আপডেট করুন',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111213),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ProductListView._borderColor),
                    ),
                    child: Row(
                      children: [
                        _StockStepperButton(
                          icon: Icons.remove_rounded,
                          onTap: isSaving || stock <= 0
                              ? null
                              : () => setModalState(() => stock--),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              const Text(
                                'বর্তমান স্টক',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                stock.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _StockStepperButton(
                          icon: Icons.add_rounded,
                          onTap: isSaving
                              ? null
                              : () => setModalState(() => stock++),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSaving
                          ? null
                          : () async {
                              final productId = product.id;
                              if (productId == null || productId <= 0) {
                                Get.snackbar(
                                  'স্টক আপডেট ব্যর্থ হয়েছে',
                                  'সঠিক পণ্য নির্বাচন করা হয়নি।',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                                return;
                              }

                              setModalState(() => isSaving = true);
                              final saved = await controller.updateProductStock(
                                productId: productId,
                                currentStock: stock,
                              );
                              setModalState(() => isSaving = false);

                              if (saved) {
                                Navigator.of(sheetContext).pop();
                                Get.snackbar(
                                  'সফল',
                                  'স্টক সফলভাবে আপডেট হয়েছে',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } else {
                                Get.snackbar(
                                  'স্টক আপডেট ব্যর্থ হয়েছে',
                                  controller.saveMessage.value.isNotEmpty
                                      ? controller.saveMessage.value
                                      : 'স্টক আপডেট করতে সমস্যা হয়েছে।',
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.redAccent,
                                );
                              }
                            },
                      icon: isSaving
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save_rounded),
                      label: const Text('স্টক সংরক্ষণ করুন'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34D399),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _StockStepperButton extends StatelessWidget {
  const _StockStepperButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Opacity(
        opacity: onTap == null ? 0.45 : 1,
        child: Container(
          height: 48,
          width: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF1B1C1E),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: ProductListView._borderColor),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF34D399),
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _ProductActionTile extends StatelessWidget {
  const _ProductActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF111213),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ProductListView._borderColor),
        ),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF6B7280),
            ),
          ],
        ),
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
