import 'package:ecom_delivery_flutter/app/models/pos/pos_cart_model.dart';
import 'package:ecom_delivery_flutter/app/modules/pos/controllers/pos_cart_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/pos/views/widgets/pos_checkout_modal.dart';
import 'package:ecom_delivery_flutter/app/modules/pos/views/widgets/pos_held_bills_dialog.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PosCartBottomSheet extends StatelessWidget {
  const PosCartBottomSheet({
    super.key,
    required this.controller,
  });

  final PosCartController controller;

  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _itemBg = Color(0xFF242528);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _accentColor = Color(0xFF34D399);

  static Future<void> show({
    required BuildContext context,
    required PosCartController controller,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardColor,
      barrierColor: Colors.black.withOpacity(0.65),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PosCartBottomSheet(controller: controller),
    );
  }

  void _showCounterSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        final textController = TextEditingController();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4B5563),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'pos.selectCounter'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: controller.defaultCounters.map((counter) {
                    final isSelected = controller.selectedCounter.value == counter;
                    return ChoiceChip(
                      label: Text(counter),
                      selected: isSelected,
                      selectedColor: _accentColor,
                      backgroundColor: _itemBg,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          controller.switchCounter(counter);
                          Navigator.of(sheetCtx).pop();
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                // Custom Counter Name Input
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'pos.customCounterHint'.tr,
                          hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                          filled: true,
                          fillColor: _itemBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _borderColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (textController.text.trim().isNotEmpty) {
                          controller.switchCounter(textController.text.trim());
                          Navigator.of(sheetCtx).pop();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Text('pos.set'.tr, style: const TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHoldCartDialog(BuildContext context) {
    final reasonController = TextEditingController();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (dlgCtx) {
        return Dialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: _borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pause_circle_filled_rounded, color: Color(0xFFFBBF24), size: 24),
                    const SizedBox(width: 10),
                    Text(
                      'pos.holdParkBill'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'pos.holdParkBillDesc'.tr,
                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: reasonController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'pos.holdReasonHint'.tr,
                    hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    filled: true,
                    fillColor: _itemBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'pos.customerNameOptional'.tr,
                    hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    filled: true,
                    fillColor: _itemBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'pos.customerPhoneOptional'.tr,
                    hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    filled: true,
                    fillColor: _itemBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dlgCtx).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF9CA3AF),
                          side: const BorderSide(color: _borderColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('pos.cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.of(dlgCtx).pop();
                          final response = await controller.holdCart(
                            reason: reasonController.text,
                            customerName: nameController.text,
                            customerPhone: phoneController.text,
                          );
                          if (response != null) {
                            _showHoldCodeSuccessDialog(context, response.holdCode ?? 'HOLD-SUCCESS');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFBBF24),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('pos.holdBill'.tr, style: const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showHoldCodeSuccessDialog(BuildContext context, String holdCode) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: _borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.pause_circle_filled_rounded,
                    color: Color(0xFFFBBF24),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'pos.billParkedHeld'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'pos.counterResetDesc'.tr,
                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _itemBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFBBF24).withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          holdCode,
                          style: const TextStyle(
                            color: Color(0xFFFBBF24),
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.copy_rounded, color: Color(0xFFFBBF24), size: 16),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('pos.ok'.tr, style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditItemDialog(BuildContext context, PosCartItemModel item) {
    final priceController = TextEditingController(
      text: item.unitPrice % 1 == 0 ? item.unitPrice.toInt().toString() : item.unitPrice.toStringAsFixed(2),
    );
    final noteController = TextEditingController(text: item.note ?? '');

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (ctx) {
        return Dialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: _borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'pos.editItem'.tr}: ${item.product?.name ?? 'Item'}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'pos.customUnitPrice'.tr,
                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                  decoration: InputDecoration(
                    prefixText: '৳ ',
                    prefixStyle: const TextStyle(color: _accentColor, fontWeight: FontWeight.w900),
                    filled: true,
                    fillColor: _itemBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'pos.itemNoteDiscountReason'.tr,
                  style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: noteController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'pos.discountReasonHint'.tr,
                    hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    filled: true,
                    fillColor: _itemBg,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF9CA3AF),
                          side: const BorderSide(color: _borderColor),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('pos.cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final newPrice = double.tryParse(priceController.text.trim());
                          if (newPrice != null && newPrice >= 0) {
                            controller.updateItemDetails(
                              item: item,
                              newUnitPrice: newPrice,
                              note: noteController.text.trim(),
                            );
                            Navigator.of(ctx).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text('pos.save'.tr, style: const TextStyle(fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Grab handle
            const SizedBox(height: 12),
            Container(
              height: 4,
              width: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF4B5563),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 12),

            // Top Bar: Counter & Quick Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // Counter Switcher Chip
                  InkWell(
                    onTap: () => _showCounterSelector(context),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _accentColor.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.point_of_sale_rounded, color: _accentColor, size: 16),
                          const SizedBox(width: 6),
                          Obx(() => Text(
                                controller.selectedCounter.value,
                                style: const TextStyle(
                                  color: _accentColor,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              )),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down_rounded, color: _accentColor, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Refresh Cart Button
                  IconButton(
                    tooltip: 'pos.refreshCart'.tr,
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFF9CA3AF), size: 20),
                    onPressed: controller.fetchActiveCart,
                  ),

                  // Held Bills Button (in header)
                  IconButton(
                    tooltip: 'pos.viewHeldBills'.tr,
                    icon: const Icon(Icons.pause_circle_outline_rounded, color: Color(0xFFFBBF24), size: 22),
                    onPressed: () => PosHeldBillsDialog.show(context, controller),
                  ),

                  // Baki Khata Shortcut
                  IconButton(
                    tooltip: 'baki.title'.tr,
                    icon: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFFEF4444), size: 21),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Get.toNamed(Routes.BAKI_KHATA);
                    },
                  ),

                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Color(0xFF9CA3AF), size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(color: _borderColor, height: 1),

            // Cart Items
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                final items = controller.items;
                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 56,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'pos.cartEmpty'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'pos.cartEmptyDesc'.tr,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12.5),
                          ),
                          const SizedBox(height: 18),
                          OutlinedButton.icon(
                            onPressed: () => PosHeldBillsDialog.show(context, controller),
                            icon: const Icon(Icons.pause_circle_outline_rounded, size: 18),
                            label: Text('pos.checkHeldBills'.tr),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFBBF24),
                              side: const BorderSide(color: Color(0xFFFBBF24)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CartItemTile(
                      item: item,
                      controller: controller,
                      onEdit: () => _showEditItemDialog(context, item),
                    );
                  },
                );
              }),
            ),

            // Footer Summary & POS Quick Actions
            Obx(() {
              final isCartEmpty = controller.isCartEmpty;
              if (isCartEmpty) return const SizedBox.shrink();

              final totalItems = controller.totalItems;
              final subtotal = controller.subtotal;

              return Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: const BoxDecoration(
                  color: Color(0xFF1E2023),
                  border: Border(top: BorderSide(color: _borderColor)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Subtotal Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${'pos.subtotal'.tr} ($totalItems ${'pos.items'.tr})',
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '৳${subtotal.toStringAsFixed(subtotal % 1 == 0 ? 0 : 2)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Action Buttons Row
                    Row(
                      children: [
                        // Park / Hold Bill Button
                        Expanded(
                          flex: 3,
                          child: OutlinedButton.icon(
                            onPressed: () => _showHoldCartDialog(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFFBBF24),
                              side: const BorderSide(color: Color(0xFFFBBF24)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.pause_circle_filled_rounded, size: 18),
                            label: Text(
                              'pos.holdBill'.tr,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Pay / Checkout Button
                        Expanded(
                          flex: 4,
                          child: ElevatedButton.icon(
                            onPressed: () => PosCheckoutModal.show(context, controller),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            icon: const Icon(Icons.check_circle_rounded, size: 18),
                            label: Text(
                              'pos.checkoutPay'.tr,
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.controller,
    required this.onEdit,
  });

  final PosCartItemModel item;
  final PosCartController controller;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final imgUrl = item.product?.imageUrl() ?? '';
    final hasImg = imgUrl.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF242528),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 46,
              height: 46,
              color: const Color(0xFF1B1C1E),
              child: hasImg
                  ? Image.network(
                      imgUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.broken_image_outlined,
                        color: Color(0xFF6B7280),
                        size: 20,
                      ),
                    )
                  : const Icon(
                      Icons.image_not_supported_outlined,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
            ),
          ),

          const SizedBox(width: 10),

          // Title, Unit Price, Note
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product?.name ?? 'Product #${item.productId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onEdit,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '৳${item.unitPrice.toStringAsFixed(item.unitPrice % 1 == 0 ? 0 : 2)}',
                        style: const TextStyle(
                          color: Color(0xFF34D399),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit_outlined, size: 12, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                ),
                if (item.note != null && item.note!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.note!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 10.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Qty Stepper [-] [qty] [+]
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1B1C1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2E3033)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepperButton(
                  icon: Icons.remove,
                  onTap: () => controller.updateItemQty(item: item, newQty: item.qty - 1),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '${item.qty}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _StepperButton(
                  icon: Icons.add,
                  onTap: () => controller.updateItemQty(item: item, newQty: item.qty + 1),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Line total & remove
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '৳${item.lineTotal.toStringAsFixed(item.lineTotal % 1 == 0 ? 0 : 2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              InkWell(
                onTap: () {
                  if (item.id != null) {
                    controller.removeItem(itemId: item.id!);
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(2),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 17,
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

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }
}
