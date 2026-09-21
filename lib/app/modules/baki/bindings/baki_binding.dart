import 'package:ecom_delivery_flutter/app/modules/baki/controllers/baki_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/baki/controllers/customer_ledger_controller.dart';
import 'package:get/get.dart';

class BakiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BakiController>(() => BakiController());
    Get.lazyPut<CustomerLedgerController>(() => CustomerLedgerController(), fenix: true);
  }
}
