import 'package:ecom_delivery_flutter/app/modules/seller_tips/data/seller_tips_data.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_tips/models/seller_tip.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerTipsDetailView extends StatelessWidget {
  const SellerTipsDetailView({super.key});

  static const Color _bgColor = Color(0xFF111213);
  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _accentColor = Color(0xFF34D399);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final tipId = args is Map ? args['tipId']?.toString() : null;
    final tip = SellerTipsData.byId(tipId);

    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          tip.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Back to Tips'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: _borderColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              if (_hasAction(tip)) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Get.toNamed(tip.actionRoute!),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: Text(tip.actionLabel!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
        children: [
          _DetailHero(tip: tip),
          const SizedBox(height: 14),
          ...tip.steps.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _StepCard(
                    index: entry.key + 1,
                    step: entry.value,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  bool _hasAction(SellerTip tip) {
    final route = tip.actionRoute;
    final label = tip.actionLabel;
    if (route == null || route.isEmpty || label == null || label.isEmpty) {
      return false;
    }

    return AppPages.routes.any((page) => page.name == route);
  }
}

class _DetailHero extends StatelessWidget {
  const _DetailHero({required this.tip});

  final SellerTip tip;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 56,
            width: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(tip.icon, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            tip.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tip.summary,
            style: const TextStyle(
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

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.index,
    required this.step,
  });

  final int index;
  final SellerTipStep step;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SellerTipsDetailView._cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SellerTipsDetailView._borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 34,
            width: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SellerTipsDetailView._accentColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              index.toString(),
              style: const TextStyle(
                color: SellerTipsDetailView._accentColor,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  step.description,
                  style: const TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12.8,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if ((step.note ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF60A5FA),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          step.note!,
                          style: const TextStyle(
                            color: Color(0xFFBFDBFE),
                            fontSize: 12,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
