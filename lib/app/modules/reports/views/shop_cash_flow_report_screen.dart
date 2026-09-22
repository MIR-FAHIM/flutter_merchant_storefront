import 'package:ecom_delivery_flutter/app/modules/reports/controllers/shop_cash_flow_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/widgets/shop_cash_flow_report_widget.dart';
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
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: ShopCashFlowReportWidget(),
        ),
      ),
    );
  }
}
