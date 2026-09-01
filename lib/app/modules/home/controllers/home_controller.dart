import 'package:ecom_delivery_flutter/app/models/dashboard_model.dart';
import 'package:ecom_delivery_flutter/app/models/delivery/delivery_report.dart';
import 'package:ecom_delivery_flutter/app/models/profile_model.dart';

import 'package:ecom_delivery_flutter/app/repositories/auth_repositories.dart';
import 'package:ecom_delivery_flutter/app/repositories/delivery_rep.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:ecom_delivery_flutter/app/modules/settings/controllers/language_controller.dart';

import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import 'package:ecom_delivery_flutter/main.dart';
import 'package:ecom_delivery_flutter/service/shared_pref.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final balance = '0.0'.obs;
  final phoneController = TextEditingController().obs;
  final outletNameController = TextEditingController().obs;
  final ownerController = TextEditingController().obs;
  final addressController = TextEditingController().obs;
  final status = false.obs;
  final packageName = "".obs;

  final packageLoad = false.obs;
  final hideChatBox = false.obs;

  final userID = 0.obs;
  final deliveryReport = DeliveryReportModel().obs;
  final dashboardReport = DashboardModel().obs;
  final box = GetStorage().obs;
  final contactsResult = <Contact>[].obs;
  final profileData = ProfileData().obs;

  @override
  Future<void> onInit() async {
    userID.value = Get.find<AuthService>().currentUser.value.data!.user!.id!;
    getProfile();
    reportDashboardShopController();
    super.onInit();
    print('HomeController.onInit');
  }

  Future refreshHome() async {}

  @override
  void onReady() {
    // TODO: implement onReady

    super.onReady();
  }

  getProfile() {
    AuthRepository().getSellerProfile(userID.value.toString()).then((e) {
      print("profile data is $e");
      if (e['status'] == 'success') {
        ProfileModel model = ProfileModel.fromJson(e);
        profileData.value = model.data!;
        print("profile data name is ${profileData.value.name}");
      } else if (e['message'] == "Invalid app token") {
        Get.find<AuthService>().removeCurrentUser();

        Get.toNamed(Routes.SPLASHSCREEN);
      }
    });
  }

  reportDeliveryController() {
    DeliveryRepository().reportDelivery(userID.value.toString()).then((e) {
      print("reportDelivery data is $e");

      try {
        if (e['status'] == 'success') {
          DeliveryReportModel model = DeliveryReportModel.fromJson(e);
          deliveryReport.value = model;
        }
      } catch (err) {

      } finally {

      }
    });
  }

  reportDashboardShopController() {
    DeliveryRepository().reportShopDashboard(userID.value.toString()).then((e) {
      print("reportDelivery data is $e");

      try {
        if (e['status'] == 'success') {
          DashboardModel model = DashboardModel.fromJson(e);
          dashboardReport.value = model;
        }
      } catch (err) {

      } finally {

      }
    });
  }
}
