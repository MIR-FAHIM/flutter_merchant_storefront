import 'package:flutter/material.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  final String status;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _getStatusStyle(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: statusStyle.backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusStyle.borderColor,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusStyle.icon,
            size: isCompact ? 11 : 13,
            color: statusStyle.color,
          ),
          const SizedBox(width: 5),
          Text(
            _formatStatusText(status),
            style: TextStyle(
              color: statusStyle.color,
              fontSize: isCompact ? 10.5 : 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  static String _formatStatusText(String raw) {
    if (raw.trim().isEmpty) return 'N/A';
    final cleaned = raw.replaceAll('_', ' ').trim();
    return cleaned.substring(0, 1).toUpperCase() + cleaned.substring(1);
  }

  static _StatusStyle _getStatusStyle(String status) {
    final text = status.trim().toLowerCase();

    if (text == 'pending' || text == 'unpaid') {
      return const _StatusStyle(
        color: Color(0xFFF59E0B),
        backgroundColor: Color(0x26F59E0B),
        borderColor: Color(0x40F59E0B),
        icon: Icons.schedule_rounded,
      );
    } else if (text == 'confirmed' || text == 'accepted' || text == 'processing') {
      return const _StatusStyle(
        color: Color(0xFF3B82F6),
        backgroundColor: Color(0x263B82F6),
        borderColor: Color(0x403B82F6),
        icon: Icons.sync_rounded,
      );
    } else if (text == 'picked_up' || text == 'picked up' || text == 'on_the_way' || text == 'on the way' || text == 'shipped') {
      return const _StatusStyle(
        color: Color(0xFF06B6D4),
        backgroundColor: Color(0x2606B6D4),
        borderColor: Color(0x4006B6D4),
        icon: Icons.local_shipping_rounded,
      );
    } else if (text == 'completed' || text == 'delivered' || text == 'paid') {
      return const _StatusStyle(
        color: Color(0xFF10B981),
        backgroundColor: Color(0x2610B981),
        borderColor: Color(0x4010B981),
        icon: Icons.check_circle_rounded,
      );
    } else if (text == 'cancelled' || text == 'canceled' || text == 'failed') {
      return const _StatusStyle(
        color: Color(0xFFEF4444),
        backgroundColor: Color(0x26EF4444),
        borderColor: Color(0x40EF4444),
        icon: Icons.cancel_rounded,
      );
    } else if (text == 'refunded' || text == 'returned') {
      return const _StatusStyle(
        color: Color(0xFF8B5CF6),
        backgroundColor: Color(0x268B5CF6),
        borderColor: Color(0x408B5CF6),
        icon: Icons.replay_rounded,
      );
    }

    return const _StatusStyle(
      color: Color(0xFF9CA3AF),
      backgroundColor: Color(0x269CA3AF),
      borderColor: Color(0x409CA3AF),
      icon: Icons.info_outline_rounded,
    );
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
  });

  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
}
