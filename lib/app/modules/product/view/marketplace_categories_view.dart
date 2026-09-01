import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MarketplaceCategoriesView extends StatefulWidget {
  const MarketplaceCategoriesView({super.key});

  @override
  State<MarketplaceCategoriesView> createState() =>
      _MarketplaceCategoriesViewState();
}

class _MarketplaceCategoriesViewState extends State<MarketplaceCategoriesView> {
  final ProductController controller = Get.find<ProductController>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = Get.arguments;
      final storeId = args is Map && args['storeId'] != null
          ? args['storeId'].toString()
          : args is Map && args['store_id'] != null
              ? args['store_id'].toString()
              : null;

      controller.initializeMarketplaceCategories(storeId: storeId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111213),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF111213),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Marketplace Categories',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Obx(() {
          final disabled = controller.isCategoriesLoading.value ||
              controller.isCategorySyncing.value;

          return Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            decoration: const BoxDecoration(
              color: Color(0xFF111213),
              border: Border(
                top: BorderSide(color: Color(0xFF2E3033)),
              ),
            ),
            child: SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed:
                    disabled ? null : controller.syncMarketplaceCategories,
                icon: controller.isCategorySyncing.value
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(
                  controller.isCategorySyncing.value
                      ? 'Saving Categories'
                      : 'Save Categories',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF078A83),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF2E3033),
                  disabledForegroundColor: const Color(0xFF9CA3AF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
      body: Obx(() {
        if (controller.isCategoriesLoading.value &&
            controller.marketplaceCategories.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.categoryError.value.isNotEmpty &&
            controller.marketplaceCategories.isEmpty) {
          return _StateMessage(
            icon: Icons.error_outline_rounded,
            message: controller.categoryError.value,
          );
        }

        if (controller.marketplaceCategories.isEmpty) {
          return const _StateMessage(
            icon: Icons.category_outlined,
            message: 'No categories available for this store.',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadMarketplaceCategories,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            children: [
              _HeaderCard(controller: controller),
              const SizedBox(height: 12),
              ...controller.marketplaceCategories.map(
                (category) => _CategoryTile(
                  category: category,
                  level: 0,
                  controller: controller,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.controller});

  final ProductController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: Color(0xFF34D399),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Store Category Activation',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.selectedCategoryIds.length} categories active for this store',
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

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.level,
    required this.controller,
  });

  final MarketplaceCategoryNode category;
  final int level;
  final ProductController controller;

  @override
  Widget build(BuildContext context) {
    final childCount = category.children.length;

    return Container(
      margin: EdgeInsets.only(
        left: level == 0 ? 0 : 16,
        bottom: 9,
      ),
      decoration: BoxDecoration(
        color: level == 0 ? const Color(0xFF1B1C1E) : const Color(0xFF17191B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.white.withOpacity(0.04),
        ),
        child: ExpansionTile(
          initiallyExpanded: level < 1,
          collapsedIconColor: childCount > 0 ? Colors.white70 : Colors.transparent,
          iconColor: childCount > 0 ? Colors.white : Colors.transparent,
          tilePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
          title: Row(
            children: [
              Obx(
                () => Checkbox(
                  value: controller.isMarketplaceCategorySelected(category),
                  onChanged: category.id == null
                      ? null
                      : (value) {
                          controller.toggleMarketplaceCategory(
                            category,
                            value ?? false,
                          );
                        },
                  activeColor: const Color(0xFF078A83),
                  checkColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF6B7280)),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      category.slug.isEmpty ? 'no-slug' : category.slug,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (childCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF242629),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$childCount ${childCount == 1 ? 'child' : 'children'}',
                    style: const TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          children: category.children
              .map(
                (child) => _CategoryTile(
                  category: child,
                  level: level + 1,
                  controller: controller,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF078A83), size: 44),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                height: 1.35,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
