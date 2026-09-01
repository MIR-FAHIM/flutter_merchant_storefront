import 'dart:io';

import 'package:ecom_delivery_flutter/app/models/seller_store_model.dart';
import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

class ProductAddView extends StatefulWidget {
  const ProductAddView({super.key});

  @override
  State<ProductAddView> createState() => _ProductAddViewState();
}

class _ProductAddViewState extends State<ProductAddView> {
  final ProductController controller = Get.find<ProductController>();

  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController slugCtrl = TextEditingController();
  final TextEditingController priceCtrl = TextEditingController();
  final TextEditingController stockCtrl = TextEditingController(text: '0');
  final TextEditingController purchaseCtrl = TextEditingController(text: '0');
  final TextEditingController unitCtrl = TextEditingController(text: 'pcs');
  final TextEditingController weightCtrl = TextEditingController(text: '0');
  final TextEditingController shortDescriptionCtrl = TextEditingController();
  final TextEditingController descriptionCtrl = TextEditingController();
  final TextEditingController discountCtrl = TextEditingController(text: '0');

  final RxBool todaysDeal = false.obs;
  final RxBool published = true.obs;
  final RxBool featured = false.obs;
  final RxBool refundable = false.obs;
  final RxBool cashOnDelivery = true.obs;
  final RxBool stockVisibility = true.obs;
  final RxString selectedBrandId = ''.obs;
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedDiscountType = 'amount'.obs;
  final RxList<XFile> selectedImages = <XFile>[].obs;

  final PageController pageController = PageController();
  final RxInt currentStep = 0.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initializeProductAddFlow();
    });
    nameCtrl.addListener(() {
      if (slugCtrl.text.trim().isEmpty || slugCtrl.text.trim() == 'product') {
        slugCtrl.text = controller.generateSlug(nameCtrl.text);
        slugCtrl.selection = TextSelection.fromPosition(
          TextPosition(offset: slugCtrl.text.length),
        );
      }
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    slugCtrl.dispose();
    priceCtrl.dispose();
    stockCtrl.dispose();
    purchaseCtrl.dispose();
    unitCtrl.dispose();
    weightCtrl.dispose();
    shortDescriptionCtrl.dispose();
    descriptionCtrl.dispose();
    discountCtrl.dispose();
    pageController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> files = await picker.pickMultiImage();
    if (files.isNotEmpty) {
      selectedImages.assignAll(files);
    }
  }

  Future<void> _submitProduct() async {
    final productName = nameCtrl.text.trim();
    final slug = slugCtrl.text.trim();
    final categoryId = selectedCategoryId.value;

    if (productName.isEmpty || slug.isEmpty || categoryId.isEmpty) {
      controller.addProductError.value = 'Please fill in product name, slug and category.';
      return;
    }

    if (priceCtrl.text.trim().isEmpty || stockCtrl.text.trim().isEmpty) {
      controller.addProductError.value = 'Please enter unit price and current stock.';
      return;
    }

    final created = await controller.createSellerProduct(
      name: productName,
      slug: slug,
      categoryId: categoryId,
      unitPrice: priceCtrl.text.trim(),
      currentStock: stockCtrl.text.trim(),
      brandId: selectedBrandId.value.isNotEmpty ? selectedBrandId.value : null,
      purchasePrice: purchaseCtrl.text.trim(),
      unit: unitCtrl.text.trim(),
      weight: weightCtrl.text.trim(),
      shortDescription: shortDescriptionCtrl.text.trim(),
      description: descriptionCtrl.text.trim(),
      discount: discountCtrl.text.trim(),
      discountType: selectedDiscountType.value,
      todaysDeal: todaysDeal.value,
      published: published.value,
      featured: featured.value,
      refundable: refundable.value,
      cashOnDelivery: cashOnDelivery.value,
      stockVisibility: stockVisibility.value,
      images: selectedImages,
    );

    if (created) {
      Get.snackbar('Success', 'Product created successfully', snackPosition: SnackPosition.BOTTOM);
      Get.offNamed('/PRODUCT_LIST');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111213),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111213),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add Product',
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
              _StepIndicator(currentStep: currentStep.value),
              const SizedBox(height: 16),
              if (currentStep.value == 0) ...[
                _FormCard(
                  title: 'Step 1: Basic Info',
                  children: [
                    _TextField(label: 'Product name', controller: nameCtrl),
                    _TextField(label: 'Slug', controller: slugCtrl),
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
                      if (controller.activeCategories.isNotEmpty)
                        _DropdownField<String>(
                          hint: 'Select category',
                          value: selectedCategoryId.value.isEmpty ? null : selectedCategoryId.value,
                          items: controller.activeCategories
                              .map((e) => DropdownMenuItem<String>(
                                    value: e.id.toString(),
                                    child: Text(e.name),
                                  ))
                              .toList(),
                          onChanged: (value) => selectedCategoryId.value = value ?? '',
                        ),
                      if (controller.brands.isNotEmpty)
                        _DropdownField<String>(
                          hint: 'No brand',
                          value: selectedBrandId.value.isEmpty ? null : selectedBrandId.value,
                          items: [
                            const DropdownMenuItem<String>(value: '', child: Text('No brand')),
                            ...controller.brands.map((brand) => DropdownMenuItem<String>(
                              value: brand.id.toString(),
                              child: Text(brand.name),
                            ))
                          ],
                          onChanged: (value) => selectedBrandId.value = value ?? '',
                        ),
                    ],
                    _TextField(label: 'Unit price', controller: priceCtrl, keyboardType: TextInputType.number),
                    _TextField(label: 'Current stock', controller: stockCtrl, keyboardType: TextInputType.number),
                    _TextField(label: 'Purchase price', controller: purchaseCtrl, keyboardType: TextInputType.number),
                    _TextField(label: 'Unit', controller: unitCtrl),
                    _TextField(label: 'Weight', controller: weightCtrl, keyboardType: TextInputType.number),
                  ],
                ),
              ] else if (currentStep.value == 1) ...[
                _FormCard(
                  title: 'Step 2: Images',
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImages,
                      icon: const Icon(Icons.photo_library_rounded),
                      label: const Text('Select product images'),
                    ),
                    const SizedBox(height: 12),
                    if (selectedImages.isEmpty)
                      const Text(
                        'At least one image is required.',
                        style: TextStyle(color: Colors.orangeAccent),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: selectedImages.map((image) {
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
              ] else if (currentStep.value == 2) ...[
                _FormCard(
                  title: 'Step 3: Description & Settings',
                  children: [
                    _TextField(label: 'Short description', controller: shortDescriptionCtrl),
                    _TextField(label: 'Description', controller: descriptionCtrl, maxLines: 4),
                    _TextField(label: 'Discount', controller: discountCtrl, keyboardType: TextInputType.number),
                    _DropdownField<String>(
                      hint: 'Discount type',
                      value: selectedDiscountType.value,
                      items: const [
                        DropdownMenuItem(value: 'amount', child: Text('Amount')),
                        DropdownMenuItem(value: 'percent', child: Text('Percent')),
                      ],
                      onChanged: (value) => selectedDiscountType.value = value ?? 'amount',
                    ),
                    Obx(() => _SwitchRow(label: 'Today\'s Deal', value: todaysDeal.value, onChanged: (v) => todaysDeal.value = v)),
                    Obx(() => _SwitchRow(label: 'Published', value: published.value, onChanged: (v) => published.value = v)),
                    Obx(() => _SwitchRow(label: 'Featured', value: featured.value, onChanged: (v) => featured.value = v)),
                    Obx(() => _SwitchRow(label: 'Cash on Delivery', value: cashOnDelivery.value, onChanged: (v) => cashOnDelivery.value = v)),
                    Obx(() => _SwitchRow(label: 'Refundable', value: refundable.value, onChanged: (v) => refundable.value = v)),
                    Obx(() => _SwitchRow(label: 'Stock visibility', value: stockVisibility.value, onChanged: (v) => stockVisibility.value = v)),
                  ],
                ),
              ] else ...[
                _FormCard(
                  title: 'Step 4: Preview',
                  children: [
                    Text('Name: ${nameCtrl.text}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Slug: ${slugCtrl.text}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Category: ${controller.activeCategories.firstWhereOrNull((e) => e.id.toString() == selectedCategoryId.value)?.name ?? 'N/A'}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Price: ${priceCtrl.text}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Stock: ${stockCtrl.text}', style: const TextStyle(color: Colors.white)),
                    const SizedBox(height: 8),
                    Text('Images: ${selectedImages.length}', style: const TextStyle(color: Colors.white)),
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
                  if (currentStep.value > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => currentStep.value--,
                        child: const Text('Back'),
                      ),
                    ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentStep.value < 3) {
                          currentStep.value++;
                        } else {
                          _submitProduct();
                        }
                      },
                      child: Text(currentStep.value < 3 ? 'Next' : 'Submit'),
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
    final steps = ['Basic', 'Images', 'Details', 'Preview'];
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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedStoreId.isEmpty ? null : selectedStoreId,
          hint: const Text('Select store'),
          items: stores
              .map((store) => DropdownMenuItem<String>(
                    value: store.id?.toString() ?? '',
                    child: Text(store.name),
                  ))
              .toList(),
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
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
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

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.hint,
    required this.items,
    required this.onChanged,
    this.value,
  });

  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF121417),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(color: Color(0xFF9CA3AF))),
          value: value,
          dropdownColor: const Color(0xFF1B1C1E),
          style: const TextStyle(color: Colors.white),
          items: items,
          onChanged: onChanged,
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
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.white)),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
