import 'package:ecom_delivery_flutter/app/modules/seller_packages/controllers/seller_packages_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_packages/repositories/seller_packages_repository.dart';
import 'package:get/get.dart';

class SellerPackagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerPackagesRepository>(
      () => SellerPackagesRepository(),
    );
    Get.lazyPut<SellerPackagesController>(
      () => SellerPackagesController(
        repository: Get.find<SellerPackagesRepository>(),
      ),
    );
  }
}
