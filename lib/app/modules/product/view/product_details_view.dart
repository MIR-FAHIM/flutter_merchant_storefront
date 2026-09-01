import 'package:ecom_delivery_flutter/app/models/product/product_response_model.dart';
import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductDetailsView extends GetView<ProductController> {
  const ProductDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final int productId = (Get.arguments is Map && Get.arguments['product_id'] != null)
        ? int.tryParse(Get.arguments['product_id'].toString()) ?? 0
        : 0;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (productId > 0 && controller.selectedProduct.value?.id != productId) {
        controller.getProductDetails(productId: productId);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF111213),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111213),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        actions: [
          Obx(() {
            final bool canEdit = controller.selectedProduct.value != null;
            return IconButton(
              onPressed: canEdit ? () => Get.toNamed(
                    Routes.PRODUCT_EDIT,
                    arguments: {'product_id': productId},
                  ) : null,
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.detailError.value.isNotEmpty && controller.selectedProduct.value == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 52),
                  const SizedBox(height: 12),
                  Text(
                    controller.detailError.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => controller.getProductDetails(productId: productId),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final ProductData? product = controller.selectedProduct.value;
        if (product == null) {
          return const Center(
            child: Text('No product found', style: TextStyle(color: Colors.white70)),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.getProductDetails(productId: productId),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              _ProductHero(product: product),
              const SizedBox(height: 18),
              _InfoCard(
                title: 'Basic Information',
                children: [
                  _TwoColumnRow(label: 'Product Name', value: product.name ?? 'N/A'),
                  _TwoColumnRow(label: 'SKU', value: product.sku ?? 'N/A'),
                  _TwoColumnRow(label: 'Slug', value: product.slug ?? 'N/A'),
                  _TwoColumnRow(label: 'Shop', value: product.shopId?.toString() ?? 'N/A'),
                  _TwoColumnRow(label: 'Category', value: product.category?.name ?? 'N/A'),
                  _TwoColumnRow(label: 'Brand', value: product.brand?.toString() ?? 'N/A'),
                  _TwoColumnRow(label: 'Unit', value: product.unit ?? 'N/A'),
                  _TwoColumnRow(label: 'Weight', value: '${product.weight ?? 0}'),
                  _TwoColumnRow(label: 'Min Qty', value: '${product.minQty ?? 0}'),
                  _TwoColumnRow(label: 'Barcode', value: product.barcode ?? 'N/A'),
                ],
              ),
              const SizedBox(height: 18),
              _InfoCard(
                title: 'Pricing & Inventory',
                children: [
                  _TwoColumnRow(label: 'Unit Price', value: _formatMoney(product.unitPrice ?? 0)),
                  _TwoColumnRow(label: 'Purchase Price', value: _formatMoney(product.purchasePrice ?? 0)),
                  _TwoColumnRow(label: 'Discount', value: '${product.discount ?? 0}'),
                  _TwoColumnRow(label: 'Current Stock', value: '${product.currentStock ?? 0}'),
                  _TwoColumnRow(label: 'Low Stock', value: '${product.lowStockQuantity ?? 0}'),
                  _TwoColumnRow(label: 'Stock Visibility', value: product.stockVisibilityState ?? 'N/A'),
                ],
              ),
              const SizedBox(height: 18),
              _InfoCard(
                title: 'Description',
                children: [
                  _HtmlBlock(text: product.description ?? ''),
                ],
              ),
              const SizedBox(height: 18),
              _InfoCard(
                title: 'Shipping',
                children: [
                  _TwoColumnRow(label: 'Shipping Type', value: product.shippingType ?? 'N/A'),
                  _TwoColumnRow(label: 'Shipping Cost', value: _formatMoney(product.shippingCost ?? 0)),
                  _TwoColumnRow(label: 'Estimated Days', value: '${product.estShippingDays ?? 0}'),
                  _TwoColumnRow(label: 'Qty Multiplied', value: product.isQuantityMultiplied == 1 ? 'Yes' : 'No'),
                ],
              ),
              const SizedBox(height: 18),
              _InfoCard(
                title: 'Status & Visibility',
                children: [
                  _TwoColumnRow(label: 'Published', value: product.isPublished ? 'Active' : 'Inactive'),
                  _TwoColumnRow(label: 'Approved', value: product.isApproved ? 'Approved' : 'Pending'),
                  _TwoColumnRow(label: 'Cash on Delivery', value: product.cashOnDelivery == 1 ? 'Available' : 'Not Available'),
                  _TwoColumnRow(label: 'Featured', value: product.featured == 1 ? 'Yes' : 'No'),
                  _TwoColumnRow(label: 'Seller Featured', value: product.sellerFeatured == 1 ? 'Yes' : 'No'),
                  _TwoColumnRow(label: 'Show Home', value: product.showHome == 1 ? 'Yes' : 'No'),
                  _TwoColumnRow(label: 'Digital', value: product.digital == 1 ? 'Yes' : 'No'),
                  _TwoColumnRow(label: 'Auction', value: product.auctionProduct == 1 ? 'Yes' : 'No'),
                ],
              ),
              const SizedBox(height: 18),
              _InfoCard(
                title: 'SEO',
                children: [
                  _TwoColumnRow(label: 'Meta Title', value: product.metaTitle ?? 'N/A'),
                  _TwoColumnRow(label: 'Meta Description', value: product.metaDescription ?? 'N/A'),
                  _TwoColumnRow(label: 'Meta Image', value: product.metaImg ?? 'N/A'),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  static String _formatMoney(double value) {
    final String fixed = value.toStringAsFixed(2);
    final List<String> parts = fixed.split('.');
    final String integerPart = parts[0];
    final String decimalPart = parts.length > 1 ? parts[1] : '00';
    final String formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '৳$formattedInteger.$decimalPart';
  }
}

class _ProductHero extends StatelessWidget {
  const _ProductHero({required this.product});

  final ProductData product;

  @override
  Widget build(BuildContext context) {
    final String imageUrl = product.imageUrl();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1.5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: imageUrl.isEmpty
                  ? const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 52, color: Color(0xFF6B7280)),
                    )
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.broken_image_outlined, size: 52, color: Color(0xFF6B7280)),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            product.name ?? 'Unnamed Product',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Badge(label: 'SKU: ${product.sku ?? 'N/A'}'),
              _Badge(label: 'ID: #${product.id ?? 0}'),
              if (product.isPublished) _Badge(label: 'Published', color: Colors.green),
              if (product.isApproved) _Badge(label: 'Approved', color: Colors.blue),
              if (product.cashOnDelivery == 1) _Badge(label: 'COD', color: Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ProductDetailsView._formatMoney(product.unitPrice ?? 0),
            style: const TextStyle(
              color: Color(0xFF34D399),
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, this.color = const Color(0xFF2E3033)});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _TwoColumnRow extends StatelessWidget {
  const _TwoColumnRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _HtmlBlock extends StatelessWidget {
  const _HtmlBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    if (text.trim().isEmpty) {
      return const Text('No description available', style: TextStyle(color: Colors.white70));
    }

    return Text(
      text
          .replaceAll(RegExp(r'<[^>]*>'), ' ')
          .replaceAll('&nbsp;', ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim(),
      style: const TextStyle(color: Colors.white70, height: 1.5),
    );
  }
}
