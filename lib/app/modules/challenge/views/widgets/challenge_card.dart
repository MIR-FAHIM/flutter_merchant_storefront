import 'package:ecom_delivery_flutter/app/models/challenge/challenge_model.dart';
import 'package:flutter/material.dart';

class ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final VoidCallback onTap;

  const ChallengeCard({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _accentGreen = Color(0xFF34D399);
  static const Color _accentGold = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final isActive = challenge.isActive;
    final statusColor = isActive ? _accentGreen : const Color(0xFF9CA3AF);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? _accentGreen.withOpacity(0.3) : _borderColor,
          width: isActive ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Title & Active Status Pill
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _accentGold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _accentGold.withOpacity(0.3),
                          width: 0.8,
                        ),
                      ),
                      child: const Icon(
                        Icons.emoji_events_rounded,
                        color: _accentGold,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              height: 1.25,
                            ),
                          ),
                          if (challenge.description != null &&
                              challenge.description!.trim().isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              challenge.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF9CA3AF),
                                fontSize: 12,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: statusColor.withOpacity(0.4),
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
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            challenge.statusBadgeTextBn,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Rule & Target Points Row
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Earning Rule
                    _InfoChip(
                      icon: Icons.monetization_on_outlined,
                      label: challenge.earningRuleTextBn,
                      color: const Color(0xFF60A5FA),
                    ),
                    // Target / Milestone Points
                    if (challenge.maxMilestonePoints > 0)
                      _InfoChip(
                        icon: Icons.military_tech_outlined,
                        label: 'টার্গেট: ${challenge.maxMilestonePoints} পয়েন্ট',
                        color: _accentGold,
                      ),
                    // Participants count
                    if ((challenge.participantsCount ?? 0) > 0)
                      _InfoChip(
                        icon: Icons.people_outline_rounded,
                        label: '${challenge.participantsCount} জন যুক্ত',
                        color: const Color(0xFF34D399),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Divider line
                const Divider(color: _borderColor, height: 1),

                const SizedBox(height: 10),

                // Bottom Row: Date Range & Primary Reward Preview
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Color(0xFF9CA3AF),
                      size: 13,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        challenge.dateRangeTextBn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.14),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.card_giftcard_rounded,
                            color: Color(0xFFA78BFA),
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 130),
                            child: Text(
                              challenge.primaryRewardTitleBn,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFA78BFA),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF6B7280),
                      size: 12,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3), width: 0.6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
