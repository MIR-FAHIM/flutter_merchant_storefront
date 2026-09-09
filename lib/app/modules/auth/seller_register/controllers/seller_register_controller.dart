import 'package:ecom_delivery_flutter/app/models/auth/customer_model.dart';
import 'package:ecom_delivery_flutter/app/modules/auth/seller_register/repositories/seller_register_repository.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
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

  final hidePassword = true.obs;
  final hideConfirmPassword = true.obs;
  final acceptedTerms = false.obs;
  final isSubmitting = false.obs;
  final fieldErrors = <String, String>{}.obs;

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
      final response = await _repository.createSeller({
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text,
        'user_type': 'seller',
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'country': countryController.text.trim(),
        'state': stateController.text.trim(),
        'city': cityController.text.trim(),
        'area': areaController.text.trim(),
        'postal_code': postalCodeController.text.trim(),
        'shop_name': shopNameController.text.trim(),
      });

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
