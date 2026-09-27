import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'product_form_card.dart';
import 'product_form_fields.dart';

class ProductDetailsTab extends GetWidget<ProductController> {
  const ProductDetailsTab({super.key});

  @override
  ProductController get controller => Get.isRegistered<ProductController>()
      ? Get.find<ProductController>()
      : Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: FormCard(
        title: 'ধাপ ৩: বিবরণ ও সেটিংস',
        children: [
          // ঐচ্ছিক ধাপ সম্পর্কিত নোট
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F2E28),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF34D399).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF34D399),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'এই ধাপটি ঐচ্ছিক (Optional)',
                            style: TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF34D399)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ঐচ্ছিক',
                              style: TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'আপনি যদি ডিসকাউন্ট, পণ্যের বিবরণ বা বিশেষ সেটিংস যুক্ত করতে চান তবে এখান থেকে নির্ধারণ করতে পারবেন। এখন কিছু সেট না করলেও কোনো সমস্যা নেই, পরবর্তীতে \'প্রোডাক্ট আপডেট\' (Update Product) অপশন থেকে যেকোনো সময় এগুলো পরিবর্তন বা সেট করে নিতে পারবেন।',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          FormTextField(
            label: 'সংক্ষিপ্ত বিবরণ',
            controller: controller.addShortDescriptionController,
          ),
          FormTextField(
            label: 'বিস্তারিত বিবরণ',
            controller: controller.addDescriptionController,
            maxLines: 4,
          ),
          FormTextField(
            label: 'ডিসকাউন্ট',
            controller: controller.addDiscountController,
            keyboardType: TextInputType.number,
          ),
          Obx(() => FormDropdownField<String>(
                hint: 'ডিসকাউন্টের ধরন',
                value: controller.addSelectedDiscountType.value,
                items: const [
                  DropdownMenuItem(
                    value: 'amount',
                    child: Text('নির্দিষ্ট টাকা (টাকা)'),
                  ),
                  DropdownMenuItem(value: 'percent', child: Text('শতাংশ (%)')),
                ],
                onChanged: (value) => controller.addSelectedDiscountType.value =
                    value ?? 'amount',
              )),
          Obx(() => FormSwitchRow(
                label: 'আজকের অফার (Today\'s Deal)',
                value: controller.addTodaysDeal.value,
                onChanged: (v) => controller.addTodaysDeal.value = v,
              )),
          Obx(() => FormSwitchRow(
                label: 'প্রকাশিত (Published)',
                value: controller.addPublished.value,
                onChanged: (v) => controller.addPublished.value = v,
              )),
          Obx(() => FormSwitchRow(
                label: 'ফিচার্ড পণ্য (Featured)',
                value: controller.addFeatured.value,
                onChanged: (v) => controller.addFeatured.value = v,
              )),
          Obx(() => FormSwitchRow(
                label: 'ক্যাশ অন ডেলিভারি (COD)',
                value: controller.addCashOnDelivery.value,
                onChanged: (v) => controller.addCashOnDelivery.value = v,
              )),
          Obx(() => FormSwitchRow(
                label: 'রিফান্ডযোগ্য (Refundable)',
                value: controller.addRefundable.value,
                onChanged: (v) => controller.addRefundable.value = v,
              )),
          Obx(() => FormSwitchRow(
                label: 'স্টক প্রদর্শন (Stock Visibility)',
                value: controller.addStockVisibility.value,
                onChanged: (v) => controller.addStockVisibility.value = v,
              )),
        ],
      ),
    );
  }
}
