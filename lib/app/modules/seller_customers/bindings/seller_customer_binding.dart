import 'package:ecom_delivery_flutter/app/modules/seller_customers/controllers/seller_customer_controller.dart';
import 'package:get/get.dart';

class SellerCustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerCustomerController>(() => SellerCustomerController());
  }
}
