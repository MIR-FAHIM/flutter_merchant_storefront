import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'product_form_card.dart';
import 'product_form_fields.dart';

class ProductGeneralInfoTab extends GetWidget<ProductController> {
  const ProductGeneralInfoTab({super.key});

  @override
  ProductController get controller => Get.isRegistered<ProductController>()
      ? Get.find<ProductController>()
      : Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: FormCard(
        title: 'ধাপ ১: সাধারণ তথ্য',
        children: [
          FormTextField(
            label: 'পণ্যের নাম',
            controller: controller.addNameController,
          ),
          Obx(() {
            if (controller.isCategoriesLoading.value) {
              return const SizedBox(
                height: 48,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.categoryError.value.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      controller.categoryError.value,
                      style: const TextStyle(color: Colors.orangeAccent),
                    ),
                  ),
                ],
                if (controller.activeCategories.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade900.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.shade600.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.amber.shade400,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'অনুগ্রহ করে প্রথমে পছন্দের ক্যাটাগরি যুক্ত করুন।',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                Get.toNamed(Routes.MARKETPLACE_CATEGORIES),
                            icon: const Icon(
                              Icons.category_outlined,
                              size: 18,
                              color: Colors.amber,
                            ),
                            label: const Text(
                              'পছন্দের ক্যাটাগরি যুক্ত করুন',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: Colors.amber.shade600
                                    .withValues(alpha: 0.6),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  FormDropdownField<String>(
                    hint: 'ক্যাটাগরি নির্বাচন করুন',
                    searchHint: 'ক্যাটাগরি অনুসন্ধান করুন...',
                    isSearchable: true,
                    value: controller.addSelectedCategoryId.value.isEmpty
                        ? null
                        : controller.addSelectedCategoryId.value,
                    items: controller.activeCategories
                        .map((e) => DropdownMenuItem<String>(
                              value: e.id.toString(),
                              child: Text(e.name),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        controller.addSelectedCategoryId.value = value ?? '',
                  ),
                if (controller.brands.isNotEmpty)
                  FormDropdownField<String>(
                    hint: 'ব্র্যান্ড নির্বাচন করুন',
                    searchHint: 'ব্র্যান্ড অনুসন্ধান করুন...',
                    isSearchable: true,
                    value: controller.addSelectedBrandId.value.isEmpty
                        ? null
                        : controller.addSelectedBrandId.value,
                    items: [
                      const DropdownMenuItem<String>(
                        value: '',
                        child: Text('কোনো ব্র্যান্ড নেই (None)'),
                      ),
                      ...controller.brands.map(
                        (brand) => DropdownMenuItem<String>(
                          value: brand.id.toString(),
                          child: Text(brand.name),
                        ),
                      ),
                    ],
                    onChanged: (value) =>
                        controller.addSelectedBrandId.value = value ?? '',
                  ),
              ],
            );
          }),
          FormTextField(
            label: 'বিক্রয় মূল্য',
            controller: controller.addPriceController,
            keyboardType: TextInputType.number,
          ),
          FormTextField(
            label: 'বর্তমান স্টক',
            controller: controller.addStockController,
            keyboardType: TextInputType.number,
          ),
          FormTextField(
            label: 'ক্রয় মূল্য',
            controller: controller.addPurchaseController,
            keyboardType: TextInputType.number,
          ),
          FormTextField(
            label: 'পরিমাপের একক (যেমন: pcs, kg)',
            controller: controller.addUnitController,
          ),
          FormTextField(
            label: 'ওজন',
            controller: controller.addWeightController,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}
