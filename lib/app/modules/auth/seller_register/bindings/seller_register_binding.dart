import 'package:ecom_delivery_flutter/app/modules/auth/seller_register/controllers/seller_register_controller.dart';
import 'package:get/get.dart';

class SellerRegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerRegisterController>(() => SellerRegisterController());
  }
}
