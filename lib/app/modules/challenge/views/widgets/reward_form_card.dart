import 'package:ecom_delivery_flutter/app/modules/challenge/controllers/create_challenge_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RewardFormCard extends StatelessWidget {
  final int index;
  final RewardFormItem item;
  final VoidCallback onRemove;
  final bool canRemove;

  const RewardFormCard({
    super.key,
    required this.index,
    required this.item,
    required this.onRemove,
    required this.canRemove,
  });

  static const Color _cardColor = Color(0xFF242528);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _accentColor = Color(0xFF34D399);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Milestone Number & Remove Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      color: Color(0xFFF59E0B),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Milestone Reward #${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.redAccent,
                    size: 20,
                  ),
                  tooltip: 'Remove Reward',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 1: Points Required & Reward Type Dropdown
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Points Required
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Points Required *',
                      style: TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: item.pointsRequiredController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: _inputDecoration(
                        hintText: 'e.g. 5000',
                        prefixIcon: const Icon(
                          Icons.stars_rounded,
                          color: Color(0xFFF59E0B),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Reward Type Dropdown
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reward Type *',
                      style: TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Obx(
                      () => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B1C1E),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _borderColor),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: item.rewardType.value,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1B1C1E),
                            icon: const Icon(
                              Icons.arrow_drop_down,
                              color: Color(0xFF9CA3AF),
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                            items: CreateChallengeController.availableRewardTypes
                                .map((type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(_typeLabel(type)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) item.rewardType.value = val;
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Reward Name
          const Text(
            'Reward Name *',
            style: TextStyle(
              color: Color(0xFFD1D5DB),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: item.nameController,
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: _inputDecoration(
              hintText: 'e.g. Free Double Burger or 10% Discount',
              prefixIcon: const Icon(
                Icons.card_giftcard_rounded,
                color: _accentColor,
                size: 18,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Reward Value (Optional)
          Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Reward Value',
                      style: TextStyle(
                        color: Color(0xFFD1D5DB),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _valueHintSuffix(item.rewardType.value),
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: item.rewardValueController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  decoration: _inputDecoration(
                    hintText: _valuePlaceholder(item.rewardType.value),
                    prefixIcon: const Icon(
                      Icons.tag_rounded,
                      color: Color(0xFF9CA3AF),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required Widget prefixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF1B1C1E),
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
      prefixIcon: prefixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _accentColor, width: 1.2),
      ),
    );
  }

  static String _typeLabel(String type) {
    switch (type) {
      case 'PRODUCT':
        return '🎁 Product';
      case 'DISCOUNT':
        return '🏷️ Discount';
      case 'VOUCHER':
        return '🎟️ Voucher';
      case 'FREE_DELIVERY':
        return '🚚 Free Delivery';
      case 'CUSTOM':
      default:
        return '⭐ Custom';
    }
  }

  static String _valueHintSuffix(String type) {
    switch (type) {
      case 'DISCOUNT':
        return '(e.g. 10% or 100)';
      case 'PRODUCT':
        return '(e.g. Product ID: 123)';
      case 'VOUCHER':
        return '(e.g. Coupon Code: SUM50)';
      default:
        return '(Optional value or notes)';
    }
  }

  static String _valuePlaceholder(String type) {
    switch (type) {
      case 'DISCOUNT':
        return '10% or ৳100';
      case 'PRODUCT':
        return '123 (Product ID)';
      case 'VOUCHER':
        return 'SUMMER50';
      default:
        return 'Enter value or code';
    }
  }
}
