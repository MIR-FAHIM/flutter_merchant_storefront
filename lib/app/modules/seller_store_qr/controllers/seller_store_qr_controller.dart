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
  final storeQrBytes = Rxn<Uint8List>();
  final isLoading = false.obs;
  final isLoadingQrImage = false.obs;
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
  String get selectedStoreCode => selectedStore.value?.code?.trim() ?? '';

  int get selectedStoreId => selectedStore.value?.id ?? 0;

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

      if (selectedStore.value != null) {
        await fetchStoreQrImage();
      }
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
    storeQrBytes.value = null;
    if (store != null) {
      fetchStoreQrImage();
    }
  }

  Future<void> fetchStoreQrImage() async {
    if (selectedStoreId <= 0) return;

    final token = Get.find<AuthService>().currentUser.value.data?.token;
    if (token == null || token.trim().isEmpty) return;

    try {
      isLoadingQrImage.value = true;
      final bytes = await _repository.fetchStoreQrImage(
        storeId: selectedStoreId.toString(),
        token: token,
      );
      if (bytes != null && bytes.isNotEmpty) {
        storeQrBytes.value = bytes;
      }
    } catch (e) {
      debugPrint('fetchStoreQrImage error: $e');
    } finally {
      isLoadingQrImage.value = false;
    }
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

  void scanStoreQr() {
    final TextEditingController scanInputController = TextEditingController();

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF1B1C1E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF064E3B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Color(0xFF34D399),
                  size: 36,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Scan or Lookup Store QR',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter or scan Store Code/URL to open store profile.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12.5),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: scanInputController,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Enter Store URL or Store ID...',
                  hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF141517),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF2E3033)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF34D399), width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel', style: TextStyle(color: Color(0xFF9CA3AF))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF34D399),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final input = scanInputController.text.trim();
                        Get.back();
                        if (input.isNotEmpty) {
                          final String targetUrl = input.startsWith('http')
                              ? input
                              : '$publicStoreBaseUrl/$input';
                          launchUrl(Uri.parse(targetUrl), mode: LaunchMode.externalApplication);
                        }
                      },
                      child: const Text('Open Store', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
          GetSnackBar(
            titleText: Text(
              'QR Frame Downloaded'.tr,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            messageText: Text(
              'Saved to: ${file.path}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            duration: const Duration(seconds: 6),
            mainButton: TextButton.icon(
              onPressed: () {
                Get.back();
                SharePlus.instance.share(
                  ShareParams(
                    text: 'Shop from $selectedStoreName: $publicStoreUrl',
                    subject: '$selectedStoreName Store QR',
                    files: [XFile(file.path)],
                  ),
                );
              },
              icon: const Icon(Icons.share_rounded, size: 16, color: Color(0xFF34D399)),
              label: const Text(
                'SHARE / SAVE',
                style: TextStyle(color: Color(0xFF34D399), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            backgroundColor: const Color(0xFF1B1C1E),
            borderColor: const Color(0xFF34D399),
            borderRadius: 12,
            margin: const EdgeInsets.all(12),
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
      if (Platform.isAndroid) {
        final publicDownloadDir = Directory('/storage/emulated/0/Download');
        if (await publicDownloadDir.exists()) {
          return publicDownloadDir;
        }
      }
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
