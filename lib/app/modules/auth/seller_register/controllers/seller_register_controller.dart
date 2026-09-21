import 'package:ecom_delivery_flutter/app/models/auth/customer_model.dart';
import 'package:ecom_delivery_flutter/app/models/auth/seller_register_response_model.dart';
import 'package:ecom_delivery_flutter/app/models/location_model.dart';
import 'package:ecom_delivery_flutter/app/modules/auth/seller_register/repositories/seller_register_repository.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:ecom_delivery_flutter/app/services/location_service.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SellerRegisterController extends GetxController {
  SellerRegisterController({SellerRegisterRepository? repository})
      : _repository = repository ?? SellerRegisterRepository();

  final SellerRegisterRepository _repository;
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final shopNameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final countryController = TextEditingController(text: 'Bangladesh');
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final areaController = TextEditingController();
  final addressController = TextEditingController();
  final postalCodeController = TextEditingController();
  final referralCodeController = TextEditingController();

  final hidePassword = true.obs;
  final hideConfirmPassword = true.obs;
  final acceptedTerms = false.obs;
  final isSubmitting = false.obs;
  final fieldErrors = <String, String>{}.obs;

  // Location observables
  final divisions = <DivisionModel>[].obs;
  final districts = <DistrictModel>[].obs;
  final upazilas = <UpazilaModel>[].obs;

  final isLoadingDivisions = false.obs;
  final isLoadingDistricts = false.obs;
  final isLoadingUpazilas = false.obs;

  final selectedDivision = Rxn<DivisionModel>();
  final selectedDistrict = Rxn<DistrictModel>();
  final selectedUpazila = Rxn<UpazilaModel>();



  @override
  void onInit() {
    super.onInit();
    fetchDivisions();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      if (Get.isRegistered<LocationService>()) {
        final locService = Get.find<LocationService>();
        if (locService.currentLocation['lat'] == null) {
          await locService.determinePosition();
        }
      }
    } catch (e) {
      print('Location determine error on init: $e');
    }
  }

  Future<void> fetchDivisions() async {
    isLoadingDivisions.value = true;
    try {
      final list = await _repository.getDivisions();
      divisions.assignAll(list);
    } catch (e) {
      print('Error fetching divisions: $e');
    } finally {
      isLoadingDivisions.value = false;
    }
  }

  Future<void> selectDivision(DivisionModel? division) async {
    selectedDivision.value = division;
    clearFieldError('division_id');

    // Reset District & Upazila values
    selectedDistrict.value = null;
    selectedUpazila.value = null;
    districts.clear();
    upazilas.clear();
    clearFieldError('district_id');
    clearFieldError('upazila_id');

    if (division != null) {
      stateController.text = division.name;
      isLoadingDistricts.value = true;
      try {
        final list = await _repository.getDistricts(division.id);
        districts.assignAll(list);
      } catch (e) {
        print('Error fetching districts: $e');
      } finally {
        isLoadingDistricts.value = false;
      }
    } else {
      stateController.clear();
    }
  }

  Future<void> selectDistrict(DistrictModel? district) async {
    selectedDistrict.value = district;
    clearFieldError('district_id');

    // Reset Upazila value
    selectedUpazila.value = null;
    upazilas.clear();
    clearFieldError('upazila_id');

    if (district != null) {
      cityController.text = district.name;
      if (Get.isRegistered<LocationService>()) {
        final loc = Get.find<LocationService>().currentLocation;
        if (loc['lat'] == null && district.numericLat != null) {
          loc.addAll({
            'lat': district.numericLat,
            'lng': district.numericLon,
            'lon': district.numericLon,
            'city': district.name,
          });
        }
      }

      isLoadingUpazilas.value = true;
      try {
        final list = await _repository.getUpazilas(district.id);
        upazilas.assignAll(list);
      } catch (e) {
        print('Error fetching upazilas: $e');
      } finally {
        isLoadingUpazilas.value = false;
      }
    } else {
      cityController.clear();
    }
  }

  void selectUpazila(UpazilaModel? upazila) {
    selectedUpazila.value = upazila;
    clearFieldError('upazila_id');
    if (upazila != null) {
      areaController.text = upazila.name;
    } else {
      areaController.clear();
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    shopNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    areaController.dispose();
    addressController.dispose();
    postalCodeController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    fieldErrors.clear();
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!acceptedTerms.value) {
      fieldErrors['terms'] = 'sellerRegister.termsRequired'.tr;
      return;
    }

    isSubmitting.value = true;
    try {
      // Resolve lat and lon safely from LocationService or District
      num? lat;
      num? lon;

      if (Get.isRegistered<LocationService>()) {
        final locService = Get.find<LocationService>();
        var loc = locService.currentLocation;

        if (loc['lat'] == null) {
          try {
            await locService.determinePosition();
            loc = locService.currentLocation;
          } catch (_) {}
        }

        if (loc['lat'] != null) {
          lat = loc['lat'] is num
              ? loc['lat'] as num
              : double.tryParse(loc['lat'].toString());
        }
        final dynamic rawLon = loc['lng'] ?? loc['lon'];
        if (rawLon != null) {
          lon = rawLon is num
              ? rawLon as num
              : double.tryParse(rawLon.toString());
        }
      }

      // Fallback to selected district coordinates if device GPS is unavailable
      lat ??= selectedDistrict.value?.numericLat;
      lon ??= selectedDistrict.value?.numericLon;

      // Populate LocationService map so it is guaranteed non-null
      if (Get.isRegistered<LocationService>() && lat != null) {
        Get.find<LocationService>().currentLocation.addAll({
          'lat': lat,
          'lng': lon,
          'lon': lon,
        });
      }

      final payload = <String, dynamic>{
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'user_type': 'seller',
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'country': countryController.text.trim(),
        'state': stateController.text.trim().isNotEmpty
            ? stateController.text.trim()
            : (selectedDivision.value?.name ?? ''),
        'city': cityController.text.trim().isNotEmpty
            ? cityController.text.trim()
            : (selectedDistrict.value?.name ?? ''),
        'area': areaController.text.trim().isNotEmpty
            ? areaController.text.trim()
            : (selectedUpazila.value?.name ?? ''),
        'shop_name': shopNameController.text.trim(),
        'division_id': selectedDivision.value?.id,
        'district_id': selectedDistrict.value?.id,
        'upazila_id': selectedUpazila.value?.id,
        'lat': lat ?? (Get.isRegistered<LocationService>() ? Get.find<LocationService>().currentLocation.value['lat'] : null),
        'lon': lon ?? (Get.isRegistered<LocationService>() ? (Get.find<LocationService>().currentLocation.value['lng'] ?? Get.find<LocationService>().currentLocation.value['lon']) : null),
      };

      if (postalCodeController.text.trim().isNotEmpty) {
        payload['postal_code'] = postalCodeController.text.trim();
      }
      if (referralCodeController.text.trim().isNotEmpty) {
        payload['referral_code'] = referralCodeController.text.trim();
      }

      print("my register payload is 4534 $payload");

      final decodedResponse = await _repository.createSeller(payload);
      final response = SellerRegisterResponse.fromJson(decodedResponse);

      if (response.isSuccess) {
        final autoLoggedIn = _saveAutoLoginIfPossible(response);
        Get.offNamed(
          Routes.SELLER_REGISTER_SUCCESS,
          arguments: {
            'auto_logged_in': autoLoggedIn,
            'message': response.message,
            'shop': response.data['shop'],
            'user': response.data['user'],
          },
        );
        return;
      }

      if (response.statusCode == 422) {
        _setFieldErrors(response.fieldErrors);
        return;
      }

      Get.showSnackbar(
        Ui.ErrorSnackBar(
          message: response.statusCode >= 500
              ? 'sellerRegister.registrationFailed'.tr
              : response.message,
          title: 'sellerRegister.registration'.tr,
        ),
      );
    } catch (e) {
      Get.showSnackbar(
        Ui.ErrorSnackBar(
          message: e.toString(),
          title: 'sellerRegister.registration'.tr,
        ),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  String? requiredValidator(String? value, String label) {
    if ((value ?? '').trim().isEmpty) {
      return '${'sellerRegister.required'.tr}: $label';
    }
    return null;
  }

  String? phoneValidator(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) {
      return 'sellerRegister.phoneRequired'.tr;
    }

    // Normalize Bengali digits if typed in Bengali
    final digitsOnly = raw
        .replaceAll('০', '0')
        .replaceAll('১', '1')
        .replaceAll('২', '2')
        .replaceAll('৩', '3')
        .replaceAll('৪', '4')
        .replaceAll('৫', '5')
        .replaceAll('৬', '6')
        .replaceAll('৭', '7')
        .replaceAll('৮', '8')
        .replaceAll('৯', '9')
        .replaceAll(RegExp(r'[\s\-\+]'), '');

    String clean = digitsOnly;
    if (clean.startsWith('880')) {
      clean = clean.substring(2);
    }

    if (clean.length != 11 || !RegExp(r'^\d{11}$').hasMatch(clean)) {
      return 'sellerRegister.phoneInvalid'.tr;
    }
    return null;
  }

  String? emailValidator(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return 'sellerRegister.emailRequired'.tr;
    if (!GetUtils.isEmail(email)) return 'sellerRegister.emailInvalid'.tr;
    return null;
  }

  String? passwordValidator(String? value) {
    if ((value ?? '').isEmpty) return 'sellerRegister.passwordRequired'.tr;
    if (value!.length < 6) return 'sellerRegister.passwordMinLength'.tr;
    return null;
  }

  String? confirmPasswordValidator(String? value) {
    if ((value ?? '').isEmpty) {
      return 'sellerRegister.confirmPasswordRequired'.tr;
    }
    if (value != passwordController.text) {
      return 'sellerRegister.passwordsDoNotMatch'.tr;
    }
    return null;
  }

  String? fieldError(String key) => fieldErrors[key];

  void clearFieldError(String key) {
    if (fieldErrors.containsKey(key)) fieldErrors.remove(key);
  }

  bool _saveAutoLoginIfPossible(SellerRegisterResponse response) {
    final data = response.data;
    final token = data['token']?.toString();
    final user = data['user'];
    final shop = data['shop'];

    if (token == null || token.isEmpty || user is! Map) {
      _saveStoreKeys(user: user, shop: shop);
      return false;
    }

    final normalizedUser = Map<String, dynamic>.from(user);
    if (shop is Map) {
      normalizedUser['shop'] = Map<String, dynamic>.from(shop);
    }

    final loginModel = LoginResponseModel.fromJson({
      'status': response.body is Map ? response.body['status'] : 'success',
      'message': response.message,
      'data': {
        'token': token,
        'token_type': data['token_type'] ?? 'Bearer',
        'user': normalizedUser,
      },
    });

    Get.find<AuthService>().setUser(loginModel);
    _saveStoreKeys(user: normalizedUser, shop: shop);
    return true;
  }

  void _saveStoreKeys({dynamic user, dynamic shop}) {
    final box = GetStorage();
    final userId = user is Map ? user['id'] : null;
    final shopId = shop is Map ? shop['id'] : null;

    if (userId != null) box.write('userId', userId);
    if (shopId != null) {
      box.write('storeId', shopId);
      box.write('shopId', shopId);
      box.write('selected_store_id', shopId);
    }
  }

  void _setFieldErrors(Map<String, List<String>> errors) {
    fieldErrors.assignAll(
      errors.map((key, value) {
        return MapEntry(key, value.isEmpty ? 'Invalid value' : value.first);
      }),
    );
  }
}
