import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';
import 'package:ecom_delivery_flutter/common/Color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import '../controllers/splashscreen_controller.dart';

class SplashscreenView extends GetView<SplashscreenController> {
  final _size = Get.size;
  @override
  Widget build(BuildContext context) {
    Get.find<SplashscreenController>();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Container(
        height: _size.height,
        width: _size.width,
        child: Stack(
          children: [
            Center(
              child: Image(
               
                height: 200,
                width: 200,
                image: AssetImage(

                  CompanyData.companyLogo,
                ),
              ),
            ),
            Positioned(
              bottom: 10,
              right: 0,
              left: 0,
              child: Ui.customLoaderSplash(),
            )
          ],
        ),
      ),
    );
  }
}
