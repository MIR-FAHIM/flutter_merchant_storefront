import 'package:ecom_delivery_flutter/app/modules/order/controller/order_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:ecom_delivery_flutter/common/Color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ecom_delivery_flutter/app/modules/global_widgets/main_drawer_widget.dart';
import 'package:ecom_delivery_flutter/app/modules/home/controllers/home_controller.dart';
import '../controllers/root_controller.dart';

class RootView extends GetView<RootController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return WillPopScope(
        onWillPop: () async {
          final value = await showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: const Text('Are you sure you want to exit?'),
                actions: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Yes'),
                  ),
                ],
              );
            },
          );
          return value == true;
        },
        child: Scaffold(
          body: controller.currentPage,
          endDrawer: MainDrawerWidget(),
          bottomNavigationBar: BottomAppBar(
            color: AppColors.backgroundColor,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.backgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryColor,
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _BottomBarItem(
                    icon: 'assets/icons/home.png',
                    label: 'Dashboard',
                    isSelected: controller.currentIndex.value == 0,
                    onTap: () {
                      controller.currentIndex.value = 0;
                      Get.lazyPut<HomeController>(() => HomeController());
                    },
                  ),
                  _BottomBarItem(
                    icon: 'assets/icons/home.png',
                    label: 'Orders',
                    isSelected: controller.currentIndex.value == 1,
                    onTap: () {
                      controller.currentIndex.value = 1;
                      Get.lazyPut<OrderController>(() => OrderController());
                    },
                  ),
                  _BottomBarItem(
                    icon: 'assets/icons/calender.png',
                    label: 'Products',
                    isSelected: controller.currentIndex.value == 2,
                    onTap: () {
                      controller.currentIndex.value = 2;
                      Get.lazyPut<ProductController>(() => ProductController());
                    },
                  ),
                  _BottomBarItem(
                    icon: 'assets/icons/avatar.png',
                    label: 'Profile',
                    isSelected: controller.currentIndex.value == 3,
                    onTap: () {
                      controller.currentIndex.value = 3;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _BottomBarItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    var activeColor = AppColors.primaryColor;
    final color = isSelected ? activeColor : Colors.white;

    return MaterialButton(
      minWidth: 30,
      onPressed: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            icon,
            height: 16,
            width: 16,
            color: color,
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
