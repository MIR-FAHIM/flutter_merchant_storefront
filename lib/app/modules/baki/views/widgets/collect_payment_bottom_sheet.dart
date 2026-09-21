import 'package:ecom_delivery_flutter/app/models/baki/baki_summary_model.dart';
import 'package:ecom_delivery_flutter/app/modules/baki/controllers/baki_controller.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CollectPaymentBottomSheet extends GetWidget<BakiController> {
  const CollectPaymentBottomSheet({
    super.key,
    required this.customer,
    this.onSuccess,
  });

  final BakiCustomerItem customer;
  final VoidCallback? onSuccess;

  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _inputBg = Color(0xFF242528);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _greenAccent = Color(0xFF43A047);

  static final List<Map<String, String>> _methods = [
    {'id': 'cash', 'label': 'Cash (নগদ)'},
    {'id': 'bkash', 'label': 'bKash (বিকাশ)'},
    {'id': 'nagad', 'label': 'Nagad (নগদ)'},
    {'id': 'rocket', 'label': 'Rocket (রকেট)'},
    {'id': 'card', 'label': 'Card (কার্ড)'},
    {'id': 'bank_transfer', 'label': 'Bank (ব্যাংক)'},
    {'id': 'other', 'label': 'Other (অন্যান্য)'},
  ];

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
    ctrl.initCollectPayment(customer);

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _cardColor,
      barrierColor: Colors.black.withOpacity(0.65),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CollectPaymentBottomSheet(
        customer: customer,
        onSuccess: onSuccess,
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final amount = double.tryParse(controller.collectAmountController.text.trim());
    if (amount == null || amount <= 0) {
      Get.showSnackbar(Ui.ErrorSnackBar(
        title: 'baki.bakiKhata'.tr,
        message: 'baki.enterAmount'.tr,
      ));
      return;
    }

    final dueDate = controller.collectSelectedDueDate.value;
    final formattedDueDate = dueDate != null
        ? "${dueDate.year.toString().padLeft(4, '0')}-${dueDate.month.toString().padLeft(2, '0')}-${dueDate.day.toString().padLeft(2, '0')}"
        : null;

    final note = controller.collectNoteController.text.trim();

    final ok = await controller.collectPayment(
      customerId: customer.customerId ?? 0,
      amount: amount,
      paymentMethod: controller.collectSelectedMethod.value,
      note: note.isNotEmpty ? note : null,
      dueDate: formattedDueDate,
    );

    if (ok && context.mounted) {
      Navigator.of(context).pop();
      onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final due = customer.totalBaki;

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
                      color: _greenAccent.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.payments_rounded,
                      color: _greenAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'baki.collectPayment'.tr,
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
                      color: Colors.redAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'baki.totalDue'.tr,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '৳${due.toStringAsFixed(due % 1 == 0 ? 0 : 2)}',
                          style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: _borderColor, height: 1),
              const SizedBox(height: 14),

              // Amount Field with Quick "Full Pay" chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'baki.amount'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  if (due > 0)
                    InkWell(
                      onTap: () {
                        controller.collectAmountController.text =
                            due % 1 == 0 ? due.toInt().toString() : due.toStringAsFixed(2);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _greenAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _greenAccent.withOpacity(0.4)),
                        ),
                        child: Text(
                          'baki.fullPay'.tr,
                          style: const TextStyle(
                            color: _greenAccent,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller.collectAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                decoration: InputDecoration(
                  prefixText: '৳ ',
                  prefixStyle: const TextStyle(color: _greenAccent, fontWeight: FontWeight.w900, fontSize: 16),
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280)),
                  filled: true,
                  fillColor: _inputBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _greenAccent)),
                ),
              ),

              const SizedBox(height: 14),

              // Payment Method Dropdown
              Text(
                'baki.paymentMethod'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                decoration: BoxDecoration(
                  color: _inputBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: Obx(() => DropdownButton<String>(
                        value: controller.collectSelectedMethod.value,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF2E3033),
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white),
                        items: _methods.map((m) {
                          return DropdownMenuItem<String>(
                            value: m['id'],
                            child: Text(
                              m['label']!,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            controller.collectSelectedMethod.value = val;
                          }
                        },
                      )),
                ),
              ),

              const SizedBox(height: 14),

              // Next Due Date (Optional)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'baki.dueDate'.tr,
                    style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                  Obx(() => controller.collectSelectedDueDate.value != null
                      ? GestureDetector(
                          onTap: () => controller.collectSelectedDueDate.value = null,
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
                    initialDate: controller.collectSelectedDueDate.value ?? now.add(const Duration(days: 7)),
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 730)),
                    builder: (ctx, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: _greenAccent,
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
                    controller.collectSelectedDueDate.value = picked;
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
                    final pickedDate = controller.collectSelectedDueDate.value;
                    return Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          color: pickedDate != null ? _greenAccent : const Color(0xFF9CA3AF),
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

              // Note Field
              Text(
                'baki.noteOptional'.tr,
                style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller.collectNoteController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. Paid in cash at counter',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  filled: true,
                  fillColor: _inputBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: _borderColor)),
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
                      backgroundColor: _greenAccent,
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
                            'baki.savePayment'.tr,
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
