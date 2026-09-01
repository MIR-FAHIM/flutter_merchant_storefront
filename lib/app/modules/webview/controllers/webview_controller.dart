import 'package:ecom_delivery_flutter/app/modules/seller_packages/views/subscription_success_view.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class WebviewController extends GetxController {
  late InAppWebViewController inAppWebViewController;
  final paymentUrl = ''.obs;
  final title = ''.obs;
  final progress = 0.0.obs;
  final isLoaded = false.obs;
  final hasDetectedSuccess = false.obs;

  @override
  void onInit() {
    final arguments = Get.arguments is Map ? Get.arguments as Map : {};
    paymentUrl.value = arguments['paymentURL']?.toString() ?? '';
    title.value = arguments['title']?.toString() ?? 'Payment';
    super.onInit();
  }

  Future<void> handleVisitedUrl(String? url) async {
    if (url == null || hasDetectedSuccess.value) return;

    final normalized = url.toLowerCase();
    final hasSuccessMarker = _successMarkers.any(normalized.contains);

    if (hasSuccessMarker) {
      hasDetectedSuccess.value = true;
      Get.off(() => const SubscriptionSuccessView());
    }
  }

  Future<bool> handleBack() async {
    if (await inAppWebViewController.canGoBack()) {
      await inAppWebViewController.goBack();
      return false;
    }
    return true;
  }

  void setWebViewController(InAppWebViewController controller) {
    inAppWebViewController = controller;
  }

  static const List<String> _successMarkers = [
    'success',
    'successful',
    'payment_success',
    'paid',
    'completed',
    'status=success',
    'status=completed',
    'txn_status=success',
  ];
}

