import 'package:ecom_delivery_flutter/app/models/challenge/challenge_model.dart';
import 'package:ecom_delivery_flutter/app/modules/challenge/controllers/challenge_detail_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/challenge/views/widgets/leaderboard_tile.dart';
import 'package:ecom_delivery_flutter/app/modules/challenge/views/widgets/stats_kpi_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChallengeDetailView extends GetWidget<ChallengeDetailController> {
  const ChallengeDetailView({super.key});

  static const Color _bgColor = Color(0xFF111213);
  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _accentGreen = Color(0xFF34D399);
  static const Color _accentGold = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _cardColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Obx(() {
          final c = controller.challenge.value;
          return Text(
            c?.title ?? 'Challenge Details',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          );
        }),
        actions: [
          IconButton(
            onPressed: () => controller.refreshAll(),
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            tooltip: 'Refresh',
          ),
          Obx(() {
            final c = controller.challenge.value;
            if (c == null) return const SizedBox.shrink();
            
            return PopupMenuButton<String>(
              color: _cardColor,
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white70),
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmation(context);
                } else if (value == 'toggle') {
                  controller.toggleStatus(!c.isActive);
                }
              },
              itemBuilder: (context) {
                return [
                  PopupMenuItem(
                    value: 'toggle',
                    child: Text(
                      c.isActive ? 'Pause Challenge' : 'Activate Challenge',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text(
                      'Delete Challenge',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ];
              },
            );
          }),
        ],
      ),
      body: RefreshIndicator(
        color: _accentGreen,
        backgroundColor: _cardColor,
        onRefresh: () => controller.refreshAll(),
        child: NotificationListener<ScrollNotification>(
          onNotification: (ScrollNotification scrollInfo) {
            if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 200) {
              controller.loadMoreParticipants();
            }
            return false;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 36),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Challenge Overview Header Card
              Obx(() {
                final c = controller.challenge.value;
                if (c == null) return const SizedBox.shrink();
                return _buildChallengeOverviewCard(c);
              }),

              const SizedBox(height: 18),

              // Statistics Header Title
              const Row(
                children: [
                  Icon(
                    Icons.insights_rounded,
                    color: _accentGreen,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Performance & Statistics',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 5 KPI Statistics Cards
              Obx(() {
                if (controller.isStatsLoading.value &&
                    controller.stats.value == null) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: CircularProgressIndicator(
                        color: _accentGreen,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                final s = controller.stats.value ?? ChallengeStatsModel();

                return Column(
                  children: [
                    // Row 1: Total Participants & Total Points Issued
                    Row(
                      children: [
                        Expanded(
                          child: StatsKpiCard(
                            title: 'Total Participants',
                            value: '${s.totalParticipants}',
                            icon: Icons.people_alt_rounded,
                            accentColor: const Color(0xFF60A5FA),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: StatsKpiCard(
                            title: 'Points Issued',
                            value: _formatNumber(s.totalPointsIssued),
                            icon: Icons.stars_rounded,
                            accentColor: _accentGold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Row 2: Rewards Unlocked, Claimed, Redeemed
                    Row(
                      children: [
                        Expanded(
                          child: StatsKpiCard(
                            title: 'Unlocked',
                            value: '${s.rewardsUnlocked}',
                            icon: Icons.lock_open_rounded,
                            accentColor: const Color(0xFF34D399),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatsKpiCard(
                            title: 'Claimed',
                            value: '${s.rewardsClaimed}',
                            icon: Icons.card_giftcard_rounded,
                            accentColor: const Color(0xFFA78BFA),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: StatsKpiCard(
                            title: 'Redeemed',
                            value: '${s.rewardsRedeemed}',
                            icon: Icons.check_circle_rounded,
                            accentColor: const Color(0xFF2DD4BF),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),

              const SizedBox(height: 24),

              // Leaderboard Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.leaderboard_rounded,
                        color: _accentGold,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Participant Leaderboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Obx(
                    () => Text(
                      '${controller.participants.length} Ranked',
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Leaderboard List
              Obx(() {
                if (controller.isParticipantsLoading.value &&
                    controller.participants.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: CircularProgressIndicator(
                        color: _accentGreen,
                        strokeWidth: 2,
                      ),
                    ),
                  );
                }

                if (controller.participants.isEmpty) {
                  return _buildLeaderboardEmptyState();
                }

                return Column(
                  children: [
                    for (int i = 0;
                        i < controller.participants.length;
                        i++)
                      LeaderboardTile(
                        participant: controller.participants[i],
                        index: i,
                      ),
                    if (controller.isMoreLoading.value)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _accentGreen,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
      )
    );
  }

  Widget _buildChallengeOverviewCard(ChallengeModel challenge) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: challenge.isActive
                      ? _accentGreen.withOpacity(0.14)
                      : Colors.grey.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: challenge.isActive
                        ? _accentGreen.withOpacity(0.4)
                        : Colors.grey.withOpacity(0.4),
                    width: 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: challenge.isActive ? _accentGreen : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      challenge.statusBadgeText,
                      style: TextStyle(
                        color: challenge.isActive ? _accentGreen : Colors.grey,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: Color(0xFF9CA3AF),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    challenge.dateRangeText,
                    style: const TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            challenge.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),

          if (challenge.description != null &&
              challenge.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              challenge.description!,
              style: const TextStyle(
                color: Color(0xFFD1D5DB),
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Earning Rule Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF242528),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on_outlined,
                  color: Color(0xFF60A5FA),
                  size: 15,
                ),
                const SizedBox(width: 6),
                Text(
                  'Earning Rule: ${challenge.earningRuleText}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          if (challenge.rewards.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Milestone Rewards:',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: challenge.rewards.map((r) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: r.rewardTypeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: r.rewardTypeColor.withOpacity(0.3),
                      width: 0.7,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(r.rewardTypeIcon, color: r.rewardTypeColor, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${r.pointsRequired} pts: ${r.name}',
                        style: TextStyle(
                          color: r.rewardTypeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLeaderboardEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.groups_outlined,
            color: Color(0xFF6B7280),
            size: 42,
          ),
          SizedBox(height: 10),
          Text(
            'No participants yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Customers who purchase and earn points during this challenge will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatNumber(num val) {
    if (val >= 1000000) {
      return '${(val / 1000000).toStringAsFixed(1)}M';
    } else if (val >= 1000) {
      return '${(val / 1000).toStringAsFixed(1)}k';
    }
    return val % 1 == 0 ? val.toInt().toString() : val.toStringAsFixed(1);
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _cardColor,
          title: const Text(
            'Delete Challenge',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Are you sure you want to delete this challenge? This action cannot be undone and will delete all associated data.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteChallenge();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );
  }
}
