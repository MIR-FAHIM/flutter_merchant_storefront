import 'package:ecom_delivery_flutter/app/modules/challenge/controllers/challenge_controller.dart';
import 'package:ecom_delivery_flutter/app/repositories/challenge_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RewardFormItem {
  final TextEditingController pointsRequiredController;
  final RxString rewardType;
  final TextEditingController nameController;
  final TextEditingController rewardValueController;

  RewardFormItem({
    String points = '5000',
    String type = 'PRODUCT',
    String name = '',
    String value = '',
  })  : pointsRequiredController = TextEditingController(text: points),
        rewardType = type.obs,
        nameController = TextEditingController(text: name),
        rewardValueController = TextEditingController(text: value);

  void dispose() {
    pointsRequiredController.dispose();
    nameController.dispose();
    rewardValueController.dispose();
  }

  Map<String, dynamic> toJson() {
    final points = int.tryParse(pointsRequiredController.text.trim()) ?? 0;
    final val = rewardValueController.text.trim();
    return {
      'points_required': points,
      'reward_type': rewardType.value,
      'name': nameController.text.trim(),
      if (val.isNotEmpty) 'reward_value': val,
    };
  }
}

class CreateChallengeController extends GetxController {
  final ChallengeRepository _repository = ChallengeRepository();

  final formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController spendAmountController =
      TextEditingController(text: '100');
  final TextEditingController pointsAwardedController =
      TextEditingController(text: '5');

  final Rx<DateTime?> startDate = Rx<DateTime?>(null);
  final Rx<DateTime?> endDate = Rx<DateTime?>(null);

  final RxList<RewardFormItem> rewards = <RewardFormItem>[].obs;

  final RxBool isSubmitting = false.obs;
  final RxString errorMessage = ''.obs;

  static const List<String> availableRewardTypes = [
    'PRODUCT',
    'DISCOUNT',
    'VOUCHER',
    'FREE_DELIVERY',
    'CUSTOM',
  ];

  @override
  void onInit() {
    super.onInit();
    // Initialize with one default reward template
    addReward(
      points: '5000',
      type: 'PRODUCT',
      name: '',
      value: '',
    );
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    spendAmountController.dispose();
    pointsAwardedController.dispose();
    for (final item in rewards) {
      item.dispose();
    }
    super.onClose();
  }

  void addReward({
    String points = '1000',
    String type = 'DISCOUNT',
    String name = '',
    String value = '',
  }) {
    rewards.add(
      RewardFormItem(
        points: points,
        type: type,
        name: name,
        value: value,
      ),
    );
  }

  void removeReward(int index) {
    if (rewards.length <= 1) {
      Get.snackbar(
        'Reward Required',
        'At least one reward milestone is required for the challenge.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.9),
        colorText: Colors.white,
      );
      return;
    }
    final item = rewards.removeAt(index);
    item.dispose();
  }

  Future<void> pickDate(BuildContext context, bool isStart) async {
    final now = DateTime.now();
    final initialDate = isStart
        ? (startDate.value ?? now)
        : (endDate.value ?? (startDate.value ?? now).add(const Duration(days: 30)));

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(now) ? now : initialDate,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF34D399),
              onPrimary: Colors.black,
              surface: Color(0xFF1B1C1E),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF1B1C1E),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        startDate.value = picked;
        // If end date is before new start date, adjust it
        if (endDate.value != null && endDate.value!.isBefore(picked)) {
          endDate.value = picked.add(const Duration(days: 7));
        }
      } else {
        if (startDate.value != null && picked.isBefore(startDate.value!)) {
          Get.snackbar(
            'Invalid Date Range',
            'End date cannot be earlier than start date.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.redAccent.withOpacity(0.9),
            colorText: Colors.white,
          );
          return;
        }
        endDate.value = picked;
      }
    }
  }

  void clearDate(bool isStart) {
    if (isStart) {
      startDate.value = null;
    } else {
      endDate.value = null;
    }
  }

  Future<void> submitChallenge() async {
    if (isSubmitting.value) return;

    errorMessage.value = '';

    // Validate Title
    final title = titleController.text.trim();
    if (title.isEmpty) {
      errorMessage.value = 'Please enter a Challenge Title.';
      return;
    }

    // Validate Earning rule
    final spendAmount = double.tryParse(spendAmountController.text.trim());
    if (spendAmount == null || spendAmount <= 0) {
      errorMessage.value = 'Please specify a valid Spend Amount (e.g. 100).';
      return;
    }

    final pointsAwarded = int.tryParse(pointsAwardedController.text.trim());
    if (pointsAwarded == null || pointsAwarded <= 0) {
      errorMessage.value = 'Please specify valid Points Awarded (e.g. 5).';
      return;
    }

    // Validate Rewards
    if (rewards.isEmpty) {
      errorMessage.value = 'Please add at least one reward milestone.';
      return;
    }

    for (int i = 0; i < rewards.length; i++) {
      final r = rewards[i];
      final pts = int.tryParse(r.pointsRequiredController.text.trim());
      if (pts == null || pts <= 0) {
        errorMessage.value =
            'Reward #${i + 1}: Please enter valid Points Required (e.g. 5000).';
        return;
      }
      if (r.nameController.text.trim().isEmpty) {
        errorMessage.value = 'Reward #${i + 1}: Please enter a Reward Name.';
        return;
      }
    }

    // Get shop ID from parent controller or storage
    String shopId = '2';
    if (Get.isRegistered<ChallengeController>()) {
      shopId = Get.find<ChallengeController>().currentShopId;
    }

    final payload = {
      'shop_id': int.tryParse(shopId) ?? 2,
      'title': title,
      if (descriptionController.text.trim().isNotEmpty)
        'description': descriptionController.text.trim(),
      'spend_amount': spendAmount,
      'points_awarded': pointsAwarded,
      if (startDate.value != null)
        'start_date': _formatDateOnly(startDate.value!),
      if (endDate.value != null) 'end_date': _formatDateOnly(endDate.value!),
      'rewards': rewards.map((r) => r.toJson()).toList(),
    };

    isSubmitting.value = true;

    try {
      final response = await _repository.createChallenge(body: payload);
      final statusCode = response['status_code'] ?? 200;
      final body = response['body'];

      if ((statusCode == 200 || statusCode == 201) &&
          (body is Map &&
              (body['status'] == 'success' ||
                  body['status'] == true ||
                  body['data'] != null ||
                  statusCode == 201))) {
        Get.snackbar(
          'Challenge Created! 🎉',
          'Your store challenge has been published successfully.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Refresh challenges list
        if (Get.isRegistered<ChallengeController>()) {
          Get.find<ChallengeController>().fetchChallenges(force: true);
        }

        Get.back();
      } else {
        // Extract 422 or API validation errors
        String errorMsg = 'Failed to create challenge. Please try again.';
        if (body is Map) {
          if (body['errors'] is Map) {
            final Map errors = body['errors'];
            final List<String> errorLines = [];
            errors.forEach((key, val) {
              if (val is List) {
                errorLines.addAll(val.map((e) => e.toString()));
              } else {
                errorLines.add(val.toString());
              }
            });
            if (errorLines.isNotEmpty) {
              errorMsg = errorLines.join('\n');
            }
          } else if (body['message'] != null) {
            errorMsg = body['message'].toString();
          }
        }
        errorMessage.value = errorMsg;
      }
    } catch (e) {
      errorMessage.value = 'Failed to connect. Please check your network connection.';
    } finally {
      isSubmitting.value = false;
    }
  }

  String _formatDateOnly(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
