import 'package:ecom_delivery_flutter/app/modules/seller_tips/data/seller_tips_data.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_tips/models/seller_tip.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_tips/views/seller_tips_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerTipsListView extends StatelessWidget {
  const SellerTipsListView({super.key});

  static const Color _bgColor = Color(0xFF111213);
  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _accentColor = Color(0xFF34D399);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Tips',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
        children: [
          const _TipsHeader(),
          const SizedBox(height: 14),
          ...SellerTipsData.tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _TipCard(tip: tip),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipsHeader extends StatelessWidget {
  const _TipsHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF064E3B), Color(0xFF075985)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: Colors.white, size: 32),
          SizedBox(height: 14),
          Text(
            'স্টোর চালানোর গাইড',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'প্যাকেজ কেনা, প্রোডাক্ট যোগ করা, ক্যাটাগরি অ্যাকটিভ করা, অর্ডার হ্যান্ডেল করা এবং ডেলিভারি সেটআপ করার সহজ নিয়ম।',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final SellerTip tip;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(
        () => const SellerTipsDetailView(),
        arguments: {'tipId': tip.id},
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SellerTipsListView._cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SellerTipsListView._borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 46,
              width: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: SellerTipsListView._accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                tip.icon,
                color: SellerTipsListView._accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    tip.summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        color: Color(0xFF60A5FA),
                        size: 16,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        tip.estimatedTime,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'দেখুন',
                        style: TextStyle(
                          color: SellerTipsListView._accentColor,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
