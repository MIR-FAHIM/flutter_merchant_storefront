import 'package:ecom_delivery_flutter/app/modules/global_widgets/main_drawer_widget.dart';
import 'package:ecom_delivery_flutter/app/modules/home/controllers/home_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/order/controller/order_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:ecom_delivery_flutter/common/Color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/root_controller.dart';

class RootView extends GetView<RootController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return WillPopScope(
        onWillPop: () async {
          if (controller.currentIndex.value != 0) {
            controller.currentIndex.value = 0;
            return false;
          }

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
                      controller.fetchPendingOrderCount();
                    },
                  ),
                  _BottomBarItem(
                    icon: 'assets/icons/home.png',
                    label: 'Orders',
                    isSelected: controller.currentIndex.value == 1,
                    badgeCount: controller.pendingOrderCount.value,
                    onTap: () {
                      controller.currentIndex.value = 1;
                      Get.lazyPut<OrderController>(() => OrderController());
                      controller.fetchPendingOrderCount();
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
  final int badgeCount;

  const _BottomBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.badgeCount = 0,
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
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Image.asset(
                icon,
                height: 16,
                width: 16,
                color: color,
              ),
              if (badgeCount > 0)
                Positioned(
                  top: -8,
                  right: -14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.backgroundColor,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withOpacity(0.5),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        badgeCount > 99 ? '99+' : badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
