import 'package:ecom_delivery_flutter/app/models/challenge/challenge_model.dart';
import 'package:flutter/material.dart';

class LeaderboardTile extends StatelessWidget {
  final ChallengeParticipantModel participant;
  final int index;

  const LeaderboardTile({
    super.key,
    required this.participant,
    required this.index,
  });

  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _borderColor = Color(0xFF2E3033);

  @override
  Widget build(BuildContext context) {
    final rank = participant.rank ?? (index + 1);
    final rankBadge = _getRankBadge(rank);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: rank <= 3 ? rankBadge.color.withOpacity(0.35) : _borderColor,
          width: rank <= 3 ? 1.1 : 0.8,
        ),
      ),
      child: Row(
        children: [
          // Rank Indicator
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rankBadge.color.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: rankBadge.color.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: rankBadge.icon != null
                ? Icon(
                    rankBadge.icon,
                    color: rankBadge.color,
                    size: 16,
                  )
                : Text(
                    '$rank',
                    style: TextStyle(
                      color: rankBadge.color,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),

          const SizedBox(width: 12),

          // Avatar / Initials
          _buildAvatar(participant),

          const SizedBox(width: 12),

          // Customer Name & Rank Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.customerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rank <= 3 ? rankBadge.title : 'অংশগ্রহণকারী',
                  style: TextStyle(
                    color: rankBadge.color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Points Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: Color(0xFFF59E0B),
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatPoints(participant.currentPoints),
                  style: const TextStyle(
                    color: Color(0xFFFBBF24),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ChallengeParticipantModel participant) {
    final avatarUrl = participant.customerAvatar;
    if (avatarUrl != null &&
        avatarUrl.trim().isNotEmpty &&
        avatarUrl.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Image.network(
          avatarUrl,
          width: 38,
          height: 38,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitials(participant.customerName),
        ),
      );
    }
    return _buildInitials(participant.customerName);
  }

  Widget _buildInitials(String name) {
    final clean = name.trim();
    final initial = clean.isNotEmpty ? clean[0].toUpperCase() : 'C';
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF2E3033),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF4B5563), width: 0.8),
      ),
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  static String _formatPoints(num points) {
    if (points % 1 == 0) {
      final int intVal = points.toInt();
      return '$intVal পয়েন্ট';
    }
    return '${points.toStringAsFixed(1)} পয়েন্ট';
  }

  static _RankStyle _getRankBadge(int rank) {
    switch (rank) {
      case 1:
        return _RankStyle(
          color: const Color(0xFFFFD700), // Gold
          title: '🏆 ১ম স্থান',
          icon: Icons.emoji_events_rounded,
        );
      case 2:
        return _RankStyle(
          color: const Color(0xFFC0C0C0), // Silver
          title: '🥈 ২য় স্থান',
          icon: Icons.military_tech_rounded,
        );
      case 3:
        return _RankStyle(
          color: const Color(0xFFCD7F32), // Bronze
          title: '🥉 ৩য় স্থান',
          icon: Icons.military_tech_outlined,
        );
      default:
        return _RankStyle(
          color: const Color(0xFF9CA3AF), // Slate
          title: '#$rank',
          icon: null,
        );
    }
  }
}

class _RankStyle {
  final Color color;
  final String title;
  final IconData? icon;

  _RankStyle({
    required this.color,
    required this.title,
    this.icon,
  });
}
