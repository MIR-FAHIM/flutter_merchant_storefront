import 'package:ecom_delivery_flutter/app/models/subscription_package_model.dart';
import 'package:flutter/material.dart';

class SubscriptionPackageCard extends StatelessWidget {
  const SubscriptionPackageCard({
    super.key,
    required this.package,
    required this.isCurrent,
    required this.isLoading,
    required this.onSubscribe,
  });

  final SubscriptionPackage package;
  final bool isCurrent;
  final bool isLoading;
  final VoidCallback? onSubscribe;

  @override
  Widget build(BuildContext context) {
    final isHighlighted = package.isPopular || package.isFeatured;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isHighlighted ? const Color(0xFF2DD4BF) : const Color(0xFF2E3033),
          width: isHighlighted ? 1.6 : 1,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: const Color(0xFF2DD4BF).withOpacity(0.12),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  package.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (package.isPopular)
                const _Badge(text: 'Popular', color: Color(0xFF2DD4BF))
              else if (package.isFeatured)
                const _Badge(text: 'Featured', color: Color(0xFFFBBF24)),
            ],
          ),
          if (package.shortDescription.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              package.shortDescription,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                package.priceText,
                style: const TextStyle(
                  color: Color(0xFF2DD4BF),
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '/ ${package.billingCycleText}',
                  style: const TextStyle(
                    color: Color(0xFFD1D5DB),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _LimitChip(
                icon: Icons.card_giftcard_rounded,
                label: '${package.trialDays ?? 0} trial days',
              ),
              _LimitChip(
                icon: Icons.inventory_2_outlined,
                label: _limitText(package.maxProducts, 'products'),
              ),

              _LimitChip(
                icon: Icons.groups_2_outlined,
                label: _limitText(package.maxStaff, 'staff'),
              ),


            ],
          ),
          if (package.features.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...package.features.take(6).map((feature) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF34D399),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          color: Color(0xFFE5E7EB),
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isCurrent || isLoading ? null : onSubscribe,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF078A83),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    isCurrent ? const Color(0xFF064E3B) : const Color(0xFF2E3033),
                disabledForegroundColor: Colors.white70,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              child: Text(
                isCurrent
                    ? 'Current Package'
                    : isLoading
                        ? 'Subscribing...'
                        : 'Subscribe',
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _limitText(int? value, String label) {
    if (value == null || value < 0) return 'Unlimited $label';
    return '$value $label';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _LimitChip extends StatelessWidget {
  const _LimitChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF242629),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF34373B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF2DD4BF), size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFD1D5DB),
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
