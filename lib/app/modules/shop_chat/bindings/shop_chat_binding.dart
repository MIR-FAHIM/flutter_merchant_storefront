import 'package:ecom_delivery_flutter/app/modules/shop_chat/controllers/shop_chat_controller.dart';
import 'package:get/get.dart';

class ShopChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShopChatController>(() => ShopChatController());
  }
}
