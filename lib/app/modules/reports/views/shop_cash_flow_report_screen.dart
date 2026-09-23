import 'package:ecom_delivery_flutter/app/modules/reports/controllers/shop_cash_flow_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/widgets/shop_cash_flow_report_widget.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ShopCashFlowReportScreen extends GetView<ShopCashFlowController> {
  const ShopCashFlowReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111213),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B1C1E),
        elevation: 0,
        title: Text(
          'Cash Flow & Ledger Report'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Refresh'.tr,
            onPressed: () => controller.fetchReport(),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFF10B981),
        backgroundColor: const Color(0xFF1B1C1E),
        onRefresh: () => controller.fetchReport(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            children: [
              InkWell(
                onTap: () => Get.toNamed(Routes.CASH_FLOW_GUIDE),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amberAccent.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.amberAccent.withValues(alpha: 0.65),
                            width: 1.2,
                          ),
                        ),
                        child: const Icon(
                          Icons.lightbulb_rounded,
                          color: Colors.amberAccent,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'আপনার দোকানের ক্যাশ ফ্লো বোঝার জন্য বিস্তারিত পড়ুন',
                          style: TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 12.5,
                            height: 1.35,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.amberAccent,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const ShopCashFlowReportWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
