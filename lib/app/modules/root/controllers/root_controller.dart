
import 'package:ecom_delivery_flutter/app/modules/home/views/profile_view.dart';
import 'package:ecom_delivery_flutter/app/modules/order/view/order_view.dart';
import 'package:ecom_delivery_flutter/app/modules/product/view/product_list_view.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_delivery_flutter/app/models/notification/popup_image_notification.dart';
import 'package:ecom_delivery_flutter/app/modules/home/views/home_view.dart';
import 'package:new_version_plus/new_version_plus.dart';


class RootController extends GetxController {
  //TODO: Implement RootController
  final currentIndex = 0.obs;
  final notificationType = ''.obs;
  final popNoti = true.obs;
  final imagePopUrl = "".obs;
  final imageUrlPop = "".obs;

  final imageNotificationPopList = <NotiDatum>[].obs;
  @override
  void onInit() {
    super.onInit();

    advancedStatusCheck();
    //

  }

  @override
  void onReady() {
    super.onReady();


  }

  @override
  void onClose() {}

  List<Widget> pages = [
    HomeView(),
    OrderListView(),
    ProductListView(),
    ProfileView(),

  ];

  Widget get currentPage => pages[currentIndex.value];
  advancedStatusCheck() async {
    print("hle broooooo");
    final newVersion = NewVersionPlus(
      androidId: 'com.myzoo.marchant',
    );
    var status = await newVersion.getVersionStatus();
    print("version status ${status!.appStoreLink}");
    if (status.canUpdate == true) {
      print("update av");
      newVersion.showUpdateDialog(
        // launchMode: LaunchMode.externalApplication,
        context: Get.context!,
        allowDismissal: false,
        versionStatus: status,
        dialogTitle: 'Update Available!',
        dialogText: 'Upgrade  ${status.localVersion} to ${status.storeVersion}',
      );
    }
  }

}
