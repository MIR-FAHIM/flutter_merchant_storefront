import 'package:ecom_delivery_flutter/app/modules/reports/controllers/shop_cash_flow_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(),
    );
    Get.put<ShopCashFlowController>(
      ShopCashFlowController(),
      permanent: false,
    );
  }
}
