import 'package:ecom_delivery_flutter/app/modules/pos/controllers/pos_cart_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/pos/views/widgets/pos_cart_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PosFloatingCartBar extends StatelessWidget {
  const PosFloatingCartBar({
    super.key,
    required this.controller,
  });

  final PosCartController controller;

  static const Color _bgColor = Color(0xFF1E2023);
  static const Color _borderColor = Color(0xFF374151);
  static const Color _accentColor = Color(0xFF34D399);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.totalItems;
      if (total <= 0) {
        return const SizedBox.shrink();
      }

      final subtotal = controller.subtotal;

      return SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Counter chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _accentColor.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.point_of_sale_rounded,
                      color: _accentColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      controller.selectedCounter.value,
                      style: const TextStyle(
                        color: _accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Items and Total
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$total ${'pos.itemsInCart'.tr}',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatMoney(subtotal),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              // Open Cart Button
              ElevatedButton.icon(
                onPressed: () {
                  PosCartBottomSheet.show(context: context, controller: controller);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.shopping_bag_outlined, size: 17),
                label: Text(
                  'pos.viewCart'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  static String _formatMoney(double value) {
    final bool hasDecimals = value % 1 != 0;
    final String fixed =
        hasDecimals ? value.toStringAsFixed(2) : value.toStringAsFixed(0);
    final List<String> parts = fixed.split('.');
    final String integerPart = parts[0];
    final String formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );

    if (hasDecimals && parts.length > 1) {
      return '৳$formattedInteger.${parts[1]}';
    }
    return '৳$formattedInteger';
  }
}
