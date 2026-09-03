import 'package:ecom_delivery_flutter/app/models/seller_store_model.dart';
import 'package:ecom_delivery_flutter/app/models/subscription_package_model.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_packages/repositories/seller_packages_repository.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerPackagesController extends GetxController
    with WidgetsBindingObserver {
  SellerPackagesController({required SellerPackagesRepository repository})
      : _repository = repository;

  final SellerPackagesRepository _repository;

  final stores = <SellerStoreModel>[].obs;
  final packages = <SubscriptionPackage>[].obs;
  final selectedStore = Rxn<SellerStoreModel>();
  final currentSubscription = Rxn<StoreSubscription>();
  final isLoading = false.obs;
  final isPackageLoading = false.obs;
  final isSubscriptionLoading = false.obs;
  final subscribingPackageId = Rxn<int>();
  final errorText = ''.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    loadInitialData();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && selectedStoreId.isNotEmpty) {
      fetchStoreSubscription();
    }
  }

  String get selectedStoreId => selectedStore.value?.id?.toString() ?? '';

  String get selectedStoreName =>
      selectedStore.value?.name.trim().isNotEmpty == true
          ? selectedStore.value!.name
          : 'MyZoo Store';

  bool get hasActiveSubscription =>
      currentSubscription.value?.isActive == true;

  SubscriptionPackage? get boughtPackage {
    final subscription = currentSubscription.value;
    if (subscription == null) return null;

    if (subscription.package != null) return subscription.package;

    for (final package in packages) {
      if (package.id != null &&
          package.id == subscription.subscriptionPackageId) {
        return package;
      }
    }

    return null;
  }

  List<SubscriptionPackage> get otherPackages {
    final currentPackageId = currentSubscription.value?.subscriptionPackageId;
    if (currentPackageId == null) return packages.toList();

    return packages.where((package) => package.id != currentPackageId).toList();
  }

  Future<void> loadInitialData() async {
    final auth = Get.find<AuthService>().currentUser.value;
    final userId = auth.data?.user?.id?.toString();
    final token = auth.data?.token;

    if (token == null || token.trim().isEmpty || userId == null) {
      _handleAuthExpired();
      return;
    }

    try {
      isLoading.value = true;
      errorText.value = '';

      await fetchSellerStores(userId);
      await fetchSellerProfilePackage(userId);
      await fetchSubscriptionPackages();

      if (selectedStoreId.isNotEmpty) {
        await fetchStoreSubscription();
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

  Future<void> fetchSellerStores(String userId) async {
    final response = await _repository.fetchSellerStores(userId: userId);
    if (!_handleApiError(response)) return;

    final parsedStores = _parseStores(response['body']);
    stores.assignAll(parsedStores);
    selectedStore.value = parsedStores.isNotEmpty ? parsedStores.first : null;
    currentSubscription.value = selectedStore.value?.package;
  }

  Future<void> fetchSellerProfilePackage(String userId) async {
    final response = await _repository.fetchSellerProfile(userId: userId);
    if (!_handleApiError(response, showSnackbar: false)) return;

    final body = _bodyMap(response['body']);
    final data = _bodyMap(body['data']);
    final shop = _bodyMap(data['shop']);
    if (shop.isEmpty) return;

    final profileStore = SellerStoreModel.fromJson(shop);
    final index = stores.indexWhere((store) => _sameId(store.id, profileStore.id));

    if (index >= 0) {
      stores[index] = profileStore;
    } else {
      stores.insert(0, profileStore);
    }

    if (profileStore.package != null) {
      selectedStore.value = index >= 0 ? stores[index] : profileStore;
      currentSubscription.value = profileStore.package;
    } else if (selectedStore.value == null) {
      selectedStore.value = index >= 0 ? stores[index] : profileStore;
    }
  }

  Future<void> fetchSubscriptionPackages() async {
    try {
      isPackageLoading.value = true;

      final response = await _repository.fetchSubscriptionPackages();
      if (!_handleApiError(response)) return;

      packages.assignAll(_parsePackages(response['body']));
    } catch (e) {
      Get.showSnackbar(
        Ui.ErrorSnackBar(message: e.toString(), title: 'Error'.tr),
      );
    } finally {
      isPackageLoading.value = false;
    }
  }

  Future<void> fetchStoreSubscription() async {
    if (selectedStoreId.isEmpty) return;

    try {
      isSubscriptionLoading.value = true;
      final fallbackSubscription = currentSubscription.value;

      final response = await _repository.fetchStoreSubscription(
        storeId: selectedStoreId,
      );

      if (!_handleApiError(response)) {
        currentSubscription.value = fallbackSubscription;
        return;
      }

      currentSubscription.value =
          _parseSubscription(response['body']) ?? fallbackSubscription;
    } catch (e) {
      Get.showSnackbar(
        Ui.ErrorSnackBar(message: e.toString(), title: 'Error'.tr),
      );
    } finally {
      isSubscriptionLoading.value = false;
    }
  }

  Future<void> selectStore(SellerStoreModel? store) async {
    selectedStore.value = store;
    currentSubscription.value = store?.package;

    if (selectedStoreId.isNotEmpty) {
      await fetchStoreSubscription();
    }
  }

  Future<void> subscribe(SubscriptionPackage package) async {
    if (selectedStoreId.isEmpty) {
      Get.showSnackbar(
        Ui.ErrorSnackBar(message: 'Please select a store first.'),
      );
      return;
    }

    final packageId = package.id;
    if (packageId == null) {
      Get.showSnackbar(
        Ui.ErrorSnackBar(message: 'Store or package not found.'),
      );
      return;
    }

    try {
      subscribingPackageId.value = packageId;

      final response = await _repository.subscribeToPackage(
        storeId: selectedStoreId,
        packageId: packageId,
        billingCycle: package.billingCycleText,
      );

      final body = response['data'];
      final paymentRequired = body['payment_required'];
      final paymentUrl = body['payment_url']?.toString();

      print("43726 $paymentRequired ------ $paymentUrl ");

      if (paymentRequired) {
        Get.toNamed(
          Routes.WEBVIEW,
          arguments: {
            'paymentURL': paymentUrl,
            'title': 'Subscription Payment',
          },
        );
        return;
      }

      Get.showSnackbar(
        Ui.SuccessSnackBar(
          message: body['message']?.toString() ??
              'Subscription activated successfully',
          title: 'Success'.tr,
        ),
      );
      await fetchStoreSubscription();
    } catch (e) {
      Get.showSnackbar(
        Ui.ErrorSnackBar(message: e.toString(), title: 'Error'.tr),
      );
    } finally {
      subscribingPackageId.value = null;
    }
  }

  bool isCurrentPackage(SubscriptionPackage package) {
    final currentPackageId = currentSubscription.value?.subscriptionPackageId;
    return currentPackageId != null && package.id == currentPackageId;
  }

  bool isSubscribing(SubscriptionPackage package) {
    return subscribingPackageId.value != null &&
        subscribingPackageId.value == package.id;
  }

  bool _handleApiError(
    Map<String, dynamic> response, {
    bool showSnackbar = true,
  }) {
    final statusCode = response['status_code'] as int? ?? 500;
    if (statusCode >= 200 && statusCode < 300) return true;

    final message = _messageForStatus(statusCode, response['body']);
    errorText.value = message;

    if (statusCode == 401) {
      _handleAuthExpired();
      return false;
    }

    if (showSnackbar) {
      Get.showSnackbar(Ui.ErrorSnackBar(message: message));
    }

    return false;
  }

  void _handleAuthExpired() {
    Get.showSnackbar(
      Ui.ErrorSnackBar(message: 'Seller auth token is required.'),
    );
    Get.offAllNamed(Routes.LOGIN);
  }

  String _messageForStatus(int statusCode, dynamic body) {
    if (statusCode == 403) return 'You do not have permission.';
    if (statusCode == 404) return 'Store or package not found.';
    if (statusCode == 422) return _validationMessage(body);
    if (statusCode >= 500) return 'Something went wrong. Please try again.';

    final map = _bodyMap(body);
    return map['message']?.toString() ?? 'Something went wrong. Please try again.';
  }

  String _validationMessage(dynamic body) {
    final map = _bodyMap(body);
    final errors = map['errors'];

    if (errors is Map) {
      final messages = <String>[];
      errors.forEach((_, value) {
        if (value is List) {
          messages.addAll(value.map((item) => item.toString()));
        } else if (value != null) {
          messages.add(value.toString());
        }
      });

      if (messages.isNotEmpty) return messages.join('\n');
    }

    return map['message']?.toString() ?? 'Please check your input.';
  }

  StoreSubscription? _parseSubscription(dynamic body) {
    final map = _bodyMap(body);
    final data = _bodyMap(map['data']);
    final subscription = _bodyMap(map['subscription']);

    if (data.isNotEmpty) {
      final dataSubscription = _bodyMap(data['subscription']);
      final dataShop = _bodyMap(data['shop']);
      final shopPackage = _bodyMap(dataShop['package']);

      if (dataSubscription.isNotEmpty) {
        return StoreSubscription.fromJson(dataSubscription);
      }
      if (shopPackage.isNotEmpty) {
        return StoreSubscription.fromJson(shopPackage);
      }
      if (_hasSubscriptionFields(data)) {
        return StoreSubscription.fromJson(data);
      }
    }

    if (subscription.isNotEmpty) {
      return StoreSubscription.fromJson(subscription);
    }

    if (map.isEmpty || !_hasSubscriptionFields(map)) return null;

    return StoreSubscription.fromJson(map);
  }

  bool _hasSubscriptionFields(Map<String, dynamic> map) {
    return map.containsKey('subscription_package_id') ||
        map.containsKey('package_id') ||
        map.containsKey('package_name') ||
        map.containsKey('subscription_package') ||
        map.containsKey('package') ||
        map.containsKey('plan');
  }
  List<SubscriptionPackage> _parsePackages(dynamic body) {
    final list = _findList(body);

    return list
        .whereType<Map>()
        .map((item) => SubscriptionPackage.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  List<SellerStoreModel> _parseStores(dynamic body) {
    final list = _findList(body);

    return list
        .whereType<Map>()
        .map((item) => SellerStoreModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .toList();
  }

  List<dynamic> _findList(dynamic value) {
    if (value is List) return value;

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);

      for (final key in ['data', 'packages', 'shops', 'stores', 'result']) {
        final child = map[key];
        if (child is List) return child;
        if (child is Map) {
          final nested = Map<String, dynamic>.from(child);
          for (final nestedKey in ['data', 'items', 'packages', 'shops']) {
            final nestedChild = nested[nestedKey];
            if (nestedChild is List) return nestedChild;
          }
        }
      }
    }

    return [];
  }

  Map<String, dynamic> _bodyMap(dynamic body) {
    if (body is Map) return Map<String, dynamic>.from(body);
    return {};
  }

  bool _sameId(dynamic first, dynamic second) {
    if (first == null || second == null) return false;
    return first.toString() == second.toString();
  }

  bool _toBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value == 1;

    final text = value?.toString().toLowerCase().trim();
    return text == '1' || text == 'true' || text == 'yes';
  }
}



