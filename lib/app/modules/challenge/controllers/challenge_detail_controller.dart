import 'dart:ui';

import 'package:ecom_delivery_flutter/app/models/challenge/challenge_model.dart';
import 'package:ecom_delivery_flutter/app/repositories/challenge_repository.dart';
import 'package:get/get.dart';

class ChallengeDetailController extends GetxController {
  final ChallengeRepository _repository = ChallengeRepository();

  final Rx<ChallengeModel?> challenge = Rx<ChallengeModel?>(null);

  // Statistics State
  final Rx<ChallengeStatsModel?> stats = Rx<ChallengeStatsModel?>(null);
  final RxBool isStatsLoading = false.obs;
  final RxString statsError = ''.obs;

  // Leaderboard / Participants State
  final RxList<ChallengeParticipantModel> participants =
      <ChallengeParticipantModel>[].obs;
  final RxBool isParticipantsLoading = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxString participantsError = ''.obs;

  int currentPage = 1;
  int lastPage = 1;
  bool get hasMore => currentPage < lastPage;

  dynamic get challengeId => challenge.value?.id ?? Get.arguments?['id'];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ChallengeModel) {
      challenge.value = args;
    } else if (args is Map && args['challenge'] is ChallengeModel) {
      challenge.value = args['challenge'];
    }

    refreshAll();
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadStatistics(),
      loadParticipants(refresh: true),
    ]);
  }

  Future<void> loadStatistics() async {
    final id = challengeId;
    if (id == null) return;

    isStatsLoading.value = true;
    statsError.value = '';

    try {
      final response = await _repository.fetchStatistics(challengeId: id);
      final statusCode = response['status_code'] ?? 200;
      final body = response['body'];

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = ChallengeStatsResponse.fromJson(body);
        stats.value = parsed.data ?? ChallengeStatsModel();
      } else {
        statsError.value = 'পরিসংখ্যান লোড করতে ব্যর্থ হয়েছে';
      }
    } catch (e) {
      statsError.value = 'পরিসংখ্যান লোড করতে ব্যর্থ হয়েছে';
    } finally {
      isStatsLoading.value = false;
    }
  }

  Future<void> loadParticipants({bool refresh = false}) async {
    final id = challengeId;
    if (id == null) return;

    if (refresh) {
      currentPage = 1;
      hasMore;
    }

    if (currentPage == 1) {
      isParticipantsLoading.value = true;
    } else {
      isMoreLoading.value = true;
    }
    participantsError.value = '';

    try {
      final response = await _repository.fetchParticipants(
        challengeId: id,
        page: currentPage,
        perPage: 20,
      );
      final statusCode = response['status_code'] ?? 200;
      final body = response['body'];

      if (statusCode >= 200 && statusCode < 300 && body != null) {
        final parsed = ChallengeParticipantsResponse.fromJson(body);
        lastPage = parsed.lastPage;

        if (refresh || currentPage == 1) {
          participants.assignAll(parsed.data);
        } else {
          participants.addAll(parsed.data);
        }
      } else {
        if (currentPage == 1) {
          participantsError.value = 'অংশগ্রহণকারীদের তালিকা লোড করতে ব্যর্থ হয়েছে';
        }
      }
    } catch (e) {
      if (currentPage == 1) {
        participantsError.value = 'অংশগ্রহণকারীদের তালিকা লোড করতে ব্যর্থ হয়েছে';
      }
    } finally {
      isParticipantsLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> loadMoreParticipants() async {
    if (isMoreLoading.value || isParticipantsLoading.value || !hasMore) return;
    currentPage++;
    await loadParticipants(refresh: false);
  }

  Future<void> deleteChallenge() async {
    final id = challengeId;
    if (id == null) return;

    try {
      final response = await _repository.deleteChallenge(challengeId: id);
      final statusCode = response['status_code'] ?? 200;
      
      if (statusCode >= 200 && statusCode < 300) {
        Get.back(result: true);
        Get.snackbar(
          'সফল',
          'চ্যালেঞ্জ সফলভাবে মুছে ফেলা হয়েছে',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF34D399).withOpacity(0.9),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        final body = response['body'];
        final message = body?['message'] ?? 'চ্যালেঞ্জ মুছতে সমস্যা হয়েছে';
        Get.snackbar(
          'ত্রুটি',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.9),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      Get.snackbar(
        'ত্রুটি',
        'একটি সমস্যা দেখা দিয়েছে: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withOpacity(0.9),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  Future<void> toggleStatus(bool isActive) async {
    final id = challengeId;
    if (id == null) return;

    try {
      final response = await _repository.toggleChallengeStatus(
        challengeId: id,
        isActive: isActive,
      );
      final statusCode = response['status_code'] ?? 200;
      
      if (statusCode >= 200 && statusCode < 300) {
        // update local model
        final currentModel = challenge.value;
        if (currentModel != null) {
          challenge.value = currentModel.copyWith(isActive: isActive);
        }
        
        Get.snackbar(
          'সফল',
          isActive
              ? 'চ্যালেঞ্জ সফলভাবে চালু করা হয়েছে'
              : 'চ্যালেঞ্জ সাময়িক বন্ধ (Pause) করা হয়েছে',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF34D399).withOpacity(0.9),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        final body = response['body'];
        final message = body?['message'] ?? 'স্ট্যাটাস আপডেট করতে সমস্যা হয়েছে';
        Get.snackbar(
          'ত্রুটি',
          message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFEF4444).withOpacity(0.9),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } catch (e) {
      Get.snackbar(
        'ত্রুটি',
        'একটি সমস্যা দেখা দিয়েছে: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444).withOpacity(0.9),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }
}
