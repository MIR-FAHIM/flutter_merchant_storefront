import 'package:ecom_delivery_flutter/app/modules/delivery_man/controllers/delivery_man_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/delivery_man/repositories/delivery_man_repository.dart';
import 'package:get/get.dart';

class DeliveryManBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryManRepository>(() => DeliveryManRepository());
    Get.lazyPut<DeliveryManController>(
      () => DeliveryManController(
        repository: Get.find<DeliveryManRepository>(),
      ),
    );
  }
}
