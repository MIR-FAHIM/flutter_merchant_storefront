import 'package:flutter/material.dart';

class ChallengeListResponse {
  final String? status;
  final String? message;
  final List<ChallengeModel> data;

  ChallengeListResponse({
    this.status,
    this.message,
    this.data = const [],
  });

  factory ChallengeListResponse.fromJson(dynamic json) {
    if (json is List) {
      return ChallengeListResponse(
        status: 'success',
        data: json
            .whereType<Map>()
            .map((item) =>
                ChallengeModel.fromJson(Map<String, dynamic>.from(item)))
            .toList(),
      );
    }

    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      final rawData = map['data'];
      List<ChallengeModel> items = [];

      if (rawData is List) {
        items = rawData
            .whereType<Map>()
            .map((item) =>
                ChallengeModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      } else if (rawData is Map && rawData['data'] is List) {
        // Handles paginated structure: data.data
        items = (rawData['data'] as List)
            .whereType<Map>()
            .map((item) =>
                ChallengeModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }

      return ChallengeListResponse(
        status: map['status']?.toString(),
        message: map['message']?.toString(),
        data: items,
      );
    }

    return ChallengeListResponse();
  }

  bool get isSuccess => status?.toLowerCase() == 'success';
}

class ChallengeModel {
  final int? id;
  final int? shopId;
  final String title;
  final String? description;
  final double? spendAmount;
  final int? pointsAwarded;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final int? targetPoints;
  final List<ChallengeRewardModel> rewards;
  final int? participantsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChallengeModel({
    this.id,
    this.shopId,
    required this.title,
    this.description,
    this.spendAmount,
    this.pointsAwarded,
    this.startDate,
    this.endDate,
    this.isActive = true,
    this.targetPoints,
    this.rewards = const [],
    this.participantsCount,
    this.createdAt,
    this.updatedAt,
  });

  ChallengeModel copyWith({
    int? id,
    int? shopId,
    String? title,
    String? description,
    double? spendAmount,
    int? pointsAwarded,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    int? targetPoints,
    List<ChallengeRewardModel>? rewards,
    int? participantsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChallengeModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      title: title ?? this.title,
      description: description ?? this.description,
      spendAmount: spendAmount ?? this.spendAmount,
      pointsAwarded: pointsAwarded ?? this.pointsAwarded,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      targetPoints: targetPoints ?? this.targetPoints,
      rewards: rewards ?? this.rewards,
      participantsCount: participantsCount ?? this.participantsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory ChallengeModel.fromJson(Map<String, dynamic> json) {
    List<ChallengeRewardModel> rewardsList = [];
    if (json['rewards'] is List) {
      rewardsList = (json['rewards'] as List)
          .whereType<Map>()
          .map((item) =>
              ChallengeRewardModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    // Resolve target points if provided directly or derive from highest reward
    int? resolvedTargetPoints = _toInt(json['target_points']);
    if (resolvedTargetPoints == null && rewardsList.isNotEmpty) {
      resolvedTargetPoints = rewardsList
          .map((r) => r.pointsRequired)
          .reduce((a, b) => a > b ? a : b);
    }

    return ChallengeModel(
      id: _toInt(json['id']),
      shopId: _toInt(json['shop_id']),
      title: json['title']?.toString() ?? 'Untitled Challenge',
      description: json['description']?.toString(),
      spendAmount: _toDouble(json['spend_amount']),
      pointsAwarded: _toInt(json['points_awarded']),
      startDate: _toDateTime(json['start_date']),
      endDate: _toDateTime(json['end_date']),
      isActive: _toBool(json['is_active']) ?? true,
      targetPoints: resolvedTargetPoints,
      rewards: rewardsList,
      participantsCount:
          _toInt(json['participants_count'] ?? json['total_participants']),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (shopId != null) 'shop_id': shopId,
      'title': title,
      if (description != null) 'description': description,
      'spend_amount': spendAmount,
      'points_awarded': pointsAwarded,
      if (startDate != null) 'start_date': _formatDateOnly(startDate!),
      if (endDate != null) 'end_date': _formatDateOnly(endDate!),
      'is_active': isActive ? 1 : 0,
      'rewards': rewards.map((r) => r.toJson()).toList(),
    };
  }

  String get statusBadgeText => isActive ? 'Active' : 'Inactive';
  String get statusBadgeTextBn => isActive ? 'চলমান (Active)' : 'বন্ধ আছে (Paused)';

  String get earningRuleText {
    final spend = spendAmount != null
        ? (spendAmount! % 1 == 0 ? spendAmount!.toInt() : spendAmount!)
        : 100;
    final points = pointsAwarded ?? 5;
    return '৳$spend spent = $points pts';
  }

  String get earningRuleTextBn {
    final spend = spendAmount != null
        ? (spendAmount! % 1 == 0 ? spendAmount!.toInt() : spendAmount!)
        : 100;
    final points = pointsAwarded ?? 5;
    return 'প্রতি ৳$spend কেনাকাটায় = $points পয়েন্ট';
  }

  String get dateRangeText {
    if (startDate == null && endDate == null) return 'No time limit';
    if (startDate != null && endDate != null) {
      return '${_formatDate(startDate!)} - ${_formatDate(endDate!)}';
    }
    if (startDate != null) return 'Starts ${_formatDate(startDate!)}';
    return 'Ends ${_formatDate(endDate!)}';
  }

  String get dateRangeTextBn {
    if (startDate == null && endDate == null) return 'কোনো সময়সীমা নেই';
    if (startDate != null && endDate != null) {
      return '${_formatDate(startDate!)} থেকে ${_formatDate(endDate!)}';
    }
    if (startDate != null) return 'শুরু: ${_formatDate(startDate!)}';
    return 'শেষ: ${_formatDate(endDate!)}';
  }

  int get maxMilestonePoints {
    if (targetPoints != null && targetPoints! > 0) return targetPoints!;
    if (rewards.isNotEmpty) {
      return rewards
          .map((r) => r.pointsRequired)
          .reduce((a, b) => a > b ? a : b);
    }
    return 0;
  }

  String get primaryRewardTitle {
    if (rewards.isEmpty) return 'No rewards added';
    if (rewards.length == 1) return rewards.first.name;
    return '${rewards.first.name} (+${rewards.length - 1} more)';
  }

  String get primaryRewardTitleBn {
    if (rewards.isEmpty) return 'কোনো গিফট যোগ করা হয়নি';
    if (rewards.length == 1) return rewards.first.name;
    return '${rewards.first.name} (+আরও ${rewards.length - 1}টি)';
  }
}

class ChallengeRewardModel {
  final int? id;
  final int? challengeId;
  final int pointsRequired;
  final String rewardType;
  final String name;
  final String? rewardValue;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChallengeRewardModel({
    this.id,
    this.challengeId,
    required this.pointsRequired,
    required this.rewardType,
    required this.name,
    this.rewardValue,
    this.createdAt,
    this.updatedAt,
  });

  factory ChallengeRewardModel.fromJson(Map<String, dynamic> json) {
    return ChallengeRewardModel(
      id: _toInt(json['id']),
      challengeId: _toInt(json['challenge_id']),
      pointsRequired: _toInt(json['points_required']) ?? 0,
      rewardType: (json['reward_type']?.toString().toUpperCase()) ?? 'CUSTOM',
      name: json['name']?.toString() ?? 'Reward',
      rewardValue: json['reward_value']?.toString(),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (challengeId != null) 'challenge_id': challengeId,
      'points_required': pointsRequired,
      'reward_type': rewardType,
      'name': name,
      if (rewardValue != null && rewardValue!.trim().isNotEmpty)
        'reward_value': rewardValue!.trim(),
    };
  }

  String get rewardTypeLabel {
    switch (rewardType.toUpperCase()) {
      case 'PRODUCT':
        return 'Free Product';
      case 'DISCOUNT':
        return 'Discount';
      case 'VOUCHER':
        return 'Gift Voucher';
      case 'FREE_DELIVERY':
        return 'Free Delivery';
      case 'CUSTOM':
      default:
        return 'Special Gift';
    }
  }

  String get rewardTypeLabelBn {
    switch (rewardType.toUpperCase()) {
      case 'PRODUCT':
        return '🎁 ফ্রি প্রোডাক্ট';
      case 'DISCOUNT':
        return '🏷️ স্পেশাল ডিসকাউন্ট';
      case 'VOUCHER':
        return '🎟️ ভাউচার';
      case 'FREE_DELIVERY':
        return '🚚 ফ্রি ডেলিভারি';
      case 'CUSTOM':
      default:
        return '⭐ বিশেষ উপহার';
    }
  }

  IconData get rewardTypeIcon {
    switch (rewardType.toUpperCase()) {
      case 'PRODUCT':
        return Icons.shopping_bag_outlined;
      case 'DISCOUNT':
        return Icons.discount_outlined;
      case 'VOUCHER':
        return Icons.confirmation_number_outlined;
      case 'FREE_DELIVERY':
        return Icons.local_shipping_outlined;
      case 'CUSTOM':
      default:
        return Icons.card_giftcard_rounded;
    }
  }

  Color get rewardTypeColor {
    switch (rewardType.toUpperCase()) {
      case 'PRODUCT':
        return const Color(0xFF60A5FA);
      case 'DISCOUNT':
        return const Color(0xFFEF4444);
      case 'VOUCHER':
        return const Color(0xFFF59E0B);
      case 'FREE_DELIVERY':
        return const Color(0xFF10B981);
      case 'CUSTOM':
      default:
        return const Color(0xFF8B5CF6);
    }
  }
}

class ChallengeStatsResponse {
  final String? status;
  final String? message;
  final ChallengeStatsModel? data;

  ChallengeStatsResponse({
    this.status,
    this.message,
    this.data,
  });

  factory ChallengeStatsResponse.fromJson(Map<String, dynamic> json) {
    dynamic statsMap = json['data'] ?? json;
    if (statsMap is! Map<String, dynamic>) {
      statsMap = Map<String, dynamic>.from(statsMap is Map ? statsMap : {});
    }

    return ChallengeStatsResponse(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: ChallengeStatsModel.fromJson(statsMap),
    );
  }
}

class ChallengeStatsModel {
  final int totalParticipants;
  final num totalPointsIssued;
  final int rewardsUnlocked;
  final int rewardsClaimed;
  final int rewardsRedeemed;

  ChallengeStatsModel({
    this.totalParticipants = 0,
    this.totalPointsIssued = 0,
    this.rewardsUnlocked = 0,
    this.rewardsClaimed = 0,
    this.rewardsRedeemed = 0,
  });

  factory ChallengeStatsModel.fromJson(Map<String, dynamic> json) {
    return ChallengeStatsModel(
      totalParticipants: _toInt(
            json['total_participants'] ??
                json['participants_count'] ??
                json['totalParticipants'],
          ) ??
          0,
      totalPointsIssued: _toDouble(
            json['total_points_issued'] ??
                json['points_issued'] ??
                json['totalPointsIssued'],
          ) ??
          0,
      rewardsUnlocked: _toInt(
            json['rewards_unlocked'] ??
                json['unlocked_rewards'] ??
                json['rewardsUnlocked'],
          ) ??
          0,
      rewardsClaimed: _toInt(
            json['rewards_claimed'] ??
                json['claimed_rewards'] ??
                json['rewardsClaimed'],
          ) ??
          0,
      rewardsRedeemed: _toInt(
            json['rewards_redeemed'] ??
                json['redeemed_rewards'] ??
                json['rewardsRedeemed'],
          ) ??
          0,
    );
  }
}

class ChallengeParticipantsResponse {
  final String? status;
  final String? message;
  final List<ChallengeParticipantModel> data;
  final int currentPage;
  final int lastPage;
  final int total;

  ChallengeParticipantsResponse({
    this.status,
    this.message,
    this.data = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });

  factory ChallengeParticipantsResponse.fromJson(dynamic json) {
    if (json is List) {
      return ChallengeParticipantsResponse(
        status: 'success',
        data: json
            .whereType<Map>()
            .map((item) => ChallengeParticipantModel.fromJson(
                Map<String, dynamic>.from(item)))
            .toList(),
        currentPage: 1,
        lastPage: 1,
        total: json.length,
      );
    }

    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      final rawData = map['data'];

      List<ChallengeParticipantModel> participants = [];
      int current = 1;
      int last = 1;
      int totalItems = 0;

      if (rawData is List) {
        participants = rawData
            .whereType<Map>()
            .map((item) => ChallengeParticipantModel.fromJson(
                Map<String, dynamic>.from(item)))
            .toList();
        totalItems = participants.length;
      } else if (rawData is Map) {
        final list = rawData['data'];
        if (list is List) {
          participants = list
              .whereType<Map>()
              .map((item) => ChallengeParticipantModel.fromJson(
                  Map<String, dynamic>.from(item)))
              .toList();
        }
        current = _toInt(rawData['current_page']) ?? 1;
        last = _toInt(rawData['last_page']) ?? 1;
        totalItems = _toInt(rawData['total']) ?? participants.length;
      }

      return ChallengeParticipantsResponse(
        status: map['status']?.toString(),
        message: map['message']?.toString(),
        data: participants,
        currentPage: current,
        lastPage: last,
        total: totalItems,
      );
    }

    return ChallengeParticipantsResponse();
  }
}

class ChallengeParticipantModel {
  final int? id;
  final int? userId;
  final String customerName;
  final String? customerAvatar;
  final num currentPoints;
  final int? rank;
  final DateTime? completedAt;

  ChallengeParticipantModel({
    this.id,
    this.userId,
    required this.customerName,
    this.customerAvatar,
    this.currentPoints = 0,
    this.rank,
    this.completedAt,
  });

  factory ChallengeParticipantModel.fromJson(Map<String, dynamic> json) {
    // Extract customer name from various backend variations
    String name = 'Customer';
    String? avatar;

    if (json['customer_name'] != null) {
      name = json['customer_name'].toString();
    } else if (json['name'] != null) {
      name = json['name'].toString();
    } else if (json['user'] is Map) {
      final user = Map<String, dynamic>.from(json['user']);
      name = user['name']?.toString() ?? 'Customer';
      avatar = user['avatar']?.toString() ?? user['profile_image']?.toString();
    } else if (json['customer'] is Map) {
      final cust = Map<String, dynamic>.from(json['customer']);
      name = cust['name']?.toString() ?? 'Customer';
      avatar = cust['avatar']?.toString() ?? cust['image']?.toString();
    }

    avatar ??= json['customer_avatar']?.toString() ??
        json['avatar']?.toString() ??
        json['profile_image']?.toString();

    return ChallengeParticipantModel(
      id: _toInt(json['id']),
      userId: _toInt(json['user_id'] ?? json['customer_id']),
      customerName: name,
      customerAvatar: avatar,
      currentPoints: _toDouble(json['current_points'] ?? json['points']) ?? 0,
      rank: _toInt(json['rank']),
      completedAt: _toDateTime(json['completed_at'] ?? json['created_at']),
    );
  }
}

// Helpers
int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

bool? _toBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 1;
  final text = value.toString().toLowerCase().trim();
  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;
  return null;
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}

String _formatDate(DateTime dt) {
  final localDate = dt.toLocal();
  final months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  return '${localDate.day} ${months[localDate.month - 1]} ${localDate.year}';
}

String _formatDateOnly(DateTime dt) {
  final y = dt.year.toString().padLeft(4, '0');
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
