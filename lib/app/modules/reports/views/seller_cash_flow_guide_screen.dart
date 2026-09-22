import 'package:ecom_delivery_flutter/app/models/reports/shop_cash_flow_report_model.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/controllers/shop_cash_flow_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/widgets/add_expense_bottom_sheet.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/widgets/adjust_cash_drawer_bottom_sheet.dart';
import 'package:ecom_delivery_flutter/app/modules/reports/views/widgets/set_opening_cash_bottom_sheet.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class SellerCashFlowGuideScreen extends StatelessWidget {
  const SellerCashFlowGuideScreen({super.key});

  ShopCashFlowController get controller {
    if (Get.isRegistered<ShopCashFlowController>()) {
      return Get.find<ShopCashFlowController>();
    }
    return Get.put(ShopCashFlowController());
  }

  static String _formatCurrency(double val) {
    return NumberFormat('#,##0.00').format(val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📖 সেলার ক্যাশ ফ্লো গাইড',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Obx(() => Text(
                  'স্টোর #${controller.currentStoreId} • লাইভ অডিট টিপস',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                )),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'রিফ্রেশ ডাটা',
            icon: const Icon(Icons.refresh_rounded, color: Colors.amberAccent),
            onPressed: () => controller.fetchReport(),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Obx(() {
        final data = controller.reportData.value;
        final kpis = data?.kpiCards ?? KpiCards();
        final totals = data?.totals ?? LedgerTotals();
        final grouped = controller.groupedLedgerRows;

        // Calculate dynamic figures from live ledger
        double openingCash = 0.0;
        for (var row in grouped['OPENING_BALANCE'] ?? <LedgerRowItem>[]) {
          openingCash += row.credit;
        }

        double cashInflow = 0.0;
        for (var row in grouped['REVENUE_INFLOW'] ?? <LedgerRowItem>[]) {
          cashInflow += row.credit;
        }

        double cashExpenses = 0.0;
        for (var row in grouped['CASH_OUTFLOW'] ?? <LedgerRowItem>[]) {
          cashExpenses += row.debit;
        }

        double drawerAdjustment = 0.0;
        for (var row in grouped['DRAWER_ADJUSTMENT'] ?? <LedgerRowItem>[]) {
          drawerAdjustment += row.netImpact;
        }

        double bakiCollected = 0.0;
        for (var row in grouped['BAKI_FLOW'] ?? <LedgerRowItem>[]) {
          bakiCollected += row.credit;
        }

        final double expectedDrawer = kpis.expectedCashInDrawer;
        final double digitalWallet = kpis.totalDigitalPayments;
        final double todayNewBaki = kpis.todayNewBaki;
        final double totalOutstandingBaki = kpis.totalStoreOutstandingBaki;

        return RefreshIndicator(
          color: const Color(0xFF10B981),
          backgroundColor: const Color(0xFF1E293B),
          onRefresh: () => controller.fetchReport(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Philosophy Hero Banner
                _buildPhilosophyHeroCard(context),
                const SizedBox(height: 16),

                // 2. Period Filter Selector
                _buildPeriodFilterRow(context),
                const SizedBox(height: 16),

                // 3. Live Dynamic Store Snapshot Card
                _buildLiveStoreSnapshotCard(
                  expectedDrawer: expectedDrawer,
                  digitalWallet: digitalWallet,
                  todayNewBaki: todayNewBaki,
                  totalOutstandingBaki: totalOutstandingBaki,
                ),
                const SizedBox(height: 20),

                // 4. Section 1: Debit vs Credit
                _buildSectionDebitCredit(
                  context: context,
                  totalCredit: totals.totalCredit,
                  totalDebit: totals.totalDebit,
                ),
                const SizedBox(height: 20),

                // 5. Section 2: 4 Pillars of Cash Flow (With Live Data)
                _buildSectionFourPillars(
                  context: context,
                  openingCash: openingCash,
                  cashInflow: cashInflow,
                  cashExpenses: cashExpenses,
                  drawerAdjustment: drawerAdjustment,
                  expectedDrawer: expectedDrawer,
                  digitalWallet: digitalWallet,
                  todayNewBaki: todayNewBaki,
                  totalOutstandingBaki: totalOutstandingBaki,
                  bakiCollected: bakiCollected,
                ),
                const SizedBox(height: 20),

                // 6. Section 3: 4 Golden Rules (With Action Shortcuts)
                _buildSectionGoldenRules(
                  context: context,
                  openingCash: openingCash,
                  cashExpenses: cashExpenses,
                  drawerAdjustment: drawerAdjustment,
                  expectedDrawer: expectedDrawer,
                ),
                const SizedBox(height: 20),

                // 7. Section 4: Special Seller Tip (Split 1,000 tk example)
                _buildSpecialSellerTipCard(context),
                const SizedBox(height: 20),

                // 8. Section 5: Written Live Audit Report & Share
                _buildWrittenReportSlip(
                  context: context,
                  data: data,
                  kpis: kpis,
                  totals: totals,
                  openingCash: openingCash,
                  cashInflow: cashInflow,
                  cashExpenses: cashExpenses,
                  drawerAdjustment: drawerAdjustment,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // --- 1. Philosophy Hero Banner ---
  Widget _buildPhilosophyHeroCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.6)),
                ),
                child: const Icon(Icons.lightbulb_rounded, color: Colors.amberAccent, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'ক্যাশ ফ্লো ও ক্যাশ বাক্সের হিসাব বোঝার সহজ উপায়',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber.withOpacity(0.3)),
            ),
            child: const Text(
              '“হিসাবের খাতায় লাভ আর ক্যাশ বাক্সের নগদ টাকা — দুটো কিন্তু এক জিনিস নয়!”',
              style: TextStyle(
                color: Color(0xFFFDE68A),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'আপনার দোকানে সারাদিনে কত টাকার পণ্য বিক্রি হলো, আর আপনার ক্যাশ বাক্সে (গাল্লায়) বাস্তবে কত টাকা হাতে আছে — এই পুরো হিসাবটা সহজ করার নামই ক্যাশ ফ্লো (Cash Flow)।',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Period Filter Selector ---
  Widget _buildPeriodFilterRow(BuildContext context) {
    final periods = [
      {'id': 'today', 'label': 'আজ (Today)'},
      {'id': 'yesterday', 'label': 'গতকাল (Yesterday)'},
      {'id': 'this_week', 'label': 'চলতি সপ্তাহ'},
      {'id': 'this_month', 'label': 'চলতি মাস'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: periods.map((p) {
          final isSelected = controller.selectedPeriod.value == p['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => controller.setPeriod(p['id']!),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF10B981) : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF34D399) : Colors.white12,
                  ),
                ),
                child: Text(
                  p['label']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- 3. Live Store Snapshot Card ---
  Widget _buildLiveStoreSnapshotCard({
    required double expectedDrawer,
    required double digitalWallet,
    required double todayNewBaki,
    required double totalOutstandingBaki,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'আপনার দোকানের বর্তমান লাইভ আর্থিক অবস্থা',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'REAL DATA',
                  style: TextStyle(
                    color: Color(0xFF34D399),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildSnapshotPill(
                  title: 'ক্যাশ বাক্সে থাকার কথা',
                  amount: expectedDrawer,
                  color: const Color(0xFF10B981),
                  icon: Icons.payments_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSnapshotPill(
                  title: 'ডিজিটাল ওয়ালেট',
                  amount: digitalWallet,
                  color: const Color(0xFF60A5FA),
                  icon: Icons.account_balance_wallet_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildSnapshotPill(
                  title: 'আজকের নতুন বাকি',
                  amount: todayNewBaki,
                  color: const Color(0xFFF87171),
                  icon: Icons.assignment_late_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSnapshotPill(
                  title: 'মোট অনাদায়ী বকেয়া',
                  amount: totalOutstandingBaki,
                  color: const Color(0xFFFBBF24),
                  icon: Icons.history_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotPill({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '৳${_formatCurrency(amount)}',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Section 1: Debit vs Credit ---
  Widget _buildSectionDebitCredit({
    required BuildContext context,
    required double totalCredit,
    required double totalDebit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            number: '১',
            title: 'ডেবিট (Debit) ও ক্রেডিট (Credit) এর সহজ অর্থ',
          ),
          const SizedBox(height: 8),
          const Text(
            'দোকানের হিসাব মেলানোর জন্য কঠিন অ্যাকাউন্টিং বোঝার দরকার নেই, শুধু এই দুটি শব্দ বুঝলেই হবে:',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 14),

          // Credit Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B).withOpacity(0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF059669)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF059669),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        '🟢 ক্রেডিট (Credit / Cash In ➕)',
                        style: TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'সহজ অর্থ: দোকানে টাকা বা পেমেন্ট আসলো।',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'উদাহরণ: কাস্টমারের নগদ বিক্রি, কাস্টমার বাকির টাকা শোধ করলে, বিকাশ/কার্ড পেমেন্ট, দ্রুত নগদ বিক্রি।',
                  style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'আপনার স্টোরে মোট ক্রেডিট (ইনকাম):',
                        style: TextStyle(color: Color(0xFFA7F3D0), fontSize: 11),
                      ),
                      Text(
                        '৳${_formatCurrency(totalCredit)}',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Debit Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF7F1D1D).withOpacity(0.35),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDC2626)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDC2626),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.remove_rounded, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        '🔴 ডেবিট (Debit / Cash Out ➖)',
                        style: TextStyle(
                          color: Color(0xFFF87171),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'সহজ অর্থ: দোকান থেকে টাকা বের হলো।',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  'উদাহরণ: চা/নাশতার খরচ, মালামাল পরিবহন খরচ, কাস্টমারকে ফেরত দেওয়া টাকা, নতুন বাকি দেওয়া।',
                  style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'আপনার স্টোরে মোট ডেবিট (খরচ/বাকি):',
                        style: TextStyle(color: Color(0xFFFECACA), fontSize: 11),
                      ),
                      Text(
                        '৳${_formatCurrency(totalDebit)}',
                        style: const TextStyle(
                          color: Color(0xFFF87171),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 5. Section 2: 4 Pillars of Cash Flow (With Live Data) ---
  Widget _buildSectionFourPillars({
    required BuildContext context,
    required double openingCash,
    required double cashInflow,
    required double cashExpenses,
    required double drawerAdjustment,
    required double expectedDrawer,
    required double digitalWallet,
    required double todayNewBaki,
    required double totalOutstandingBaki,
    required double bakiCollected,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            number: '২',
            title: 'ক্যাশ ফ্লো পেজের ৪টি প্রধান জিনিস',
          ),
          const SizedBox(height: 14),

          // Pillar 1: Cash in Drawer
          _buildPillarItem(
            icon: Icons.payments_rounded,
            iconColor: const Color(0xFF34D399),
            title: '১. 💵 ক্যাশ বাক্সের টাকা (Cash in Drawer)',
            description: 'এটি আপনার ক্যাশ বাক্সে (গাল্লায়) আসল কাগজ বা নোটের টাকা।',
            formula: 'হিসাব: (সকালের শুরুর ক্যাশ) + (আজকের নগদ ইনকাম) - (আজকের নগদ খরচ)',
            liveWidget: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF34D399).withOpacity(0.35)),
              ),
              child: Column(
                children: [
                  _buildMiniMathRow('সকালের শুরুর ক্যাশ (Opening):', '৳${_formatCurrency(openingCash)}', Colors.white70),
                  _buildMiniMathRow('নগদ ইনকাম (বিক্রি ও উদ্ধার):', '+ ৳${_formatCurrency(cashInflow)}', const Color(0xFF34D399)),
                  _buildMiniMathRow('নগদ খরচ (চা-নাশতা/অন্যান্য):', '- ৳${_formatCurrency(cashExpenses)}', const Color(0xFFF87171)),
                  if (drawerAdjustment != 0)
                    _buildMiniMathRow('ড্রয়ার সমন্বয় (সিস্টেম এডজাস্টমেন্ট):', '${drawerAdjustment > 0 ? '+' : ''} ৳${_formatCurrency(drawerAdjustment)}', const Color(0xFF60A5FA)),
                  const Divider(color: Colors.white24, height: 12),
                  _buildMiniMathRow(
                    'ক্যাশ বাক্সে থাকার কথা (Expected):',
                    '৳${_formatCurrency(expectedDrawer)}',
                    const Color(0xFF34D399),
                    isBold: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Pillar 2: Digital Wallets
          _buildPillarItem(
            icon: Icons.qr_code_scanner_rounded,
            iconColor: const Color(0xFF60A5FA),
            title: '২. 📱 ডিজিটাল টাকা (Digital Wallets)',
            description: 'বিকাশ, নগদ বা কার্ডে পাওয়া টাকা। এই টাকা আপনার ক্যাশ বাক্সে থাকে না, সরাসরি ব্যাংক বা ওয়ালেটে জমা হয়।',
            liveWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ডিজিটাল পেমেন্ট রিসিভড:',
                    style: TextStyle(color: Colors.white70, fontSize: 11.5),
                  ),
                  Text(
                    '৳${_formatCurrency(digitalWallet)}',
                    style: const TextStyle(
                      color: Color(0xFF60A5FA),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Pillar 3: New Baki Given
          _buildPillarItem(
            icon: Icons.assignment_late_outlined,
            iconColor: const Color(0xFFF87171),
            title: '৩. 🔴 আজকের নতুন বাকি (New Baki Given)',
            description: 'আজ সারাদিনে মোট কত টাকার পণ্য কাস্টমাররা বাকিতে নিয়ে গেল (যা এখনো পাননি)।',
            liveWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFF87171).withOpacity(0.35)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('আজকের নতুন বাকি:', style: TextStyle(color: Colors.white70, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(
                          '৳${_formatCurrency(todayNewBaki)}',
                          style: const TextStyle(
                            color: Color(0xFFF87171),
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Get.toNamed(Routes.BAKI_KHATA),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF87171).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF87171)),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'বাকি খাতা',
                            style: TextStyle(color: Color(0xFFF87171), fontSize: 10.5, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios_rounded, size: 9, color: Color(0xFFF87171)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Pillar 4: Baki Recovered
          _buildPillarItem(
            icon: Icons.assignment_turned_in_outlined,
            iconColor: const Color(0xFF34D399),
            title: '৪. 🟢 আজকের বাকি উদ্ধার (Baki Recovered)',
            description: 'পুরনো বাকির কাস্টমারদের কাছ থেকে আজ নগদ বা বিকাশে কত টাকা ফেরত পেলেন।',
            liveWidget: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF34D399).withOpacity(0.35)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'সংগৃহীত নগদ বাকি:',
                    style: TextStyle(color: Colors.white70, fontSize: 11.5),
                  ),
                  Text(
                    '৳${_formatCurrency(bakiCollected)}',
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPillarItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    String? formula,
    required Widget liveWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
        ),
        if (formula != null) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              formula,
              style: const TextStyle(
                color: Color(0xFFFDE68A),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        liveWidget,
      ],
    );
  }

  Widget _buildMiniMathRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.white : Colors.white70,
              fontSize: 11,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: isBold ? 12.5 : 11.5,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // --- 6. Section 3: 4 Golden Rules (With Action Shortcuts) ---
  Widget _buildSectionGoldenRules({
    required BuildContext context,
    required double openingCash,
    required double cashExpenses,
    required double drawerAdjustment,
    required double expectedDrawer,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            number: '৩',
            title: 'ক্যাশ বাক্স ১০০% সঠিক রাখার ৪টি স্বর্ণালী নিয়ম 💡',
          ),
          const SizedBox(height: 14),

          // Rule 1: Set Opening Cash
          _buildGoldenRuleCard(
            context: context,
            ruleNumber: '১',
            title: 'প্রতিদিন সকালে "Opening Cash" বসান',
            description:
                'দোকান খুলে ক্যাশ বাক্সে খুচরা/ভাঙতির জন্য কত টাকা রাখছেন (যেমন: ১,০০০ টাকা), সেটা অ্যাপের Set Opening Cash বাটনে দিয়ে দিন। তাহলে গতকালের জমানো টাকার সাথে আজকের হিসাব গুলিয়ে যাবে না।',
            statusText: 'আজকের ওপেনিং ক্যাশ: ৳${_formatCurrency(openingCash)}',
            buttonLabel: '✏️ Set Opening Cash',
            buttonColor: const Color(0xFF10B981),
            onAction: () => SetOpeningCashBottomSheet.show(context: context, controller: controller),
          ),
          const SizedBox(height: 12),

          // Rule 2: Add Expense
          _buildGoldenRuleCard(
            context: context,
            ruleNumber: '২',
            title: 'ছোটখাট খরচ সাথে সাথে অ্যাপে তুলুন',
            description:
                'দোকানের চা-নাশতা, পলিথিন কেনা, রিকশা ভাড়া বা দোকান ঝাড়ুদারের খরচ ক্যাশ বাক্স থেকে দিলে সাথে সাথে - Add Expense দিন। ছোট খরচ না তুললে দিনশেষে ক্যাশ মিলাতে পারবেন না!',
            statusText: 'রেকর্ডকৃত নগদ খরচ: ৳${_formatCurrency(cashExpenses)}',
            buttonLabel: '🧾 Add Expense',
            buttonColor: const Color(0xFFF87171),
            onAction: () => AddExpenseBottomSheet.show(context: context, controller: controller),
          ),
          const SizedBox(height: 12),

          // Rule 3: Rush Hour Drawer Adjust
          _buildGoldenRuleCard(
            context: context,
            ruleNumber: '৩',
            title: 'ব্যস্ত সময়ে (Rush Hour) ভয় পাবেন না!',
            description:
                'বিকেলে বা সন্ধ্যায় দোকানে ভিড় থাকলে সব পণ্যের কার্ট বানানো সম্ভব নাও হতে পারে। ভিড় কমার পর ক্যাশ বাক্সের টাকা গুনে অ্যাপে ⚖️ Adjust Cash Drawer বাটনে চাপ দিন। আপনার হাতের আসল টাকার সাথে সিস্টেমের হিসাব মুহূর্তে মিলে যাবে!',
            statusText: 'বর্তমান ড্রয়ার এডজাস্টমেন্ট: ৳${_formatCurrency(drawerAdjustment)}',
            buttonLabel: '⚖️ Adjust Cash Drawer',
            buttonColor: const Color(0xFF0EA5E9),
            onAction: () => AdjustCashDrawerBottomSheet.show(context: context, controller: controller),
          ),
          const SizedBox(height: 12),

          // Rule 4: Night Galla Match
          _buildGoldenRuleCard(
            context: context,
            ruleNumber: '৪',
            title: 'দোকান বন্ধের সময় "Galla Match" করুন',
            description:
                'রাত শেষে দোকান বন্ধ করার আগে অ্যাপের "Expected Cash in Drawer" এর টাকার সাথে আপনার ক্যাশ বাক্সের নোটগুলো গুনে মিলিয়ে নিন। মিলে গেলে নিশ্চিন্তে বাড়ি যান!',
            statusText: 'ক্যাশ বাক্সে নোট থাকা উচিত: ৳${_formatCurrency(expectedDrawer)}',
            buttonLabel: '✅ মিল হয়েছে কি যাচাই করুন',
            buttonColor: const Color(0xFFF59E0B),
            onAction: () {
              Get.snackbar(
                'গাল্লা মেলান (Galla Match)',
                'আপনার ক্যাশ বাক্সে ঠিক ৳${_formatCurrency(expectedDrawer)} টাকা নোট/কয়েন হিসেবে উপস্থিত আছে কি না গুনে মিলিয়ে নিন।',
                backgroundColor: const Color(0xFF1E293B),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
                icon: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF10B981)),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGoldenRuleCard({
    required BuildContext context,
    required String ruleNumber,
    required String title,
    required String description,
    required String statusText,
    required String buttonLabel,
    required Color buttonColor,
    required VoidCallback onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: buttonColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'নিয়ম $ruleNumber',
                  style: TextStyle(color: buttonColor, fontSize: 10, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  statusText,
                  style: const TextStyle(
                    color: Color(0xFFFDE68A),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: onAction,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: buttonColor.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: buttonColor.withOpacity(0.6)),
                  ),
                  child: Text(
                    buttonLabel,
                    style: TextStyle(
                      color: buttonColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
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

  // --- 7. Section 4: Special Seller Tip ---
  Widget _buildSpecialSellerTipCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF451A03), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFF59E0B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.stars_rounded, color: Colors.black, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                '💡 সেলারদের জন্য একটি বিশেষ টিপস',
                style: TextStyle(
                  color: Color(0xFFFDE68A),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '“যদি কাস্টমার ১,০০০ টাকার জিনিস কিনে ৩০০ টাকা নগদ দেয় আর ৭০০ টাকা বাকি রাখে — অ্যাপের হিসাব আপনার ক্যাশ বাক্সে যোগ করবে ৩০০ টাকা (নগদ), আর কাস্টমারের বাকি খাতায় যোগ করবে ৭০০ টাকা। ফলে আপনার নগদ ক্যাশ ও বাকির খাতা দুটোই নিখুঁত থাকবে!”',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),

          // Visual Flow Diagram
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shopping_cart_outlined, color: Colors.white70, size: 15),
                    SizedBox(width: 6),
                    Text(
                      'মোট বিক্রয় বিল: ৳১,০০০',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('├── ', style: TextStyle(color: Colors.white38, fontFamily: 'monospace')),
                    const Icon(Icons.payments_outlined, color: Color(0xFF34D399), size: 14),
                    const SizedBox(width: 4),
                    const Text(
                      '৳৩০০ নগদ',
                      style: TextStyle(color: Color(0xFF34D399), fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
                    const Expanded(
                      child: Text(
                        ' ➡️ ক্যাশ বাক্সে যুক্ত হয় (নগদ ইনকাম)',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text('└── ', style: TextStyle(color: Colors.white38, fontFamily: 'monospace')),
                    const Icon(Icons.menu_book_rounded, color: Color(0xFFF87171), size: 14),
                    const SizedBox(width: 4),
                    const Text(
                      '৳৭০০ বাকি',
                      style: TextStyle(color: Color(0xFFF87171), fontSize: 11.5, fontWeight: FontWeight.w800),
                    ),
                    const Expanded(
                      child: Text(
                        ' ➡️ বাকি খাতায় কাস্টমার ডিউ যুক্ত হয়',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 8. Section 5: Written Live Audit Report & Share ---
  Widget _buildWrittenReportSlip({
    required BuildContext context,
    required ShopCashFlowReportData? data,
    required KpiCards kpis,
    required LedgerTotals totals,
    required double openingCash,
    required double cashInflow,
    required double cashExpenses,
    required double drawerAdjustment,
  }) {
    final periodName = controller.selectedPeriod.value == 'today'
        ? 'আজকের দিন (Today)'
        : controller.selectedPeriod.value == 'yesterday'
            ? 'গতকাল (Yesterday)'
            : controller.selectedPeriod.value == 'this_week'
                ? 'চলতি সপ্তাহ (This Week)'
                : 'চলতি মাস (This Month)';

    final dateRangeStr = (data?.from != null && data?.to != null)
        ? '${data!.from} থেকে ${data.to}'
        : DateFormat('dd MMM yyyy').format(DateTime.now());

    final shareText = '''
📊 মাইজু স্টোর ক্যাশ ফ্লো অডিট রিপোর্ট
দোকান নং: #${controller.currentStoreId}
সময়কাল: $periodName ($dateRangeStr)
----------------------------------
💵 প্রারম্ভিক ক্যাশ (Opening): ৳${_formatCurrency(openingCash)}
🟢 নগদ ইনকাম (Sales & Recoveries): ৳${_formatCurrency(cashInflow)}
🔴 নগদ খরচ (Cash Outflow): ৳${_formatCurrency(cashExpenses)}
⚖️ ক্যাশ সমন্বয় (Drawer Adj.): ৳${_formatCurrency(drawerAdjustment)}
----------------------------------
➡️ ক্যাশ বাক্সে থাকার কথা (Galla Cash): ৳${_formatCurrency(kpis.expectedCashInDrawer)}
📱 ডিজিটাল ওয়ালেট ইনকাম: ৳${_formatCurrency(kpis.totalDigitalPayments)}
🔴 নতুন বাকি দেওয়া: ৳${_formatCurrency(kpis.todayNewBaki)}
🟢 মোট অনাদায়ী বকেয়া: ৳${_formatCurrency(kpis.totalStoreOutstandingBaki)}
----------------------------------
(MyZoo Merchant Cash Audit System)
''';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSectionHeader(
                  number: '৪',
                  title: 'লিখিত ক্যাশ ফ্লো অডিট স্লিপ',
                ),
              ),
              IconButton(
                tooltip: 'শেয়ার বা কপি করুন',
                icon: const Icon(Icons.share_rounded, color: Color(0xFF10B981), size: 20),
                onPressed: () {
                  Share.share(shareText, subject: 'MyZoo ক্যাশ ফ্লো রিপোর্ট');
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'নিচে আপনার দোকানের নির্বাচিত সময়ের পূর্ণাঙ্গ লিখিত অডিট হিসাব দেওয়া হলো:',
            style: TextStyle(color: Colors.white70, fontSize: 11.5),
          ),
          const SizedBox(height: 12),

          // Receipt Style Container
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.14)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'MYZOO STORE AUDIT SLIP',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'স্টোর #${controller.currentStoreId} • $periodName',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        dateRangeStr,
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white12, height: 20),
                _buildReceiptRow('সকালের ওপেনিং ক্যাশ:', '৳${_formatCurrency(openingCash)}', Colors.white70),
                _buildReceiptRow('মোট নগদ বিক্রি ও সংগ্রহ:', '+ ৳${_formatCurrency(cashInflow)}', const Color(0xFF34D399)),
                _buildReceiptRow('নগদ খরচ (Expenses):', '- ৳${_formatCurrency(cashExpenses)}', const Color(0xFFF87171)),
                if (drawerAdjustment != 0)
                  _buildReceiptRow('ড্রয়ার সমন্বয় (Adjustments):', '${drawerAdjustment > 0 ? '+' : ''} ৳${_formatCurrency(drawerAdjustment)}', const Color(0xFF60A5FA)),
                const Divider(color: Colors.white24, height: 16),
                _buildReceiptRow(
                  '💵 ক্যাশ বাক্সে মোট টাকা (Expected):',
                  '৳${_formatCurrency(kpis.expectedCashInDrawer)}',
                  const Color(0xFF34D399),
                  isBold: true,
                ),
                const SizedBox(height: 6),
                _buildReceiptRow('📱 ডিজিটাল ওয়ালেট সংগ্রহ:', '৳${_formatCurrency(kpis.totalDigitalPayments)}', const Color(0xFF60A5FA)),
                _buildReceiptRow('🔴 নতুন বাকি দেওয়া হয়েছে:', '৳${_formatCurrency(kpis.todayNewBaki)}', const Color(0xFFF87171)),
                _buildReceiptRow('🟢 মোট অনাদায়ী বকেয়া:', '৳${_formatCurrency(kpis.totalStoreOutstandingBaki)}', const Color(0xFFFBBF24)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Action buttons: Copy & Share
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: shareText));
                    Get.snackbar(
                      'কপি সম্পন্ন',
                      'অডিট রিপোর্ট টেক্সট ক্লিপবোর্ডে কপি করা হয়েছে।',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF1E293B),
                      colorText: Colors.white,
                    );
                  },
                  icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white70),
                  label: const Text(
                    'রিপোর্ট কপি করুন',
                    style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Share.share(shareText, subject: 'MyZoo ক্যাশ ফ্লো রিপোর্ট');
                  },
                  icon: const Icon(Icons.share_rounded, size: 16, color: Colors.black),
                  label: const Text(
                    'শেয়ার করুন',
                    style: TextStyle(color: Colors.black, fontSize: 11.5, fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isBold ? Colors.white : Colors.white70,
              fontSize: isBold ? 11.5 : 11,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: isBold ? 13 : 11.5,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String number,
    required String title,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
