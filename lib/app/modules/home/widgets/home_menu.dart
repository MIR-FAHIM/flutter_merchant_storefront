import 'package:ecom_delivery_flutter/common/Color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';


class HomeMenu extends GetWidget<HomeController> {

  final String menuName;
  final String imagePath;
  final double fontSize;
  HomeMenu({required this.menuName, required this.fontSize, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return    Container(
      width: Get.width*.3,
      height: Get.height*.1,
      decoration: BoxDecoration(
        color: AppColors.secondbackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primaryColor, // ✅ Solid border color
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 40, width: 40,),
          Text(
            menuName,
            style: TextStyle(color: AppColors.homeTextColor1, fontSize: fontSize),
          ),
        ],
      ),
    );
  }
}
