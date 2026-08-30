import 'package:ecom_delivery_flutter/app/modules/seller_store_qr/controllers/seller_store_qr_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_store_qr/repositories/seller_store_qr_repository.dart';
import 'package:get/get.dart';

class SellerStoreQrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SellerStoreQrRepository>(
      () => SellerStoreQrRepository(),
    );
    Get.lazyPut<SellerStoreQrController>(
      () => SellerStoreQrController(
        repository: Get.find<SellerStoreQrRepository>(),
      ),
    );
  }
}
