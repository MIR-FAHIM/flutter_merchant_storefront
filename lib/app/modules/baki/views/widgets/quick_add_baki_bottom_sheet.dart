import 'package:ecom_delivery_flutter/app/models/baki/baki_summary_model.dart';
import 'package:ecom_delivery_flutter/app/modules/baki/controllers/baki_controller.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuickAddBakiBottomSheet extends GetWidget<BakiController> {
  const QuickAddBakiBottomSheet({
    super.key,
    required this.customer,
    this.onSuccess,
  });

  final BakiCustomerItem customer;
  final VoidCallback? onSuccess;

  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _inputBg = Color(0xFF242528);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _redAccent = Color(0xFFE53935);

  static Future<void> show({
    required BuildContext context,
    required BakiCustomerItem customer,
    BakiController? controller,
    VoidCallback? onSuccess,
  }) {
    if (!Get.isRegistered<BakiController>()) {
      Get.put(BakiController());
    }
    final ctrl = controller ?? Get.find<BakiController>();
    ctrl.initQuickAdd(customer);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardColor,
      barrierColor: Colors.black.withOpacity(0.65),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => QuickAddBakiBottomSheet(
        customer: customer,
        onSuccess: onSuccess,
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final amount = double.tryParse(controller.quickAddAmountController.text.trim());
    if (amount == null || amount <= 0) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        title: 'baki.bakiKhata'.tr,
        message: 'baki.enterAmount'.tr,
      ));
      return;
    }

    final note = controller.quickAddNoteController.text.trim();
    if (note.isEmpty) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        title: 'baki.bakiKhata'.tr,
        message: 'baki.enterNote'.tr,
      ));
      return;
    }

    final dueDate = controller.quickAddSelectedDueDate.value;
    final formattedDueDate = dueDate != null
        ? "${dueDate.year.toString().padLeft(4, '0')}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}"
        : null;

    final ok = await controller.quickAddBaki(
      customerId: customer.customerId ?? 0,
      amount: amount,
      note: note,
      dueDate: formattedDueDate,
    );

    if (ok && context.mounted) {
      Navigator.of(context).pop();
      onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentDue = customer.totalBaki;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  height: 4,
                  width: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B5563),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Title & Customer Details
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _redAccent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.note_add_rounded,
                      color: _redAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'baki.quickAddBaki'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          customer.name ?? 'Customer',
                          style: const TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Current Due Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'baki.totalDue'.tr,
                          style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '৳${currentDue.toStringAsFixed(currentDue % 1 == 0 ? 0 : 2)}',
                          style: const TextStyle(color: Color(0xFFF59E0B), fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: _borderColor, height: 1),
              const SizedBox(height: 14),

              // Amount Field
              Text(
                'baki.bakiAmount'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller.quickAddAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                decoration: InputDecoration(
                  prefixText: '৳ ',
                  prefixStyle: const TextStyle(color: _redAccent, fontWeight: FontWeight.w900, fontSize: 16),
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: _inputBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _redAccent)),
                ),
              ),

              const SizedBox(height: 14),

              // Due Date (Optional)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'baki.dueDate'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  Obx(() => controller.quickAddSelectedDueDate.value != null
                      ? GestureDetector(
                          onTap: () => controller.quickAddSelectedDueDate.value = null,
                          child: Text(
                            'pos.cancel'.tr,
                            style: const TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.quickAddSelectedDueDate.value ?? now.add(const Duration(days: 7)),
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 730)),
                    builder: (ctx, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: _redAccent,
                            onPrimary: Colors.white,
                            surface: _cardColor,
                            onSurface: Colors.white,
                          ),
                          dialogBackgroundColor: _cardColor,
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    controller.quickAddSelectedDueDate.value = picked;
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Obx(() {
                    final pickedDate = controller.quickAddSelectedDueDate.value;
                    return Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: pickedDate != null ? _redAccent : const Color(0xFF9CA3AF),
                          size: 16,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          pickedDate != null
                              ? "${pickedDate.day.toString().padLeft(2, '0')}/${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}"
                              : 'baki.selectDueDate'.tr,
                          style: TextStyle(
                            color: pickedDate != null ? Colors.white : const Color(0xFF6B7280),
                            fontSize: 13,
                            fontWeight: pickedDate != null ? FontWeight.w800 : FontWeight.normal,
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),

              const SizedBox(height: 14),

              // Note / Reason Field (Required)
              Text(
                'baki.noteRequired'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller.quickAddNoteController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. Bought items on manual baki',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  filled: true,
                  fillColor: _inputBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _redAccent)),
                ),
              ),

              const SizedBox(height: 20),

              // Submit Button
              Obx(() {
                final isSubmitting = controller.isActionLoading.value;
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSubmitting ? null : () => _handleSubmit(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _redAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
                          )
                        : Text(
                            'baki.saveBaki'.tr,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
