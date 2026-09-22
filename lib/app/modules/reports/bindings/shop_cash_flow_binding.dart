import 'package:ecom_delivery_flutter/app/modules/reports/controllers/shop_cash_flow_controller.dart';
import 'package:get/get.dart';

class ShopCashFlowBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShopCashFlowController>(() => ShopCashFlowController(), fenix: true);
  }
}
