import 'dart:io';

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
        title: const Text('পণ্য সম্পাদনা', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final bool hasProduct = controller.selectedProduct.value != null;
        if (!hasProduct) {
          return const Center(
            child: Text('পণ্য লোড করা সম্ভব হয়নি', style: TextStyle(color: Colors.white70)),
          );
        }

        final product = controller.selectedProduct.value;
        final effectiveProductId = productId > 0 ? productId : product?.id ?? 0;
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionCard(
                  title: 'সাধারণ তথ্য',
                  children: [
                    _TextField(label: 'পণ্যের নাম', controller: nameCtrl),
                    _TextField(label: 'এসকেইউ (SKU)', controller: skuCtrl),
                    _TextField(label: 'স্লাগ (Slug)', controller: slugCtrl),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'পণ্যের ছবি',
                  children: [
                    if ((product?.imageUrl() ?? '').isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product!.imageUrl(),
                          height: 130,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const _ImagePlaceholder(
                              height: 130,
                              text: 'বর্তমান ছবি লোড করা যায়নি',
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      const _ImagePlaceholder(
                        height: 110,
                        text: 'কোনো ছবি পাওয়া যায়নি',
                      ),
                      const SizedBox(height: 12),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.pickEditProductImages,
                            icon: const Icon(Icons.photo_library_rounded),
                            label: const Text('নতুন ছবি নির্বাচন করুন'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Obx(() {
                          if (controller.editSelectedImages.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return IconButton(
                            tooltip: 'নির্বাচিত ছবি বাতিল করুন',
                            onPressed: controller.clearEditProductImages,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white70,
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      if (controller.editSelectedImages.isEmpty) {
                        return const Text(
                          'শুধুমাত্র ছবি আপলোড বা পরিবর্তন করতে চাইলে ছবি নির্বাচন করুন।',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      }

                      return Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.editSelectedImages.map((image) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(image.path),
                              width: 78,
                              height: 78,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      );
                    }),
                    Obx(() {
                      if (controller.editSelectedImages.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: controller.isSaving.value
                                ? null
                                : () async {
                                    final selectedImages =
                                        controller.editSelectedImages.toList();
                                    final uploaded =
                                        await controller.uploadProductImages(
                                      productId: effectiveProductId,
                                      images: selectedImages,
                                    );

                                    if (uploaded) {
                                      Get.snackbar(
                                        'সফল',
                                        controller.saveMessage.value.isNotEmpty
                                            ? controller.saveMessage.value
                                            : 'পণ্যের ছবি সফলভাবে আপলোড হয়েছে',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    } else {
                                      Get.snackbar(
                                        'আপলোড ব্যর্থ হয়েছে',
                                        controller.saveMessage.value.isNotEmpty
                                            ? controller.saveMessage.value
                                            : 'ছবি আপলোড করা সম্ভব হয়নি।',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.redAccent,
                                      );
                                    }
                                  },
                            icon: controller.isSaving.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.cloud_upload_rounded),
                            label: const Text('নির্বাচিত ছবি আপলোড করুন'),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'বিবরণ',
                  children: [
                    _TextField(label: 'সংক্ষিপ্ত বিবরণ', controller: TextEditingController(text: controller.selectedProduct.value?.tags ?? '')),
                    _TextField(label: 'বিস্তারিত বিবরণ', controller: descriptionCtrl, maxLines: 5),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'মূল্য নির্ধারণ',
                  children: [
                    _TextField(label: 'বিক্রয় মূল্য', controller: priceCtrl, keyboardType: TextInputType.number),
                    _TextField(label: 'ক্রয় মূল্য', controller: purchaseCtrl, keyboardType: TextInputType.number),
                    _TextField(label: 'ডিসকাউন্ট', controller: discountCtrl, keyboardType: TextInputType.number),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'ইনভেন্টরি ও স্টক',
                  children: [
                    _TextField(label: 'বর্তমান স্টক', controller: stockCtrl, keyboardType: TextInputType.number),
                    _TextField(label: 'সর্বনিম্ন ক্রয়ের পরিমাণ', controller: minQtyCtrl, keyboardType: TextInputType.number),
                    _TextField(label: 'কম স্টকের সতর্কতা পরিমাণ', controller: lowStockCtrl, keyboardType: TextInputType.number),
                    _TextField(label: 'ওজন', controller: weightCtrl, keyboardType: TextInputType.number),
                  ],
                ),
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'অন্যান্য সেটিংস',
                  children: [
                    Obx(() => _SwitchRow(label: 'প্রকাশিত (Published)', value: published.value, onChanged: (v) => published.value = v)),
                    Obx(() => _SwitchRow(label: 'ফিচার্ড পণ্য (Featured)', value: featured.value, onChanged: (v) => featured.value = v)),
                    Obx(() => _SwitchRow(label: 'সেলার ফিচার্ড', value: sellerFeatured.value, onChanged: (v) => sellerFeatured.value = v)),
                    Obx(() => _SwitchRow(label: 'ক্যাশ অন ডেলিভারি (COD)', value: cod.value, onChanged: (v) => cod.value = v)),
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
                          productId: effectiveProductId,
                          fields: fields,
                        );

                        if (saved) {
                          Get.back();
                          Get.snackbar(
                            'সফল',
                            controller.saveMessage.value.isNotEmpty
                                ? controller.saveMessage.value
                                : 'পণ্য সফলভাবে আপডেট করা হয়েছে',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        } else {
                          Get.snackbar(
                            'আপডেট ব্যর্থ হয়েছে',
                            controller.saveMessage.value.isNotEmpty
                                ? controller.saveMessage.value
                                : 'পণ্য আপডেট করা সম্ভব হয়নি।',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.redAccent,
                          );
                        }
                      },
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('পরিবর্তন সংরক্ষণ করুন'),
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

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({
    required this.height,
    required this.text,
  });

  final double height;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF121417),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.image_not_supported_outlined,
            color: Color(0xFF6B7280),
            size: 34,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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
