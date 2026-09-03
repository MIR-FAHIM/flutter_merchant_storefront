import 'package:ecom_delivery_flutter/app/modules/auth/login/bindings/login_binding.dart';
import 'package:ecom_delivery_flutter/app/modules/auth/login/views/login_view.dart';
import 'package:ecom_delivery_flutter/app/modules/auth/seller_register/bindings/seller_register_binding.dart';
import 'package:ecom_delivery_flutter/app/modules/auth/seller_register/views/seller_register_view.dart';
import 'package:ecom_delivery_flutter/app/modules/auth/seller_register/views/seller_registration_success_view.dart';
import 'package:ecom_delivery_flutter/app/modules/home/bindings/home_binding.dart';
import 'package:ecom_delivery_flutter/app/modules/home/views/home_view.dart';
import 'package:ecom_delivery_flutter/app/modules/order/binding/order_binding.dart';
import 'package:ecom_delivery_flutter/app/modules/order/view/order_detail_view.dart';
import 'package:ecom_delivery_flutter/app/modules/order/view/order_view.dart';
import 'package:ecom_delivery_flutter/app/modules/product/binding/product_binding.dart';
import 'package:ecom_delivery_flutter/app/modules/product/view/marketplace_categories_view.dart';
import 'package:ecom_delivery_flutter/app/modules/product/view/product_add_view.dart';
import 'package:ecom_delivery_flutter/app/modules/product/view/product_details_view.dart';
import 'package:ecom_delivery_flutter/app/modules/product/view/product_edit_view.dart';
import 'package:ecom_delivery_flutter/app/modules/product/view/product_list_view.dart';
import 'package:ecom_delivery_flutter/app/modules/root/bindings/root_binding.dart';
import 'package:ecom_delivery_flutter/app/modules/root/views/root_view.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_packages/bindings/seller_packages_binding.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_packages/views/seller_packages_view.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_store_qr/bindings/seller_store_qr_binding.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_store_qr/views/seller_store_qr_view.dart';
import 'package:ecom_delivery_flutter/app/modules/shop_chat/bindings/shop_chat_binding.dart';
import 'package:ecom_delivery_flutter/app/modules/shop_chat/views/chat_thread_view.dart';
import 'package:ecom_delivery_flutter/app/modules/shop_chat/views/conversation_list_view.dart';
import 'package:ecom_delivery_flutter/app/modules/splashscreen/bindings/splashscreen_binding.dart';
import 'package:ecom_delivery_flutter/app/modules/splashscreen/views/splashscreen_view.dart';
import 'package:ecom_delivery_flutter/app/modules/webview/bindings/webview_binding.dart';
import 'package:ecom_delivery_flutter/app/modules/webview/views/webview_view.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASHSCREEN;
  // static const INITIAL = Routes.Test;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.ROOT,
      page: () => RootView(),
      binding: RootBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.SELLER_REGISTER,
      page: () => const SellerRegisterView(),
      binding: SellerRegisterBinding(),
    ),
    GetPage(
      name: _Paths.SELLER_REGISTER_SUCCESS,
      page: () => const SellerRegistrationSuccessView(),
    ),
    GetPage(
      name: _Paths.SPLASHSCREEN,
      page: () => SplashscreenView(),
      binding: SplashscreenBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_LIST,
      page: () => ProductListView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_DETAILS,
      page: () => ProductDetailsView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_EDIT,
      page: () => ProductEditView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCT_ADD,
      page: () => const ProductAddView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: _Paths.MARKETPLACE_CATEGORIES,
      page: () => const MarketplaceCategoriesView(),
      binding: ProductBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_SHOP_DETAIL,
      page: () => OrderDetailView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_SHOP_LIST,
      page: () => OrderListView(),
      binding: OrderBinding(),
    ),
    GetPage(
      name: _Paths.SELLER_STORE_QR,
      page: () => const SellerStoreQrView(),
      binding: SellerStoreQrBinding(),
    ),
    GetPage(
      name: _Paths.SELLER_PACKAGES,
      page: () => const SellerPackagesView(),
      binding: SellerPackagesBinding(),
    ),
    GetPage(
      name: _Paths.SHOP_CHAT_CONVERSATIONS,
      page: () => const ConversationListView(),
      binding: ShopChatBinding(),
    ),
    GetPage(
      name: _Paths.SHOP_CHAT_THREAD,
      page: () => const ChatThreadView(),
      binding: ShopChatBinding(),
    ),
    GetPage(
      name: _Paths.WEBVIEW,
      page: () => WebviewView(),
      binding: WebviewBinding(),
    ),
  ];
}



