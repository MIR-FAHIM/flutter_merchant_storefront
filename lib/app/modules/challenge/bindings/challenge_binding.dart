import 'package:ecom_delivery_flutter/app/modules/challenge/controllers/challenge_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/challenge/controllers/challenge_detail_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/challenge/controllers/create_challenge_controller.dart';
import 'package:get/get.dart';

class ChallengeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChallengeController>(() => ChallengeController());
    Get.lazyPut<CreateChallengeController>(() => CreateChallengeController(),
        fenix: true);
    Get.lazyPut<ChallengeDetailController>(() => ChallengeDetailController(),
        fenix: true);
  }
}
