
import 'package:ecom_delivery_flutter/app/modules/home/views/profile_view.dart';
import 'package:ecom_delivery_flutter/app/modules/order/view/order_view.dart';
import 'package:ecom_delivery_flutter/app/modules/product/view/product_list_view.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_delivery_flutter/app/models/notification/popup_image_notification.dart';
import 'package:ecom_delivery_flutter/app/modules/home/views/home_view.dart';


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
    //MyAttendanceReportPage(),

    ProfileView(),

  ];

  Widget get currentPage => pages[currentIndex.value];


}
