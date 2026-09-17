import 'dart:io';

import 'package:ecom_delivery_flutter/app/models/seller_store_model.dart';
import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductAddView extends GetView<ProductController> {
  const ProductAddView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.prepareProductAddForm();

    return Scaffold(
      backgroundColor: const Color(0xFF111213),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111213),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'পণ্য যোগ করুন',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: Obx(() {
        if (controller.isStoresLoading.value || controller.isBrandsLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              _StepIndicator(currentStep: controller.addCurrentStep.value),
              const SizedBox(height: 16),
              if (controller.addCurrentStep.value == 0) ...[
                _FormCard(
                  title: 'ধাপ ১: সাধারণ তথ্য',
                  children: [
                    _TextField(label: 'পণ্যের নাম', controller: controller.addNameController),
                    if (controller.isCategoriesLoading.value)
                      const SizedBox(
                        height: 48,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else ...[
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
                            color: Colors.amber.shade900.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade600.withOpacity(0.4)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded, color: Colors.amber.shade400, size: 22),
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
                                  onPressed: () => Get.toNamed(Routes.MARKETPLACE_CATEGORIES),
                                  icon: const Icon(Icons.category_outlined, size: 18, color: Colors.amber),
                                  label: const Text(
                                    'পছন্দের ক্যাটাগরি যুক্ত করুন',
                                    style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: Colors.amber.shade600.withOpacity(0.6)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        _DropdownField<String>(
                          hint: 'ক্যাটাগরি নির্বাচন করুন',
                          value: controller.addSelectedCategoryId.value.isEmpty ? null : controller.addSelectedCategoryId.value,
                          items: controller.activeCategories
                              .map((e) => DropdownMenuItem<String>(
                                    value: e.id.toString(),
                                    child: Text(e.name),
                                  ))
                              .toList(),
                          onChanged: (value) => controller.addSelectedCategoryId.value = value ?? '',
                        ),
                      if (controller.brands.isNotEmpty)
                        _DropdownField<String>(
                          hint: 'কোনো ব্র্যান্ড নেই',
                          value: controller.addSelectedBrandId.value.isEmpty ? null : controller.addSelectedBrandId.value,
                          items: [
                            const DropdownMenuItem<String>(value: '', child: Text('কোনো ব্র্যান্ড নেই')),
                            ...controller.brands.map((brand) => DropdownMenuItem<String>(
                              value: brand.id.toString(),
                              child: Text(brand.name),
                            ))
                          ],
                          onChanged: (value) => controller.addSelectedBrandId.value = value ?? '',
                        ),
                    ],
                    _TextField(label: 'বিক্রয় মূল্য', controller: controller.addPriceController, keyboardType: TextInputType.number),
                    _TextField(label: 'বর্তমান স্টক', controller: controller.addStockController, keyboardType: TextInputType.number),
                    _TextField(label: 'ক্রয় মূল্য', controller: controller.addPurchaseController, keyboardType: TextInputType.number),
                    _TextField(label: 'পরিমাপের একক (যেমন: pcs, kg)', controller: controller.addUnitController),
                    _TextField(label: 'ওজন', controller: controller.addWeightController, keyboardType: TextInputType.number),
                  ],
                ),
              ] else if (controller.addCurrentStep.value == 1) ...[
                _FormCard(
                  title: 'ধাপ ২: পণ্যের ছবি',
                  children: [
                    ElevatedButton.icon(
                      onPressed: controller.pickProductImages,
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('পণ্যের ছবি নির্বাচন করুন'),
                    ),
                    const SizedBox(height: 12),
                    if (controller.addSelectedImages.isEmpty)
                      const Text(
                        'কমপক্ষে একটি ছবি নির্বাচন করা আবশ্যক।',
                        style: TextStyle(color: Colors.orangeAccent),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: controller.addSelectedImages.map((image) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(image.path),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ] else if (controller.addCurrentStep.value == 2) ...[
                _FormCard(
                  title: 'ধাপ ৩: বিবরণ ও সেটিংস',
                  children: [
                    _TextField(label: 'সংক্ষিপ্ত বিবরণ', controller: controller.addShortDescriptionController),
                    _TextField(label: 'বিস্তারিত বিবরণ', controller: controller.addDescriptionController, maxLines: 4),
                    _TextField(label: 'ডিসকাউন্ট', controller: controller.addDiscountController, keyboardType: TextInputType.number),
                    _DropdownField<String>(
                      hint: 'ডিসকাউন্টের ধরন',
                      value: controller.addSelectedDiscountType.value,
                      items: const [
                        DropdownMenuItem(value: 'amount', child: Text('নির্দিষ্ট টাকা (টাকা)')),
                        DropdownMenuItem(value: 'percent', child: Text('শতাংশ (%)')),
                      ],
                      onChanged: (value) => controller.addSelectedDiscountType.value = value ?? 'amount',
                    ),
                    Obx(() => _SwitchRow(label: 'আজকের অফার (Today\'s Deal)', value: controller.addTodaysDeal.value, onChanged: (v) => controller.addTodaysDeal.value = v)),
                    Obx(() => _SwitchRow(label: 'প্রকাশিত (Published)', value: controller.addPublished.value, onChanged: (v) => controller.addPublished.value = v)),
                    Obx(() => _SwitchRow(label: 'ফিচার্ড পণ্য (Featured)', value: controller.addFeatured.value, onChanged: (v) => controller.addFeatured.value = v)),
                    Obx(() => _SwitchRow(label: 'ক্যাশ অন ডেলিভারি (COD)', value: controller.addCashOnDelivery.value, onChanged: (v) => controller.addCashOnDelivery.value = v)),
                    Obx(() => _SwitchRow(label: 'রিফান্ডযোগ্য (Refundable)', value: controller.addRefundable.value, onChanged: (v) => controller.addRefundable.value = v)),
                    Obx(() => _SwitchRow(label: 'স্টক প্রদর্শন (Stock Visibility)', value: controller.addStockVisibility.value, onChanged: (v) => controller.addStockVisibility.value = v)),
                  ],
                ),
              ] else ...[
                _FormCard(
                  title: 'ধাপ ৪: প্রিভিউ',
                  children: [
                    Text('নাম: ${controller.addNameController.text}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('ক্যাটাগরি: ${controller.activeCategories.firstWhereOrNull((e) => e.id.toString() == controller.addSelectedCategoryId.value)?.name ?? 'N/A'}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('বিক্রয় মূল্য: ৳${controller.addPriceController.text}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('স্টক: ${controller.addStockController.text}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('মোট ছবি: ${controller.addSelectedImages.length} টি', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ],
              const SizedBox(height: 18),
              if (controller.addProductError.value.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent),
                  ),
                  child: Text(
                    controller.addProductError.value,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              Row(
                children: [
                  if (controller.addCurrentStep.value > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: controller.previousProductAddStep,
                        child: const Text('পেছনে'),
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.isCreatingProduct.value
                          ? null
                          : controller.nextProductAddStep,
                      child: controller.isCreatingProduct.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(controller.addCurrentStep.value < 3 ? 'পরবর্তী' : 'সংরক্ষণ করুন'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final steps = ['সাধারণ তথ্য', 'ছবি', 'বিবরণ', 'প্রিভিউ'];
    return Row(
      children: List.generate(steps.length, (index) {
        final selected = currentStep == index;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF34D399) : const Color(0xFF1B1C1E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              steps[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _StoreSelectorWidget extends StatelessWidget {
  const _StoreSelectorWidget({
    required this.stores,
    required this.selectedStoreId,
    required this.onChanged,
  });

  final List<SellerStoreModel> stores;
  final String selectedStoreId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedStoreId.isEmpty ? null : selectedStoreId,
          hint: const Text('স্টোর নির্বাচন করুন', style: TextStyle(color: Colors.grey)),
          isExpanded: true,
          dropdownColor: const Color(0xFF1B1C1E),
          style: const TextStyle(color: Colors.white, fontSize: 14),
          items: stores.map((store) {
            return DropdownMenuItem<String>(
              value: store.id.toString(),
              child: Text(store.name ?? 'স্টোর #${store.id}'),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(16),
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
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
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
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF111213),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2E3033)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF34D399)),
          ),
        ),
      ),
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF111213),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF2E3033)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            hint: Text(hint, style: const TextStyle(color: Colors.grey)),
            isExpanded: true,
            dropdownColor: const Color(0xFF1B1C1E),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF34D399),
          ),
        ],
      ),
    );
  }
}
