import 'package:ecom_delivery_flutter/app/modules/reports/controllers/shop_cash_flow_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddExpenseBottomSheet extends GetWidget<ShopCashFlowController> {
  const AddExpenseBottomSheet({super.key});

  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _inputBg = Color(0xFF242528);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _expenseRed = Color(0xFFEF4444);

  @override
  ShopCashFlowController get controller =>
      Get.isRegistered<ShopCashFlowController>()
          ? Get.find<ShopCashFlowController>()
          : Get.put(ShopCashFlowController());

  static Future<void> show({
    required BuildContext context,
    ShopCashFlowController? controller,
  }) {
    if (!Get.isRegistered<ShopCashFlowController>()) {
      Get.put(ShopCashFlowController());
    }
    final ctrl = controller ?? Get.find<ShopCashFlowController>();
    ctrl.initExpenseForm();

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardColor,
      barrierColor: Colors.black.withOpacity(0.65),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const AddExpenseBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _expenseRed.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.money_off_rounded, color: _expenseRed, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add Daily Shop Expense'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Logs cash outflow directly paid from the till'.tr,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Amount Input
            Text(
              'Expense Amount (৳)*'.tr,
              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller.expenseAmountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                prefixText: '৳ ',
                prefixStyle: const TextStyle(color: _expenseRed, fontSize: 18, fontWeight: FontWeight.bold),
                hintText: '0.00',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: _inputBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _expenseRed, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Category Dropdown
            Text(
              'Expense Category*'.tr,
              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            Obx(() {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: _inputBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.expenseCategory.value,
                    dropdownColor: _cardColor,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    items: ShopCashFlowController.expenseCategories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat,
                        child: Text(cat.tr),
                      );
                    }).toList(),
                    onChanged: (newVal) {
                      if (newVal != null) {
                        controller.expenseCategory.value = newVal;
                      }
                    },
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),

            // Note (Optional)
            Text(
              'Note / Purpose (Optional)'.tr,
              style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: controller.expenseNoteController,
              maxLines: 2,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Tea for guests, van fare, electricity bill'.tr,
                hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
                filled: true,
                fillColor: _inputBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _borderColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _expenseRed, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            Obx(() {
              final loading = controller.isActionLoading.value;
              return SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: loading
                      ? null
                      : () async {
                          final ok = await controller.submitExpense();
                          if (ok && context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _expenseRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Save Expense'.tr,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
