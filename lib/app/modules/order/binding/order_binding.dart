import 'package:ecom_delivery_flutter/app/modules/order/controller/order_controller.dart';
import 'package:get/get.dart';


class OrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderController>(
          () => OrderController(),
    );
  }
}
