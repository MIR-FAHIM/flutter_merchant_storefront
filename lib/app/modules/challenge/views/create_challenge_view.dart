import 'package:ecom_delivery_flutter/app/modules/challenge/controllers/create_challenge_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/challenge/views/widgets/reward_form_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateChallengeView extends GetView<CreateChallengeController> {
  const CreateChallengeView({super.key});

  static const Color _bgColor = Color(0xFF111213);
  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _accentGreen = Color(0xFF34D399);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _cardColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'নতুন চ্যালেঞ্জ তৈরি করুন',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Guide Note: What to do and Why to do
              _buildGuideNote(),

              const SizedBox(height: 14),

              // Error Message Banner (if any)
              Obx(() {
                if (controller.errorMessage.value.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.redAccent.withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Section 1: Basic Information
              _buildSectionCard(
                title: 'প্রাথমিক তথ্য',
                icon: Icons.info_outline_rounded,
                children: [
                  const Text(
                    'চ্যালেঞ্জের নাম / টাইটেল *',
                    style: TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.titleController,
                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                    decoration: _inputDecoration(
                      hintText: 'যেমন: উইকলি শপিং রেস বা ঈদ স্পেশাল অফার',
                      prefixIcon: const Icon(
                        Icons.edit_note_rounded,
                        color: _accentGreen,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'চ্যালেঞ্জের বিবরণ (ঐচ্ছিক)',
                    style: TextStyle(
                      color: Color(0xFFD1D5DB),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: controller.descriptionController,
                    maxLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF242528),
                      hintText:
                          'কাস্টমাররা কীভাবে কেনাকাটা করে পয়েন্ট পাবে এবং কী পুরস্কার জিততে পারবে তা সহজ ভাষায় লিখুন...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                      ),
                      contentPadding: const EdgeInsets.all(12),
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
                        borderSide: const BorderSide(
                          color: _accentGreen,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Section 2: Duration / Dates
              _buildSectionCard(
                title: 'সময়সীমা ও মেয়াদ',
                icon: Icons.calendar_month_rounded,
                subtitle: 'অফারের শুরু এবং শেষের তারিখ নির্ধারণ করুন (ঐচ্ছিক)',
                children: [
                  Row(
                    children: [
                      // Start Date
                      Expanded(
                        child: Obx(
                          () => _buildDatePickerField(
                            context: context,
                            label: 'শুরুর তারিখ',
                            date: controller.startDate.value,
                            onTap: () => controller.pickDate(context, true),
                            onClear: () => controller.clearDate(true),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // End Date
                      Expanded(
                        child: Obx(
                          () => _buildDatePickerField(
                            context: context,
                            label: 'শেষের তারিখ',
                            date: controller.endDate.value,
                            onTap: () => controller.pickDate(context, false),
                            onClear: () => controller.clearDate(false),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Section 3: Earning Rule
              _buildSectionCard(
                title: 'পয়েন্ট উপার্জনের নিয়ম',
                icon: Icons.tune_rounded,
                subtitle: 'কত টাকার কেনাকাটায় কত পয়েন্ট পাবে তা নির্ধারণ করুন',
                children: [
                  Row(
                    children: [
                      // Spend Amount
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'খরচের পরিমাণ (৳) *',
                              style: TextStyle(
                                color: Color(0xFFD1D5DB),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: controller.spendAmountController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                              decoration: _inputDecoration(
                                hintText: '১০০',
                                prefixIcon: const Icon(
                                  Icons.payments_outlined,
                                  color: Color(0xFF60A5FA),
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Points Awarded
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'প্রাপ্ত পয়েন্ট *',
                              style: TextStyle(
                                color: Color(0xFFD1D5DB),
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextFormField(
                              controller: controller.pointsAwardedController,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                              decoration: _inputDecoration(
                                hintText: '৫',
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
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Explanation Text for Seller
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF34D399).withOpacity(0.2),
                        width: 0.8,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Color(0xFF34D399),
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "💡 উদাহরণ: প্রতি ১০০ টাকা কেনাকাটায় কাস্টমার ৫ পয়েন্ট অর্জন করবে।",
                            style: TextStyle(
                              color: Color(0xFF6EE7B7),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Section 4: Dynamic Milestone Rewards
              _buildSectionCard(
                title: 'মাইলস্টোন পুরস্কারসমূহ',
                icon: Icons.card_giftcard_rounded,
                subtitle: 'পয়েন্ট টার্গেটে পৌঁছালে কাস্টমার যে উপহার আনলক করবে',
                children: [
                  Obx(
                    () => Column(
                      children: [
                        for (int i = 0; i < controller.rewards.length; i++)
                          RewardFormCard(
                            key: ValueKey(controller.rewards[i]),
                            index: i,
                            item: controller.rewards[i],
                            canRemove: controller.rewards.length > 1,
                            onRemove: () => controller.removeReward(i),
                          ),
                      ],
                    ),
                  ),

                  // Add Reward Button
                  InkWell(
                    onTap: () => controller.addReward(),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF242528),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _accentGreen.withOpacity(0.5),
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            color: _accentGreen,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '+ আরেকটি মাইলস্টোন পুরস্কার যোগ করুন',
                            style: TextStyle(
                              color: _accentGreen,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Submit Button
              Obx(() {
                final isSubmitting = controller.isSubmitting.value;
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isSubmitting
                        ? null
                        : () => controller.submitChallenge(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'চ্যালেঞ্জ চালু করুন (Publish Challenge)',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                            ),
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

  Widget _buildGuideNote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  Icons.stars_rounded,
                  color: Color(0xFFF59E0B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '💡 চ্যালেঞ্জ তৈরির নিয়ম: কী করবেন এবং কেন করবেন?',
                  style: TextStyle(
                    color: Color(0xFFFDE68A),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // কী করবেন
          const Text(
            '📌 কী করবেন (What to do):',
            style: TextStyle(
              color: Color(0xFF34D399),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          _bulletPoint('চ্যালেঞ্জের নাম ও বিবরণ লিখুন যাতে কাস্টমাররা সহজেই বুঝতে পারে।'),
          _bulletPoint('মেয়াদ ঠিক করুন (খালি রাখলে চ্যালেঞ্জটি সবসময় চলবে)।'),
          _bulletPoint('পয়েন্ট নির্ধারণ করুন: কত টাকার কেনাকাটায় কাস্টমার কত পয়েন্ট পাবে তা সেট করুন।'),
          _bulletPoint('আকর্ষণীয় গিফট যুক্ত করুন: নির্দিষ্ট পয়েন্ট অর্জন করলে কাস্টমার কী উপহার বা ছাড় পাবে তা যোগ করুন।'),
          const SizedBox(height: 10),
          // কেন করবেন
          const Text(
            '🎯 কেন করবেন ও কী সুবিধা (Why to do):',
            style: TextStyle(
              color: Color(0xFF60A5FA),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          _bulletPoint('অর্ডারের সাইজ বৃদ্ধি: পয়েন্ট টার্গেট ছোঁয়ার জন্য কাস্টমাররা অল্প টাকার বদলে বেশি টাকার অর্ডার করবে।'),
          _bulletPoint('কাস্টমার ধরে রাখা (Loyalty): রিওয়ার্ড পয়েন্ট জমে থাকলে কাস্টমার অন্য দোকান ছেড়ে আপনার দোকানেই বারবার আসবে।'),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFFD1D5DB),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: _accentGreen, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD1D5DB),
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF242528),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF9CA3AF),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'তারিখ বেছে নিন',
                    style: TextStyle(
                      color: date != null ? Colors.white : const Color(0xFF6B7280),
                      fontSize: 12.5,
                      fontWeight: date != null ? FontWeight.w700 : FontWeight.normal,
                    ),
                  ),
                ),
                if (date != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF9CA3AF),
                      size: 16,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required Widget prefixIcon,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF242528),
      hintText: hintText,
      hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12.5),
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
        borderSide: const BorderSide(color: _accentGreen, width: 1.2),
      ),
    );
  }
}
