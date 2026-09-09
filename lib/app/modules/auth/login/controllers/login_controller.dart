import 'package:ecom_delivery_flutter/app/models/auth/customer_model.dart';
import 'package:ecom_delivery_flutter/app/repositories/auth_repositories.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:ecom_delivery_flutter/app/services/firebase_messaging_service%20copy.dart';
import 'package:ecom_delivery_flutter/app/services/firebase_messaging_service.dart';
import 'package:ecom_delivery_flutter/app/services/location_service.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import 'package:ecom_delivery_flutter/service/shared_pref.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';

import 'package:permission_handler/permission_handler.dart';


class LoginController extends GetxController {
  final mobileNumber = ''.obs;
  final imeiNumber = ''.obs;
  final phoneName = ''.obs;
  final phoneModel = ''.obs;

  final password = ''.obs;
  final deviceToken = ''.obs;

  final hidePassword = true.obs;
  final loginTime = DateTime.now().obs;
  bool isSupported = true;
  late GlobalKey<FormState> loginFormKey;
  @override
  void onInit() {
    mobileNumber.value = Get.arguments ?? '';
    loginFormKey = GlobalKey<FormState>();
    imeiNumber.value = Get.find<LocationService>().imei.value;

    askingPhonePermission();
    super.onInit();
  }

  Future<String> askingPhonePermission() async {
    final PermissionStatus permissionStatus = await _getPhonePermission();
    return permissionStatus.name;
  }
  Future<PermissionStatus> _getPhonePermission() async {
    final PermissionStatus permission = await Permission.phone.status;

    print(
        "kaj ekhane hocche location service permissioon status  ${PermissionStatus.granted}");
    if (permission != PermissionStatus.granted &&
        permission == PermissionStatus.denied) {
      final Map<Permission, PermissionStatus> permissionStatus =
          await [Permission.phone].request();
      return permissionStatus[Permission.phone] ?? PermissionStatus.restricted;
    } else {
      final Map<Permission, PermissionStatus> permissionStatus =
      await [Permission.phone].request();
      print("device info is coming from login controller");
      getDeviceInfo();

      return permissionStatus[Permission.phone] ?? PermissionStatus.restricted;
    }
  }
  Future<void> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      final androidInfo = await deviceInfo.androidInfo;
      print('Android ID: ${androidInfo.id}');
      print('Model: ${androidInfo.model}');

      phoneName.value = androidInfo.id;    // unique per device+signing key
      phoneModel.value = androidInfo.model;
    } catch (e) {
      print('Failed to get device info: $e');
    }
  }
  // getSimNumber()async{
  //  bool isPermissionGranted = await MobileNumber.hasPhonePermission;
  //  if (isPermissionGranted) {
  //    final List<SimCard>? simCards = await MobileNumber.getSimCards;
  //    print("numbe are ${simCards!.first.number}");
  //    return simCards;
  //  } else {
  //    //Request Phone Permission
  //  }
  // }
  // void printSimCardsData() async {
  //   print("phone info is start");
  //   try {
  //
  //     final List<SimDataModel> simData = await _simData.getSimData();
  //     print("sim data info is ${simData.first.countryCode}");
  //     print("sim data info is ${simData.first.phoneNumber}");
  //   } on PlatformException catch (e) {
  //     debugPrint("error! code: ${e.code} - message: ${e.message}");
  //   }
  // }
// getDeviceToken()async{
//  await FirebaseMessaging.instance.getToken().then((e){
//    deviceToken.value = e!;
//  });
// }
  Future<void> login() async {
    await FireBaseMessagingService.setDeviceToken();
    print("Device token (IMEI): ${imeiNumber.value}");
    print("Device token (fcm): ${deviceToken.value}");

    if (!loginFormKey.currentState!.validate()) return;

    loginFormKey.currentState!.save();
    Get.find<AuthService>().setFirstLoggedOrNot();

    Ui.customLoaderDialog(); // Show loading dialog

    try {
      print("Attempting login... ${deviceToken.value}");
      final resp = await AuthRepository().userLogin(mobileNumber.value, password.value, deviceToken.value);
      print("Login response: $resp");

      if (resp['status'] == 'success') {
        try {
          LoginResponseModel model = LoginResponseModel.fromJson(resp);
          print("Login successful. Token: ${model.data!.token}");

          Get.find<AuthService>().setUser(model);
          Get.back(); // Close loader
          Get.offAllNamed(Routes.ROOT); // Navigate to home
        } catch (e) {
          Get.back(); // Close loader
          Get.showSnackbar(
            Ui.ErrorSnackBar(message: e.toString(), title: 'login.parseError'.tr),
          );
        }
      } else {
        Get.back(); // Close loader
        Get.showSnackbar(
          Ui.ErrorSnackBar(message: resp['message'] ?? 'login.failed'.tr, title: 'login.error'.tr),
        );
      }
    } catch (e) {
      Get.back(); // Close loader
      Get.showSnackbar(
          Ui.ErrorSnackBar(message: e.toString(), title: 'login.error'.tr),
      );
    }
  }




}
