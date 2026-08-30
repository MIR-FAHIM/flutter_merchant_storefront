import 'dart:io';
import 'dart:ui' as ui;

import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';
import 'package:ecom_delivery_flutter/app/models/seller_store_model.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_store_qr/repositories/seller_store_qr_repository.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerStoreQrController extends GetxController {
  SellerStoreQrController({required SellerStoreQrRepository repository})
      : _repository = repository;

  final SellerStoreQrRepository _repository;

  final stores = <SellerStoreModel>[].obs;
  final selectedStore = Rxn<SellerStoreModel>();
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorText = ''.obs;

  final GlobalKey posterKey = GlobalKey();

  static const String publicStoreBaseUrl = CompanyData.publicStoreBaseUrl;

  @override
  void onInit() {
    super.onInit();
    loadSellerStores();
  }

  String get selectedStoreName =>
      selectedStore.value?.name.trim().isNotEmpty == true
          ? selectedStore.value!.name
          : 'MyZoo Store';

  String get selectedStoreSlug => selectedStore.value?.slug?.trim() ?? '';

  bool get hasSelectedStore => selectedStore.value != null;

  bool get selectedStoreHasSlug => selectedStoreSlug.isNotEmpty;

  String get publicStoreUrl => selectedStoreHasSlug
      ? '$publicStoreBaseUrl/$selectedStoreSlug'
      : '';

  Future<void> loadSellerStores() async {
    final auth = Get.find<AuthService>().currentUser.value;
    final userId = auth.data?.user?.id?.toString();
    final token = auth.data?.token;

    if (token == null || token.trim().isEmpty || userId == null) {
      errorText.value = 'Seller auth token is required for loading stores.';
      return;
    }

    try {
      isLoading.value = true;
      errorText.value = '';

      final response = await _repository.getSellerStores(userId: userId);
      final parsedStores = _parseStores(response);

      stores.assignAll(parsedStores);
      selectedStore.value = parsedStores.isNotEmpty ? parsedStores.first : null;
    } catch (e) {
      errorText.value = e.toString();
      Get.showSnackbar(
        Ui.ErrorSnackBar(message: errorText.value, title: 'Error'.tr),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectStore(SellerStoreModel? store) {
    selectedStore.value = store;
  }

  Future<void> copyStoreUrl() async {
    if (!_ensureStoreUrl()) return;

    await Clipboard.setData(ClipboardData(text: publicStoreUrl));
    Get.showSnackbar(
      Ui.SuccessSnackBar(message: 'Store URL copied', title: 'Success'.tr),
    );
  }

  Future<void> openPublicStore() async {
    if (!_ensureStoreUrl()) return;

    final uri = Uri.parse(publicStoreUrl);
    final opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened) {
      Get.showSnackbar(
        Ui.ErrorSnackBar(message: 'Could not open public store URL'),
      );
    }
  }

  Future<void> shareQrOrUrl() async {
    if (!_ensureStoreUrl()) return;

    final file = await _capturePosterFile(showSuccess: false);

    if (file != null) {
      await SharePlus.instance.share(
        ShareParams(
          text: 'Shop from $selectedStoreName: $publicStoreUrl',
          subject: '$selectedStoreName Store QR',
          files: [XFile(file.path)],
        ),
      );
      return;
    }

    await SharePlus.instance.share(
      ShareParams(
        text: 'Shop from $selectedStoreName: $publicStoreUrl',
        subject: '$selectedStoreName Store QR',
      ),
    );
  }

  Future<void> downloadQrFrame() async {
    if (!_ensureStoreUrl()) return;

    await _capturePosterFile(showSuccess: true);
  }

  bool _ensureStoreUrl() {
    if (!hasSelectedStore) {
      Get.showSnackbar(
        Ui.ErrorSnackBar(message: 'No store found for this seller account.'),
      );
      return false;
    }

    if (!selectedStoreHasSlug) {
      Get.showSnackbar(
        Ui.ErrorSnackBar(
          message:
              'This store does not have a public slug yet. Please update the store profile first.',
        ),
      );
      return false;
    }

    return true;
  }

  Future<File?> _capturePosterFile({required bool showSuccess}) async {
    try {
      isSaving.value = true;

      final boundary =
          posterKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('QR frame is not ready yet.');
      }

      final width = boundary.size.width;
      final pixelRatio = width <= 0 ? 3.0 : 1080 / width;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();

      if (bytes == null) {
        throw Exception('Could not render QR frame.');
      }

      final directory = await _downloadDirectory();
      final safeSlug = selectedStoreSlug.replaceAll(
        RegExp(r'[^a-zA-Z0-9_-]'),
        '-',
      );
      final file = File('${directory.path}/$safeSlug-qr.png');

      await file.writeAsBytes(bytes, flush: true);

      if (showSuccess) {
        Get.showSnackbar(
          Ui.SuccessSnackBar(
            message: 'QR frame downloaded: ${file.path}',
            title: 'Success'.tr,
          ),
        );
      }

      return file;
    } catch (e) {
      Get.showSnackbar(
        Ui.ErrorSnackBar(message: e.toString(), title: 'Error'.tr),
      );
      return null;
    } finally {
      isSaving.value = false;
    }
  }

  Future<Directory> _downloadDirectory() async {
    try {
      return await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
    } catch (_) {
      return getApplicationDocumentsDirectory();
    }
  }

  List<SellerStoreModel> _parseStores(dynamic response) {
    final list = _findStoreList(response);

    return list
        .whereType<Map>()
        .map((item) => SellerStoreModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  List<dynamic> _findStoreList(dynamic value) {
    if (value is List) return value;

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);

      for (final key in ['data', 'shops', 'stores', 'result']) {
        final child = map[key];
        if (child is List) return child;
        if (child is Map) {
          final nested = Map<String, dynamic>.from(child);
          for (final nestedKey in ['data', 'shops', 'stores', 'items']) {
            final nestedChild = nested[nestedKey];
            if (nestedChild is List) return nestedChild;
          }
        }
      }
    }

    return [];
  }
}
