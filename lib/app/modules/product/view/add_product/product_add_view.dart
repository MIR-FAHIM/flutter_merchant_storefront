import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'widget/product_add_bottom_bar.dart';
import 'widget/product_details_tab.dart';
import 'widget/product_general_info_tab.dart';
import 'widget/product_images_tab.dart';
import 'widget/product_preview_tab.dart';

class ProductAddView extends GetWidget<ProductController> {
  const ProductAddView({super.key});

  static const List<String> steps = ['সাধারণ তথ্য', 'ছবি', 'বিবরণ', 'প্রিভিউ'];

  @override
  ProductController get controller => Get.isRegistered<ProductController>()
      ? Get.find<ProductController>()
      : Get.put(ProductController());

  @override
  Widget build(BuildContext context) {
    controller.prepareProductAddForm();

    return DefaultTabController(
      length: steps.length,
      initialIndex: controller.addCurrentStep.value.clamp(0, steps.length - 1),
      child: Scaffold(
        backgroundColor: const Color(0xFF111213),
        appBar: AppBar(
          backgroundColor: const Color(0xFF111213),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            'পণ্য যোগ করুন',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1C1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2E3033)),
              ),
              child: TabBar(
                indicator: BoxDecoration(
                  color: const Color(0xFF34D399),
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.black,
                unselectedLabelColor: Colors.white70,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
                labelPadding: EdgeInsets.zero,
                tabs: steps.map((s) => Tab(text: s)).toList(),
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isStoresLoading.value ||
              controller.isBrandsLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return const TabBarView(
            children: [
              ProductGeneralInfoTab(),
              ProductImagesTab(),
              ProductDetailsTab(),
              ProductPreviewTab(),
            ],
          );
        }),
        bottomNavigationBar: const ProductAddBottomBar(),
      ),
    );
  }
}
