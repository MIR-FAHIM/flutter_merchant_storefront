import 'package:ecom_delivery_flutter/app/modules/challenge/controllers/challenge_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/challenge/views/widgets/challenge_card.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChallengeListView extends GetView<ChallengeController> {
  const ChallengeListView({super.key});

  static const Color _bgColor = Color(0xFF111213);
  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _accentGreen = Color(0xFF34D399);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _cardColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Row(
          children: [
            Icon(
              Icons.emoji_events_rounded,
              color: Color(0xFFF59E0B),
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'রিওয়ার্ড রেস ও চ্যালেঞ্জ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => controller.fetchChallenges(force: true),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'রিফ্রেশ করুন',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.CHALLENGE_CREATE),
        backgroundColor: _accentGreen,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded, size: 22, color: Colors.black),
        label: const Text(
          'নতুন চ্যালেঞ্জ তৈরি করুন',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
            fontSize: 13.5,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.challenges.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: _accentGreen,
              strokeWidth: 2.5,
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.challenges.isEmpty) {
          return _buildErrorState();
        }

        if (controller.challenges.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: _accentGreen,
          backgroundColor: _cardColor,
          onRefresh: () => controller.fetchChallenges(force: true),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: controller.challenges.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildGuideNote();
              }
              final challenge = controller.challenges[index - 1];
              return ChallengeCard(
                challenge: challenge,
                onTap: () async {
                  final result = await Get.toNamed(
                    Routes.CHALLENGE_DETAILS,
                    arguments: challenge,
                  );
                  if (result == true) {
                    controller.fetchChallenges(force: true);
                  }
                },
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildGuideNote() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
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
                  Icons.lightbulb_rounded,
                  color: Color(0xFFF59E0B),
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  '💡 চ্যালেঞ্জ গাইড: কী করবেন এবং কেন করবেন?',
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
          _bulletPoint('নতুন অফার বা শপিং রেস চালু করতে নিচের "+ নতুন চ্যালেঞ্জ তৈরি করুন" বাটনে চাপ দিন।'),
          _bulletPoint('চলমান যেকোনো চ্যালেঞ্জের কার্ডে ট্যাপ করে কাস্টমারদের পয়েন্টের অগ্রগতি ও লিডারবোর্ড দেখুন।'),
          _bulletPoint('প্রয়োজনে চ্যালেঞ্জ সাময়িকভাবে বন্ধ (Pause) বা পুনরায় চালু করতে পারবেন।'),
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
          _bulletPoint('বেশি বিক্রির অনুপ্রেরণা: পয়েন্ট ও ফ্রি গিফটের লোভে কাস্টমাররা বেশি টাকার অর্ডার করবে।'),
          _bulletPoint('কাস্টমার ধরে রাখা (Loyalty): নিয়মিত রিওয়ার্ড পেলে কাস্টমাররা বারবার আপনার দোকান থেকেই কেনাকাটা করবে।'),
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

  Widget _buildEmptyState() {
    return RefreshIndicator(
      color: _accentGreen,
      backgroundColor: _cardColor,
      onRefresh: () => controller.fetchChallenges(force: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        child: Column(
          children: [
            _buildGuideNote(),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF2E3033)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.emoji_events_outlined,
                      color: Color(0xFFF59E0B),
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'এখনও কোনো চ্যালেঞ্জ তৈরি করা হয়নি',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'রিওয়ার্ড রেস আপনার কাস্টমারদের বেশি বেশি কেনাকাটা করতে উৎসাহিত করে। কাস্টমাররা প্রতি কেনাকাটায় পয়েন্ট অর্জন করে আকর্ষণীয় গিফট ও ডিসকাউন্ট আনলক করতে পারে!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(Routes.CHALLENGE_CREATE),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentGreen,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add_rounded, color: Colors.black),
                    label: const Text(
                      'প্রথম চ্যালেঞ্জ তৈরি করুন',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 14),
            Text(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'তথ্য লোড করতে সমস্যা হয়েছে',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => controller.fetchChallenges(force: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E3033),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      ),
    );
  }
}
