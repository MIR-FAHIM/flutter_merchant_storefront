import 'package:ecom_delivery_flutter/app/models/notification/popup_image_notification.dart';
import 'package:ecom_delivery_flutter/app/models/order/pending_order_count_model.dart';
import 'package:ecom_delivery_flutter/app/modules/home/views/home_view.dart';
import 'package:ecom_delivery_flutter/app/modules/home/views/profile_view.dart';
import 'package:ecom_delivery_flutter/app/modules/order/view/order_view.dart';
import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/product/view/product_list_view.dart';
import 'package:ecom_delivery_flutter/app/modules/root/repositories/root_repository.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:new_version_plus/new_version_plus.dart';

class RootController extends GetxController {
  final currentIndex = 0.obs;
  final notificationType = ''.obs;
  final popNoti = true.obs;
  final imagePopUrl = "".obs;
  final imageUrlPop = "".obs;

  final imageNotificationPopList = <NotiDatum>[].obs;

  // Root repository & pending orders state
  final RootRepository _rootRepository = RootRepository();
  final RxInt pendingOrderCount = 0.obs;
  final Rx<PendingOrderCountModel?> pendingOrderModel = Rx<PendingOrderCountModel?>(null);
  final RxBool isPendingCountLoading = false.obs;

  String get currentShopId {
    if (Get.isRegistered<ProductController>()) {
      final productCtrl = Get.find<ProductController>();
      if (productCtrl.selectedStoreId.value.isNotEmpty) {
        return productCtrl.selectedStoreId.value;
      }
      if (productCtrl.shopId.isNotEmpty) {
        return productCtrl.shopId;
      }
    }

    try {
      final authUserShop = Get.find<AuthService>()
          .currentUser
          .value
          .data
          ?.user
          ?.shop
          ?.id
          ?.toString();
      if (authUserShop != null && authUserShop.isNotEmpty) {
        return authUserShop;
      }

      final authUserId = Get.find<AuthService>()
          .currentUser
          .value
          .data
          ?.user
          ?.id
          ?.toString();
      if (authUserId != null && authUserId.isNotEmpty) {
        return authUserId;
      }
    } catch (_) {}

    final box = GetStorage();
    final saved = box.read('storeId') ??
        box.read('shopId') ??
        box.read('selected_store_id');
    if (saved != null && saved.toString().isNotEmpty) {
      return saved.toString();
    }

    return '17';
  }

  @override
  void onInit() {
    super.onInit();
    advancedStatusCheck();
    fetchPendingOrderCount();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  /// Fetch live pending order count from GET /api/orders/pending-count/{shopId}
  Future<void> fetchPendingOrderCount() async {
    final shopId = currentShopId;
    if (shopId.isEmpty) return;

    isPendingCountLoading.value = true;
    try {
      final response = await _rootRepository.fetchPendingOrderCount(shopId);
      final statusCode = response['status_code'];
      final body = response['body'];

      print("my pending order ** $body");

      if (statusCode == 200 && body is Map<String, dynamic>) {
        final model = PendingOrderCountModel.fromJson(body);
        pendingOrderModel.value = model;
        pendingOrderCount.value = model.data?.count ?? 0;
      }
    } catch (e) {
      debugPrint('Error fetching pending order count: $e');
    } finally {
      isPendingCountLoading.value = false;
    }
  }

  List<Widget> pages = [
    HomeView(),
    OrderListView(),
    ProductListView(),
    ProfileView(),
  ];

  Widget get currentPage => pages[currentIndex.value];

  advancedStatusCheck() async {
    final newVersion = NewVersionPlus(
      androidId: 'com.myzoo.marchant',
    );
    var status = await newVersion.getVersionStatus();
    if (status != null && status.canUpdate == true) {
      newVersion.showUpdateDialog(
        context: Get.context!,
        allowDismissal: false,
        versionStatus: status,
        dialogTitle: 'Update Available!',
        dialogText: 'Upgrade  ${status.localVersion} to ${status.storeVersion}',
      );
    }
  }
}
