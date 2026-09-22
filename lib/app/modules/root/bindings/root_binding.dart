import 'package:ecom_delivery_flutter/app/modules/order/controller/order_controller.dart';
import 'package:get/get.dart';
import 'package:ecom_delivery_flutter/app/modules/home/controllers/home_controller.dart';

import '../controllers/root_controller.dart';

class RootBinding extends Bindings {
  @override
  void dependencies() {

    Get.lazyPut<RootController>(
      () => RootController(),
    );


    Get.lazyPut<HomeController>(
      () => HomeController(),
    );

    Get.lazyPut<OrderController>(
      () => OrderController(),
    );
  }
}
