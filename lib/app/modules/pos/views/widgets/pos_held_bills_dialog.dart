import 'package:ecom_delivery_flutter/app/models/pos/pos_cart_model.dart';
import 'package:ecom_delivery_flutter/app/modules/pos/controllers/pos_cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PosHeldBillsDialog extends StatefulWidget {
  const PosHeldBillsDialog({
    super.key,
    required this.controller,
  });

  final PosCartController controller;

  static Future<void> show(BuildContext context, PosCartController controller) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (_) => PosHeldBillsDialog(controller: controller),
    );
  }

  @override
  State<PosHeldBillsDialog> createState() => _PosHeldBillsDialogState();
}

class _PosHeldBillsDialogState extends State<PosHeldBillsDialog> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadHeldCarts();
  }

  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _itemCardColor = Color(0xFF242528);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _accentColor = Color(0xFF60A5FA);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _borderColor),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
          maxWidth: 480,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.pause_circle_outline_rounded,
                      color: _accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'pos.parkedHeldBills'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'pos.selectBillToResume'.tr,
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              const Divider(color: _borderColor, height: 1),
              const SizedBox(height: 12),

              // Content list
              Flexible(
                child: Obx(() {
                  if (widget.controller.isHeldListLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final heldList = widget.controller.heldCarts;
                  if (heldList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'pos.noParkedBills'.tr,
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'pos.billsParkedAppearHere'.tr,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: heldList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final cart = heldList[index];
                      return _HeldBillCard(
                        cart: cart,
                        controller: widget.controller,
                        onResumed: () => Navigator.of(context).pop(),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeldBillCard extends StatelessWidget {
  const _HeldBillCard({
    required this.cart,
    required this.controller,
    required this.onResumed,
  });

  final PosCartModel cart;
  final PosCartController controller;
  final VoidCallback onResumed;

  @override
  Widget build(BuildContext context) {
    final holdCode = cart.holdCode ?? 'HOLD-${cart.id ?? 0}';
    final itemsCount = cart.totalItems > 0
        ? cart.totalItems
        : cart.items.fold<int>(0, (s, i) => s + i.qty);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF242528),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Hold code pill
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: holdCode));
                  Get.snackbar(
                    'pos.copied'.tr,
                    'pos.holdCodeCopied'.tr,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 1),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        holdCode,
                        style: const TextStyle(
                          color: Color(0xFFFBBF24),
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.copy_rounded, size: 12, color: Color(0xFFFBBF24)),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Counter name
              Text(
                cart.counterName ?? 'Counter 1',
                style: const TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(),

              // Subtotal
              Text(
                '৳${cart.subtotal.toStringAsFixed(cart.subtotal % 1 == 0 ? 0 : 2)}',
                style: const TextStyle(
                  color: Color(0xFF34D399),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Customer and details
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cart.customerName != null && cart.customerName!.isNotEmpty)
                      Text(
                        '👤 ${cart.customerName} ${cart.customerPhone != null ? "(${cart.customerPhone})" : ""}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    Text(
                      '$itemsCount ${'pos.items'.tr} • ${cart.holdReason ?? 'pos.customerWaiting'.tr}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Resume button
              ElevatedButton.icon(
                onPressed: () async {
                  final ok = await controller.resumeCart(holdCode: holdCode);
                  if (ok) {
                    onResumed();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34D399),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.play_arrow_rounded, size: 16),
                label: Text(
                  'pos.resume'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
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
