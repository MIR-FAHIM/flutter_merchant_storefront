import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductEditView extends GetView<ProductController> {
  const ProductEditView({super.key});

  @override
  Widget build(BuildContext context) {
    final int productId = (Get.arguments is Map && Get.arguments['product_id'] != null)
        ? int.tryParse(Get.arguments['product_id'].toString()) ?? 0
        : 0;

    final TextEditingController nameCtrl = TextEditingController(
      text: controller.selectedProduct.value?.name ?? '',
    );
    final TextEditingController skuCtrl = TextEditingController(
      text: controller.selectedProduct.value?.sku ?? '',
    );
    final TextEditingController slugCtrl = TextEditingController(
      text: controller.selectedProduct.value?.slug ?? '',
    );
    final TextEditingController priceCtrl = TextEditingController(
      text: (controller.selectedProduct.value?.unitPrice ?? 0).toString(),
    );
    final TextEditingController purchaseCtrl = TextEditingController(
      text: (controller.selectedProduct.value?.purchasePrice ?? 0).toString(),
    );
    final TextEditingController discountCtrl = TextEditingController(
      text: (controller.selectedProduct.value?.discount ?? 0).toString(),
    );
    final TextEditingController stockCtrl = TextEditingController(
      text: (controller.selectedProduct.value?.currentStock ?? 0).toString(),
    );
    final TextEditingController minQtyCtrl = TextEditingController(
      text: (controller.selectedProduct.value?.minQty ?? 0).toString(),
    );
    final TextEditingController lowStockCtrl = TextEditingController(
      text: (controller.selectedProduct.value?.lowStockQuantity ?? 0).toString(),
    );
    final TextEditingController weightCtrl = TextEditingController(
      text: (controller.selectedProduct.value?.weight ?? 0).toString(),
    );
    final TextEditingController descriptionCtrl = TextEditingController(
      text: controller.selectedProduct.value?.description ?? '',
    );

    final RxBool published = (controller.selectedProduct.value?.published ?? 0) == 1 ? true.obs : false.obs;
    final RxBool featured = (controller.selectedProduct.value?.featured ?? 0) == 1 ? true.obs : false.obs;
    final RxBool sellerFeatured = (controller.selectedProduct.value?.sellerFeatured ?? 0) == 1 ? true.obs : false.obs;
    final RxBool cod = (controller.selectedProduct.value?.cashOnDelivery ?? 0) == 1 ? true.obs : false.obs;

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
        title: const Text('Edit Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final bool hasProduct = controller.selectedProduct.value != null;
        if (!hasProduct) {
          return const Center(
            child: Text('Product not loaded', style: TextStyle(color: Colors.white70)),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionCard(
                  title: 'Basic Information',
                  children: [
                    _TextField(label: 'Product name', controller: nameCtrl),
                    _TextField(label: 'SKU', controller: skuCtrl),
                    _TextField(label: 'Slug', controller: slugCtrl),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Description',
                  children: [
                    _TextField(label: 'Short description', controller: TextEditingController(text: controller.selectedProduct.value?.tags ?? '')),
                    _TextField(label: 'Full description', controller: descriptionCtrl, maxLines: 5),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Pricing',
                  children: [
                    _TextField(label: 'Unit price', controller: priceCtrl, keyboardType: TextInputType.number),
                    _TextField(label: 'Purchase price', controller: purchaseCtrl, keyboardType: TextInputType.number),
                    _TextField(label: 'Discount', controller: discountCtrl, keyboardType: TextInputType.number),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Inventory',
                  children: [
                    _TextField(label: 'Current stock', controller: stockCtrl, keyboardType: TextInputType.number),
                    _TextField(label: 'Minimum quantity', controller: minQtyCtrl, keyboardType: TextInputType.number),
                    _TextField(label: 'Low stock quantity', controller: lowStockCtrl, keyboardType: TextInputType.number),
                    _TextField(label: 'Weight', controller: weightCtrl, keyboardType: TextInputType.number),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Options',
                  children: [
                    Obx(() => _SwitchRow(label: 'Published', value: published.value, onChanged: (v) => published.value = v)),
                    Obx(() => _SwitchRow(label: 'Featured', value: featured.value, onChanged: (v) => featured.value = v)),
                    Obx(() => _SwitchRow(label: 'Seller Featured', value: sellerFeatured.value, onChanged: (v) => sellerFeatured.value = v)),
                    Obx(() => _SwitchRow(label: 'Cash on Delivery', value: cod.value, onChanged: (v) => cod.value = v)),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF1B1C1E),
                    border: Border.all(color: const Color(0xFF2E3033)),
                  ),
                  child: Obx(() {
                    return ElevatedButton(
                      onPressed: controller.isSaving.value ? null : () async {
                        final fields = <String, String>{
                          'name': nameCtrl.text.trim(),
                          'sku': skuCtrl.text.trim(),
                          'slug': slugCtrl.text.trim(),
                          'unit_price': priceCtrl.text.trim(),
                          'purchase_price': purchaseCtrl.text.trim(),
                          'discount': discountCtrl.text.trim(),
                          'current_stock': stockCtrl.text.trim(),
                          'min_qty': minQtyCtrl.text.trim(),
                          'low_stock_quantity': lowStockCtrl.text.trim(),
                          'weight': weightCtrl.text.trim(),
                          'description': descriptionCtrl.text.trim(),
                          'published': published.value ? '1' : '0',
                          'featured': featured.value ? '1' : '0',
                          'seller_featured': sellerFeatured.value ? '1' : '0',
                          'cash_on_delivery': cod.value ? '1' : '0',
                        };

                        final saved = await controller.updateProduct(
                          productId: productId,
                          fields: fields,
                        );

                        if (saved) {
                          Get.back();
                          Get.snackbar('Success', controller.saveMessage.value, snackPosition: SnackPosition.BOTTOM);
                        } else {
                          Get.snackbar('Update failed', controller.saveMessage.value, snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent);
                        }
                      },
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Save Changes'),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  const _TextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          filled: true,
          fillColor: const Color(0xFF121417),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2E3033)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2E3033)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF60A5FA)),
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.label, required this.value, required this.onChanged});

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF34D399),
          ),
        ],
      ),
    );
  }
}
