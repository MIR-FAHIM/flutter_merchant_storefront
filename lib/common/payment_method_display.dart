import 'package:get/get.dart';

String paymentMethodLabel(String? method) {
  switch (method?.trim().toLowerCase()) {
    case 'cash':
    case 'cod':
      return 'paymentDisplay.cash'.tr;
    case 'aamarpay':
      return 'paymentDisplay.online'.tr;
    case 'bkash':
    case 'nagad':
    case 'card':
    case 'bank':
      return 'paymentDisplay.digital'.tr;
    case 'baki':
      return 'paymentDisplay.baki'.tr;
    default:
      return method?.trim().isNotEmpty == true
          ? method!.trim().toUpperCase()
          : 'N/A';
  }
}
