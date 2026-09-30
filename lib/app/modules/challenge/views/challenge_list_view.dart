import 'package:ecom_delivery_flutter/app/modules/challenge/controllers/challenge_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/challenge/views/widgets/challenge_card.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChallengeListView extends GetView<ChallengeController> {
  const ChallengeListView({super.key});

  static const Color _bgColor = Color(0xFF111213);
  static const Color _accentGreen = Color(0xFF34D399);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1B1C1E),
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
              'Reward Races',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 19,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => controller.fetchChallenges(force: true),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Refresh',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.CHALLENGE_CREATE),
        backgroundColor: _accentGreen,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded, size: 22, color: Colors.black),
        label: const Text(
          'Create Challenge',
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
          backgroundColor: const Color(0xFF1B1C1E),
          onRefresh: () => controller.fetchChallenges(force: true),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
            itemCount: controller.challenges.length,
            itemBuilder: (context, index) {
              final challenge = controller.challenges[index];
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

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
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
                size: 56,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "You haven't created any challenges yet",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Reward races motivate your customers to purchase more often by earning points toward milestones and unlocking free rewards!",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(Routes.CHALLENGE_CREATE),
              style: ElevatedButton.styleFrom(
                backgroundColor: _accentGreen,
                foregroundColor: Colors.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.add_rounded, color: Colors.black),
              label: const Text(
                'Create First Challenge',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Colors.black,
                ),
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
              controller.errorMessage.value,
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
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
