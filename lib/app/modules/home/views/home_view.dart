import 'dart:io';

import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:ecom_delivery_flutter/common/Color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  Future<bool> _showExitDialog(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF242526),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            "Exit App",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            "Are you sure you want to exit?",
            style: TextStyle(
              color: Color(0xFFD1D5DB),
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                "No",
                style: TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: () {
                exit(0);
              },
            ),
          ],
        );
      },
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _showExitDialog(context),
      child: Obx(() {
        final dashboard = controller.dashboardReport.value.data;

        return Scaffold(
          backgroundColor: const Color(0xFF111213),
          drawer: const _ShopDashboardDrawer(),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: const Color(0xFF111213),
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              "Shop Dashboard",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 20,
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2022),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF2F3033),
                  ),
                ),
                child: IconButton(
                  onPressed: () {
                    Get.toNamed(Routes.NOTIFICATIONVIEW);
                  },
                  icon: Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          body: dashboard == null
              ? const _DashboardLoading()
              : RefreshIndicator(
            onRefresh: () async {
              await controller.reportDashboardShopController();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DashboardHeroCard(
                    ordersAmount: dashboard.ordersAmount ?? 0,
                    ordersCount: dashboard.ordersCount ?? 0,
                    productsCount: dashboard.productsCount ?? 0,
                    shopsCount: dashboard.shopsCount ?? 0,
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: "Orders",
                          value: _FormatUtil.compactNumber(
                            dashboard.ordersCount ?? 0,
                          ),
                          subtitle: "Total received orders",
                          icon: Icons.shopping_bag_outlined,
                          iconColor: const Color(0xFF34D399),
                          backgroundColor: const Color(0xFF064E3B),
                          onTap: () {
                            Get.toNamed(Routes.MY_DELIVERY);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: "Products",
                          value: _FormatUtil.compactNumber(
                            dashboard.productsCount ?? 0,
                          ),
                          subtitle: "Listed products",
                          icon: Icons.inventory_2_outlined,
                          iconColor: const Color(0xFF60A5FA),
                          backgroundColor: const Color(0xFF1E3A5F),
                          onTap: () {
                            Get.toNamed(Routes.PRODUCT_LIST);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _MetricCard(
                          title: "Shops",
                          value: _FormatUtil.compactNumber(
                            dashboard.shopsCount ?? 0,
                          ),
                          subtitle: "Active shop profile",
                          icon: Icons.storefront_outlined,
                          iconColor: const Color(0xFFA78BFA),
                          backgroundColor: const Color(0xFF312E81),
                          onTap: () {
                            Get.snackbar(
                              "Shop",
                              "Connect shop profile route here",
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MetricCard(
                          title: "Order Amount",
                          value: _FormatUtil.moneyShort(
                            dashboard.ordersAmount ?? 0,
                          ),
                          subtitle: "Total order value",
                          icon: Icons.payments_outlined,
                          iconColor: const Color(0xFFFBBF24),
                          backgroundColor: const Color(0xFF4A3413),
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  const _SectionTitle(
                    title: "Order Period Summary",
                    subtitle: "Orders grouped by business period",
                  ),

                  const SizedBox(height: 12),

                  _OrderPeriodCard(
                    today: dashboard.ordersByPeriod?.today ??
                        dashboard.todayTotalOrders ??
                        0,
                    lastWeek: dashboard.ordersByPeriod?.lastWeek ??
                        dashboard.lastWeekTotalOrders ??
                        0,
                    lastMonth: dashboard.ordersByPeriod?.lastMonth ??
                        dashboard.lastMonthTotalOrders ??
                        0,
                    year: dashboard.ordersByPeriod?.year ??
                        dashboard.yearTotalOrders ??
                        0,
                  ),

                  const SizedBox(height: 22),

                  const _SectionTitle(
                    title: "Quick Actions",
                    subtitle: "Manage shop activity faster",
                  ),

                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.05,
                    children: [
                      _QuickActionCard(
                        title: "Orders",
                        icon: Icons.receipt_long_outlined,
                        color: const Color(0xFF34D399),
                        onTap: () {
                          Get.toNamed(Routes.MY_DELIVERY);
                        },
                      ),
                      _QuickActionCard(
                        title: "Products",
                        icon: Icons.add_box_outlined,
                        color: const Color(0xFF60A5FA),
                        onTap: () {
                          Get.toNamed(Routes.PRODUCT_LIST);
                        },
                      ),
                      _QuickActionCard(
                        title: "Categories",
                        icon: Icons.category_outlined,
                        color: const Color(0xFF8B5CF6),
                        onTap: () {
                          Get.toNamed(Routes.MARKETPLACE_CATEGORIES);
                        },
                      ),
                      _QuickActionCard(
                        title: "Chat",
                        icon: Icons.forum_outlined,
                        color: const Color(0xFF2DD4BF),
                        onTap: () {
                          Get.toNamed(Routes.SHOP_CHAT_CONVERSATIONS);
                        },
                      ),
                      _QuickActionCard(
                        title: "Earnings",
                        icon: Icons.account_balance_wallet_outlined,
                        color: const Color(0xFFFBBF24),
                        onTap: () {
                          Get.snackbar(
                            "Earnings",
                            "Connect earning page route here",
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                      ),
                      _QuickActionCard(
                        title: "Packages",
                        icon: Icons.workspace_premium_outlined,
                        color: const Color(0xFFFBBF24),
                        onTap: () {
                          Get.toNamed(Routes.SELLER_PACKAGES);
                        },
                      ),
                      _QuickActionCard(
                        title: "Store QR",
                        icon: Icons.qr_code_2_rounded,
                        color: const Color(0xFF2DD4BF),
                        onTap: () {
                          Get.toNamed(Routes.SELLER_STORE_QR);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  const _SectionTitle(
                    title: "Business Snapshot",
                    subtitle: "Current shop performance at a glance",
                  ),

                  const SizedBox(height: 12),

                  _BusinessSnapshotCard(
                    shopsCount: dashboard.shopsCount ?? 0,
                    productsCount: dashboard.productsCount ?? 0,
                    ordersCount: dashboard.ordersCount ?? 0,
                    ordersAmount: dashboard.ordersAmount ?? 0,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _DashboardHeroCard extends StatelessWidget {
  const _DashboardHeroCard({
    required this.ordersAmount,
    required this.ordersCount,
    required this.productsCount,
    required this.shopsCount,
  });

  final double ordersAmount;
  final int ordersCount;
  final int productsCount;
  final int shopsCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            const Color(0xFF0F766E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.24),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  "Welcome back",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  Get.toNamed(Routes.SHOP_CHAT_CONVERSATIONS);
                },
                child: Container(
                  height: 46,
                  width: 46,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.chat, color: Colors.green,),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            "Shop Report",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "Total Order Amount",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _FormatUtil.money(ordersAmount),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _HeroMiniStat(
                  title: "Orders",
                  value: _FormatUtil.compactNumber(ordersCount),
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: (){
                    Get.toNamed(Routes.PRODUCT_LIST);
                  },
                  child: _HeroMiniStat(
                    title: "Products",
                    value: _FormatUtil.compactNumber(productsCount),
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _HeroMiniStat(
                  title: "Shops",
                  value: _FormatUtil.compactNumber(shopsCount),
                  icon: Icons.storefront_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroMiniStat extends StatelessWidget {
  const _HeroMiniStat({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1B1C1E),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF2E3033),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 23,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFF3F4F6),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderPeriodCard extends StatelessWidget {
  const _OrderPeriodCard({
    required this.today,
    required this.lastWeek,
    required this.lastMonth,
    required this.year,
  });

  final int today;
  final int lastWeek;
  final int lastMonth;
  final int year;

  @override
  Widget build(BuildContext context) {
    final int maxValue = [
      today,
      lastWeek,
      lastMonth,
      year,
    ].fold<int>(0, (previous, current) {
      return current > previous ? current : previous;
    });

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2E3033),
        ),
      ),
      child: Column(
        children: [
          _OrderPeriodRow(
            title: "Today",
            value: today,
            maxValue: maxValue,
            color: const Color(0xFF34D399),
          ),
          const SizedBox(height: 14),
          _OrderPeriodRow(
            title: "Last Week",
            value: lastWeek,
            maxValue: maxValue,
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(height: 14),
          _OrderPeriodRow(
            title: "Last Month",
            value: lastMonth,
            maxValue: maxValue,
            color: const Color(0xFFA78BFA),
          ),
          const SizedBox(height: 14),
          _OrderPeriodRow(
            title: "This Year",
            value: year,
            maxValue: maxValue,
            color: const Color(0xFFFBBF24),
          ),
        ],
      ),
    );
  }
}

class _OrderPeriodRow extends StatelessWidget {
  const _OrderPeriodRow({
    required this.title,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final String title;
  final int value;
  final int maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final double progress = maxValue == 0 ? 0 : value / maxValue;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFE5E7EB),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              value.toString(),
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFF2E3033),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _BusinessSnapshotCard extends StatelessWidget {
  const _BusinessSnapshotCard({
    required this.shopsCount,
    required this.productsCount,
    required this.ordersCount,
    required this.ordersAmount,
  });

  final int shopsCount;
  final int productsCount;
  final int ordersCount;
  final double ordersAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF2E3033),
        ),
      ),
      child: Column(
        children: [
          _SnapshotTile(
            title: "Total Shops",
            value: shopsCount.toString(),
            icon: Icons.storefront_outlined,
            color: const Color(0xFFA78BFA),
          ),
          const Divider(
            height: 1,
            color: Color(0xFF2E3033),
            indent: 16,
            endIndent: 16,
          ),
          InkWell(
            onTap: (){
              Get.toNamed(Routes.PRODUCT_LIST);
            },
            child: _SnapshotTile(
              title: "Total Products",
              value: productsCount.toString(),
              icon: Icons.inventory_2_outlined,
              color: const Color(0xFF60A5FA),
            ),
          ),
          const Divider(
            height: 1,
            color: Color(0xFF2E3033),
            indent: 16,
            endIndent: 16,
          ),
          _SnapshotTile(
            title: "Total Orders",
            value: ordersCount.toString(),
            icon: Icons.shopping_bag_outlined,
            color: const Color(0xFF34D399),
          ),
          const Divider(
            height: 1,
            color: Color(0xFF2E3033),
            indent: 16,
            endIndent: 16,
          ),
          _SnapshotTile(
            title: "Total Order Amount",
            value: _FormatUtil.money(ordersAmount),
            icon: Icons.payments_outlined,
            color: const Color(0xFFFBBF24),
          ),
        ],
      ),
    );
  }
}

class _SnapshotTile extends StatelessWidget {
  const _SnapshotTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      leading: Container(
        height: 42,
        width: 42,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(
          icon,
          color: color,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFE5E7EB),
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      trailing: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1B1C1E),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 106,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF2E3033),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShopDashboardDrawer extends StatelessWidget {
  const _ShopDashboardDrawer();

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF111213),
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    CompanyData.companyLogo,
                    height: 58,
                    width: 120,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) {
                      return const Icon(
                        Icons.storefront_rounded,
                        color: Colors.white,
                        size: 44,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Shop Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Manage orders, products, and shop report",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.dashboard_outlined,
              title: "Dashboard",
              color: AppColors.primaryColor,
              onTap: () {
                Navigator.pop(context);
              },
            ),

            _DrawerItem(
              icon: Icons.inventory_2_outlined,
              title: "Products",
              color: const Color(0xFF60A5FA),
              onTap: () {
                Get.toNamed(Routes.PRODUCT_LIST);
              },
            ),
            _DrawerItem(
              icon: Icons.forum_outlined,
              title: "Customer Chat",
              color: const Color(0xFF2DD4BF),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(Routes.SHOP_CHAT_CONVERSATIONS);
              },
            ),
            _DrawerItem(
              icon: Icons.qr_code_2_rounded,
              title: "Store QR Download",
              color: const Color(0xFF2DD4BF),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(Routes.SELLER_STORE_QR);
              },
            ),
            _DrawerItem(
              icon: Icons.workspace_premium_outlined,
              title: "Subscription Packages",
              color: const Color(0xFFFBBF24),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(Routes.SELLER_PACKAGES);
              },
            ),
            const Spacer(),
            _DrawerItem(
              icon: Icons.logout_rounded,
              title: "Log Out",
              color: Colors.redAccent,
              onTap: () {
                Get.find<AuthService>().removeCurrentUser();
                Get.offAllNamed(Routes.SPLASHSCREEN);
              },
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: color,
          size: 21,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF6B7280),
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _FormatUtil {
  static String money(double value) {
    final String fixed = value.toStringAsFixed(2);
    final List<String> parts = fixed.split('.');
    final String integerPart = parts[0];
    final String decimalPart = parts.length > 1 ? parts[1] : '00';

    final String formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (match) => ',',
    );

    return '৳$formattedInteger.$decimalPart';
  }

  static String moneyShort(double value) {
    if (value >= 10000000) {
      return '৳${(value / 10000000).toStringAsFixed(2)}Cr';
    }

    if (value >= 100000) {
      return '৳${(value / 100000).toStringAsFixed(2)}L';
    }

    if (value >= 1000) {
      return '৳${(value / 1000).toStringAsFixed(1)}K';
    }

    return money(value);
  }

  static String compactNumber(int value) {
    if (value >= 10000000) {
      return '${(value / 10000000).toStringAsFixed(2)}Cr';
    }

    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(2)}L';
    }

    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }

    return value.toString();
  }
}
