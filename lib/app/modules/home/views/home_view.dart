import 'dart:io';

import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';
import 'package:ecom_delivery_flutter/app/models/dashboard_model.dart';
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
            title: ElevatedButton(
              onPressed: () {
              Get.toNamed(Routes.SELLER_CUSTOMER_ADD);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'কাস্টমার যুক্ত করুন',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  color: Colors.black
                ),
              ),
            ),
            actions: [
              InkWell(
                onTap:(){
                  Get.toNamed(Routes.SELLER_CUSTOMER_LIST_VIEW);
                },
                child: Container(
                  height: 46,
                  width: 46,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.supervised_user_circle, color: Colors.green),
                ),
              ),
              SizedBox(width: 10,),
              Obx(
                () => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () async {
                      await controller.refreshUnreadCount();
                      Get.toNamed(Routes.SHOP_CHAT_CONVERSATIONS);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [


                        Container(
                          height: 46,
                          width: 46,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.chat, color: Colors.green),
                        ),
                        if (controller.unreadChatCount.value > 0)
                          Positioned(
                            top: -8,
                            right: -8,
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 20),
                              height: 20,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                controller.unreadChatCount.value > 99
                                    ? '99+'
                                    : controller.unreadChatCount.value
                                        .toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),


              Container(
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
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
                    color: Colors.green,
                  ),
                ),
              ),
            ],
          ),
          body: dashboard == null
              ? const _DashboardLoading()
              : RefreshIndicator(
                  onRefresh: () async {
                    await controller.refreshUnreadCount();
                    await controller.reportDashboardShopController();
                    await controller.refreshShopOrderReport();
                    await controller.refreshShopProductLimitReport();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          return _DashboardHeroCard(
                            summary: controller.shopSummary.value,
                            isSummaryLoading:
                                controller.isShopSummaryLoading.value,
                            onPeriodChanged: controller.refreshShopSummary,
                          );
                        }),
                        const SizedBox(height: 18),
                        // Container(
                        //   padding: const EdgeInsets.all(14),
                        //   decoration: BoxDecoration(
                        //     color: Colors.white,
                        //     borderRadius: BorderRadius.circular(22),
                        //     border: Border.all(
                        //       color: const Color(0xFFE0E0E0),
                        //       width: 1.5,
                        //     ),
                        //   ),
                        //   child: Row(
                        //     children: [
                        //       Expanded(
                        //         child: _DashboardModeCard(
                        //           title: 'dashboardActions.buy'.tr,
                        //           imagePath: 'assets/images/shopping-cart.png',
                        //           onTap: () {
                        //             Get.snackbar(
                        //               'dashboardActions.buy'.tr,
                        //               'dashboardActions.buyComingSoon'.tr,
                        //               snackPosition: SnackPosition.BOTTOM,
                        //             );
                        //           },
                        //         ),
                        //       ),
                        //       const SizedBox(width: 14),
                        //       Expanded(
                        //         child: _DashboardModeCard(
                        //           title: 'dashboardActions.sell'.tr,
                        //           imagePath: 'assets/icons/shopping-bag.png',
                        //           onTap: () {
                        //             Get.toNamed(Routes.PRODUCT_ADD);
                        //           },
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        const SizedBox(height: 18),
                        Obx(
                          () => _SimpleOrderReportCard(
                            report: controller.shopOrderReport.value,
                            isLoading:
                                controller.isShopOrderReportLoading.value,
                            errorMessage: controller.shopOrderReportErrorText,
                            onTap: () => Get.toNamed(Routes.ORDER_SHOP_LIST),
                            onRetry: controller.refreshShopOrderReport,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Obx(
                          () => _SimpleProductLimitReportCard(
                            report: controller.shopProductLimitReport.value,
                            isLoading: controller
                                .isShopProductLimitReportLoading.value,
                            errorMessage:
                                controller.shopProductLimitReportErrorText,
                            onTap: () => Get.toNamed(Routes.PRODUCT_LIST),
                            onRetry: controller.refreshShopProductLimitReport,
                          ),
                        ),
                        const SizedBox(height: 18),


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

class _DashboardHeroCard extends StatefulWidget {
  const _DashboardHeroCard({
    required this.summary,
    required this.isSummaryLoading,
    required this.onPeriodChanged,
  });

  final ShopSummary? summary;
  final bool isSummaryLoading;
  final Future<void> Function({String period}) onPeriodChanged;

  @override
  State<_DashboardHeroCard> createState() => _DashboardHeroCardState();
}

class _DashboardHeroCardState extends State<_DashboardHeroCard> {
  bool _showMonthly = false;

  @override
  Widget build(BuildContext context) {
    final demoMetrics = _showMonthly
        ? const _DemoPeriodMetrics(
            sales: 486900,
            orders: 612,
            paid: 412500,
            due: 74400,
          )
        : const _DemoPeriodMetrics(
            sales: 18450,
            orders: 24,
            paid: 15200,
            due: 3250,
          );
    final selectedPeriod = _showMonthly ? 'monthly' : 'daily';
    final apiMetrics =
        widget.summary?.period == selectedPeriod ? widget.summary : null;
    final metrics = apiMetrics == null
        ? demoMetrics
        : _DemoPeriodMetrics(
            sales: apiMetrics.totalSales,
            orders: apiMetrics.orderCount,
            paid: apiMetrics.paidAmount,
            due: apiMetrics.dueAmount,
          );

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "dashboardHero.storeQrTitle".tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "dashboardHero.storeQrSubtitle".tr,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => Get.toNamed(Routes.SELLER_STORE_QR),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  height: 48,
                  width: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.qr_code_2_rounded,
                    color: AppColors.primaryColor,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "dashboardHero.salesOverview".tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.isSummaryLoading
                ? 'Loading report...'
                : _showMonthly
                    ? "dashboardHero.monthlySummary".tr
                    : "dashboardHero.dailySummary".tr,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 42,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _PeriodToggle(
                  label: 'dashboardHero.daily'.tr,
                  selected: !_showMonthly,
                  onTap: () {
                    if (_showMonthly) setState(() => _showMonthly = false);
                    widget.onPeriodChanged(period: 'daily');
                  },
                ),
                _PeriodToggle(
                  label: 'dashboardHero.monthly'.tr,
                  selected: _showMonthly,
                  onTap: () {
                    if (!_showMonthly) setState(() => _showMonthly = true);
                    widget.onPeriodChanged(period: 'monthly');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Stack(
            alignment: Alignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: GridView.count(
                  key: ValueKey(_showMonthly),
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.65,
                  children: [
                    _HeroMetricTile(
                      title: 'dashboardHero.totalSales'.tr,
                      value: _FormatUtil.moneyShort(metrics.sales),
                      icon: Icons.trending_up_rounded,
                      color: const Color(0xFFBBF7D0),
                    ),
                    _HeroMetricTile(
                      title: 'dashboardHero.orderCount'.tr,
                      value: _FormatUtil.compactNumber(metrics.orders),
                      icon: Icons.receipt_long_outlined,
                      color: const Color(0xFFBFDBFE),
                    ),
                    _HeroMetricTile(
                      title: 'dashboardHero.paidAmount'.tr,
                      value: _FormatUtil.moneyShort(metrics.paid),
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFFFDE68A),
                    ),
                    _HeroMetricTile(
                      title: 'dashboardHero.dueAmount'.tr,
                      value: _FormatUtil.moneyShort(metrics.due),
                      icon: Icons.pending_actions_rounded,
                      color: const Color(0xFFFECACA),
                    ),
                  ],
                ),
              ),
              if (widget.isSummaryLoading)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x33000000),
                    child: Center(
                      child: SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DemoPeriodMetrics {
  const _DemoPeriodMetrics({
    required this.sales,
    required this.orders,
    required this.paid,
    required this.due,
  });

  final double sales;
  final int orders;
  final double paid;
  final double due;
}

class _DashboardModeCard extends StatelessWidget {
  const _DashboardModeCard({
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  final String title;
  final String imagePath;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 118,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              height: 42,
              width: 42,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF2F3B4F),
                fontSize: 25,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SimpleOrderReportCard extends StatelessWidget {
  const _SimpleOrderReportCard({
    required this.report,
    required this.isLoading,
    required this.errorMessage,
    required this.onTap,
    required this.onRetry,
  });


  final ShopOrderSimpleReport? report;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback onTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SimpleOrderReportItem(
        label: 'orderReport.today'.tr,
        value: report?.todayTotalOrder ?? 0,
        color: const Color(0xFF34D399),
      ),
      _SimpleOrderReportItem(
        label: 'orderReport.yesterday'.tr,
        value: report?.yesterdayTotalOrder ?? 0,
        color: const Color(0xFF60A5FA),
      ),
      _SimpleOrderReportItem(
        label: 'orderReport.lastWeek'.tr,
        value: report?.lastWeekTotalOrder ?? 0,
        color: const Color(0xFFFBBF24),
      ),
      _SimpleOrderReportItem(
        label: 'orderReport.lastMonth'.tr,
        value: report?.lastMonthTotalOrder ?? 0,
        color: const Color(0xFFA78BFA),
      ),
    ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1C1E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2E3033)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  color: Color(0xFF34D399),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'orderReport.title'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 15,
                  ),
              ],
            ),
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: onRetry,
                child: Text(
                  '$errorMessage ${'orderReport.retry'.tr}',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 14),
              Row(
                children: items
                    .map(
                      (item) => Expanded(
                        child: _OrderReportMetric(item: item),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SimpleOrderReportItem {
  const _SimpleOrderReportItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;
}

class _OrderReportMetric extends StatelessWidget {
  const _OrderReportMetric({required this.item});

  final _SimpleOrderReportItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _FormatUtil.compactNumber(item.value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: item.color,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SimpleProductLimitReportCard extends StatelessWidget {
  const _SimpleProductLimitReportCard({
    required this.report,
    required this.isLoading,
    required this.errorMessage,
    required this.onTap,
    required this.onRetry,
  });

  final ShopProductLimitReport? report;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback onTap;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final items = [
      _SimpleOrderReportItem(
        label: 'productLimitReport.limit'.tr,
        value: report?.productLimit ?? 0,
        color: const Color(0xFF60A5FA),
      ),
      _SimpleOrderReportItem(
        label: 'productLimitReport.added'.tr,
        value: report?.totalProductAdded ?? 0,
        color: const Color(0xFF34D399),
      ),

    ];
    final canAddMore = report?.canAddMoreProduct ?? false;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1C1E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2E3033)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFF60A5FA),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'productLimitReport.title'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                if (isLoading)
                  const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF9CA3AF),
                    size: 15,
                  ),
              ],
            ),
            if (errorMessage.isNotEmpty) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: onRetry,
                child: Text(
                  '$errorMessage ${'orderReport.retry'.tr}',
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 14),
              Row(
                children: items
                    .map(
                      (item) => Expanded(
                        child: _OrderReportMetric(item: item),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: canAddMore
                      ? const Color(0xFF064E3B)
                      : const Color(0xFF4A1D1D),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  canAddMore
                      ? 'productLimitReport.canAdd'.tr
                      : 'productLimitReport.limitFull'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: selected ? const Color(0xFF115E59) : Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _HeroMetricTile extends StatelessWidget {
  const _HeroMetricTile({
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
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
            onTap: () {
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
                  Text(
                    "shopDashboardDrawer.title".tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "shopDashboardDrawer.description".tr,
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
              title: "shopDashboardDrawer.dashboard".tr,
              color: AppColors.primaryColor,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            _DrawerItem(
              icon: Icons.inventory_2_outlined,
              title: "shopDashboardDrawer.products".tr,
              color: const Color(0xFF60A5FA),
              onTap: () {
                Get.toNamed(Routes.PRODUCT_LIST);
              },
            ),
            _DrawerItem(
              icon: Icons.forum_outlined,
              title: "shopDashboardDrawer.customerChat".tr,
              color: const Color(0xFF2DD4BF),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(Routes.SHOP_CHAT_CONVERSATIONS);
              },
            ),
            _DrawerItem(
              icon: Icons.qr_code_2_rounded,
              title: "shopDashboardDrawer.storeQrDownload".tr,
              color: const Color(0xFF2DD4BF),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(Routes.SELLER_STORE_QR);
              },
            ),
            _DrawerItem(
              icon: Icons.workspace_premium_outlined,
              title: "shopDashboardDrawer.subscriptionPackages".tr,
              color: const Color(0xFFFBBF24),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed(Routes.SELLER_PACKAGES);
              },
            ),
            const Spacer(),
            _DrawerItem(
              icon: Icons.logout_rounded,
              title: "shopDashboardDrawer.logOut".tr,
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
