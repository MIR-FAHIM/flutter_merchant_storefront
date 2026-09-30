import 'package:ecom_delivery_flutter/app/models/challenge/challenge_model.dart';
import 'package:ecom_delivery_flutter/app/modules/product/controller/product_controller.dart';
import 'package:ecom_delivery_flutter/app/repositories/challenge_repository.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ChallengeController extends GetxController {
  final ChallengeRepository _repository = ChallengeRepository();

  final RxList<ChallengeModel> challenges = <ChallengeModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  String get currentShopId {
    if (Get.isRegistered<ProductController>()) {
      final productCtrl = Get.find<ProductController>();
      if (productCtrl.selectedStoreId.value.isNotEmpty) {
        return productCtrl.selectedStoreId.value;
      }
      if (productCtrl.shopId.isNotEmpty) {
        return productCtrl.shopId;
      }
    }

    if (Get.isRegistered<AuthService>()) {
      final authUserShop = Get.find<AuthService>()
          .currentUser
          .value
          .data
          ?.user
          ?.shop
          ?.id
          ?.toString();
      if (authUserShop != null && authUserShop.isNotEmpty) {
        return authUserShop;
      }
    }

    final box = GetStorage();
    final saved = box.read('storeId') ??
        box.read('shopId') ??
        box.read('selected_store_id');
    if (saved != null && saved.toString().isNotEmpty) {
      return saved.toString();
    }

    return '2';
  }

  @override
  void onInit() {
    super.onInit();
    fetchChallenges();
  }

  Future<void> fetchChallenges({bool force = false}) async {
    if (isLoading.value && !force) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final response = await _repository.fetchChallenges(shopId: currentShopId);
      final parsed = ChallengeListResponse.fromJson(response);

      if (parsed.isSuccess) {
        challenges.assignAll(parsed.data);
      } else {
        challenges.clear();
        errorMessage.value = parsed.message ?? 'Failed to load challenges';
      }
    } catch (e) {
      challenges.clear();
      errorMessage.value = 'Failed to connect. Please check your internet.';
    } finally {
      isLoading.value = false;
    }
  }
}
