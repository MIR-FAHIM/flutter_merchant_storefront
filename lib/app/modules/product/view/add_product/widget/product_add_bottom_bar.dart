import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductAddBottomBar extends GetWidget<ProductController> {
  const ProductAddBottomBar({super.key});

  @override
  ProductController get controller => Get.isRegistered<ProductController>()
      ? Get.find<ProductController>()
      : Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    final tabController = DefaultTabController.of(context);
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        final currentStep = tabController.index;
        return Obx(() {
          return Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: const BoxDecoration(
              color: Color(0xFF111213),
              border: Border(
                top: BorderSide(color: Color(0xFF2E3033), width: 1),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (controller.addProductError.value.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.12),
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
                      if (currentStep > 0) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              tabController.animateTo(currentStep - 1);
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2E3033)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              'পেছনে',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: controller.isCreatingProduct.value
                              ? null
                              : () {
                                  if (currentStep < 3) {
                                    tabController.animateTo(currentStep + 1);
                                  } else {
                                    controller.submitProductAddForm();
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF34D399),
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: controller.isCreatingProduct.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.black,
                                  ),
                                )
                              : Text(
                                  currentStep < 3 ? 'পরবর্তী' : 'সংরক্ষণ করুন',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }
}
