import 'dart:io';

import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'product_form_card.dart';
import 'product_form_fields.dart';

class ProductPreviewTab extends GetWidget<ProductController> {
  const ProductPreviewTab({super.key});

  @override
  ProductController get controller => Get.isRegistered<ProductController>()
      ? Get.find<ProductController>()
      : Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: Listenable.merge([
        tabController,
        controller.addNameController,
        controller.addPriceController,
        controller.addStockController,
        controller.addPurchaseController,
        controller.addUnitController,
        controller.addWeightController,
        controller.addDiscountController,
        controller.addShortDescriptionController,
        controller.addDescriptionController,
      ]),
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image View Section (Prominently showing the selected images)
              FormCard(
                title: 'পণ্যের ছবি প্রিভিউ',
                children: [
                  Obx(() {
                    final images = controller.addSelectedImages;
                    if (images.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111213),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Colors.orange.shade800.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 40,
                              color: Colors.orange.shade300,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'কোনো ছবি নির্বাচন করা হয়নি',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'পণ্য যুক্ত করতে কমপক্ষে একটি ছবি নির্বাচন করুন',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () => tabController.animateTo(1),
                              icon: const Icon(
                                Icons.photo_library_rounded,
                                size: 16,
                                color: Color(0xFF34D399),
                              ),
                              label: const Text(
                                'ছবি যুক্ত করুন',
                                style: TextStyle(
                                  color: Color(0xFF34D399),
                                  fontSize: 12,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFF34D399),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Primary Featured Image
                        Container(
                          height: 210,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF111213),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF2E3033)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                File(images.first.path),
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.photo_library_rounded,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${images.length} টি ছবি',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF34D399),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'মূল ছবি (Featured)',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Thumbnails carousel/row if multiple images
                        if (images.length > 1) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 64,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: images.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final img = images[index];
                                final isFirst = index == 0;
                                return Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isFirst
                                          ? const Color(0xFF34D399)
                                          : const Color(0xFF2E3033),
                                      width: isFirst ? 2 : 1,
                                    ),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.file(
                                    File(img.path),
                                    fit: BoxFit.cover,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => tabController.animateTo(1),
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: Color(0xFF34D399),
                            ),
                            label: const Text(
                              'ছবি পরিবর্তন / যোগ করুন',
                              style: TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              const SizedBox(height: 14),

              // 2. Product Summary & Details Card
              Obx(() => FormCard(
                    title: 'পণ্যের তথ্য প্রিভিউ',
                    children: [
                      PreviewRow(
                        label: 'পণ্যের নাম:',
                        value: controller.addNameController.text.isNotEmpty
                            ? controller.addNameController.text
                            : '(নাম দেওয়া হয়নি)',
                      ),
                      const SizedBox(height: 8),
                      PreviewRow(
                        label: 'ক্যাটাগরি:',
                        value: controller.activeCategories
                                .firstWhereOrNull((e) =>
                                    e.id.toString() ==
                                    controller.addSelectedCategoryId.value)
                                ?.name ??
                            'N/A',
                      ),
                      if (controller.addSelectedBrandId.value.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        PreviewRow(
                          label: 'ব্র্যান্ড:',
                          value: controller.brands
                                  .firstWhereOrNull((e) =>
                                      e.id.toString() ==
                                      controller.addSelectedBrandId.value)
                                  ?.name ??
                              'N/A',
                        ),
                      ],
                      const SizedBox(height: 8),
                      PreviewRow(
                        label: 'বিক্রয় মূল্য:',
                        value:
                            '৳${controller.addPriceController.text.isNotEmpty ? controller.addPriceController.text : '0.00'}',
                        valueColor: const Color(0xFF34D399),
                        isBold: true,
                      ),
                      if (controller.addPurchaseController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        PreviewRow(
                          label: 'ক্রয় মূল্য:',
                          value: '৳${controller.addPurchaseController.text}',
                        ),
                      ],
                      const SizedBox(height: 8),
                      PreviewRow(
                        label: 'বর্তমান স্টক:',
                        value:
                            '${controller.addStockController.text.isNotEmpty ? controller.addStockController.text : '0'} ${controller.addUnitController.text}',
                      ),
                      if (controller.addWeightController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        PreviewRow(
                          label: 'ওজন:',
                          value: '${controller.addWeightController.text} kg',
                        ),
                      ],
                      if (controller.addDiscountController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        PreviewRow(
                          label: 'ডিসকাউন্ট:',
                          value:
                              '${controller.addDiscountController.text} ${controller.addSelectedDiscountType.value == 'percent' ? '%' : '৳'}',
                          valueColor: const Color(0xFFFCA5A5),
                        ),
                      ],
                      if (controller
                          .addShortDescriptionController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        PreviewRow(
                          label: 'সংক্ষিপ্ত বিবরণ:',
                          value: controller.addShortDescriptionController.text,
                        ),
                      ],
                      if (controller
                          .addDescriptionController.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        PreviewRow(
                          label: 'বিস্তারিত বিবরণ:',
                          value: controller.addDescriptionController.text,
                        ),
                      ],
                    ],
                  )),

              const SizedBox(height: 14),

              // 3. Settings & Flags Summary
              Obx(() => FormCard(
                    title: 'অন্যান্য সেটিংস',
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          PreviewBadge(
                            label: 'প্রকাশিত (Published)',
                            active: controller.addPublished.value,
                          ),
                          PreviewBadge(
                            label: 'আজকের অফার',
                            active: controller.addTodaysDeal.value,
                          ),
                          PreviewBadge(
                            label: 'ফিচার্ড পণ্য',
                            active: controller.addFeatured.value,
                          ),
                          PreviewBadge(
                            label: 'ক্যাশ অন ডেলিভারি (COD)',
                            active: controller.addCashOnDelivery.value,
                          ),
                          PreviewBadge(
                            label: 'রিফান্ডযোগ্য',
                            active: controller.addRefundable.value,
                          ),
                          PreviewBadge(
                            label: 'স্টক দৃশ্যমান',
                            active: controller.addStockVisibility.value,
                          ),
                        ],
                      ),
                    ],
                  )),
            ],
          ),
        );
      },
    );
  }
}
