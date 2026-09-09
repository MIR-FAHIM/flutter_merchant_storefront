import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';
import 'package:ecom_delivery_flutter/app/modules/auth/seller_register/controllers/seller_register_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/common/Color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerRegisterView extends GetView<SellerRegisterController> {
  const SellerRegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111213),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF111213),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'sellerRegister.title'.tr,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
               _HeroCard(),
              const SizedBox(height: 16),
              _SectionCard(
                title: 'sellerRegister.sellerInformation'.tr,
                children: [
                  _SellerTextField(
                    label: 'sellerRegister.sellerName'.tr,
                    hint: 'sellerRegister.sellerNameHint'.tr,
                    textController: controller.nameController,
                    errorKey: 'name',
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (value) =>
                        controller.requiredValidator(value, 'sellerRegister.sellerName'.tr),
                  ),
                  _SellerTextField(
                    label: 'sellerRegister.phone'.tr,
                    hint: 'sellerRegister.phoneHint'.tr,
                    textController: controller.phoneController,
                    errorKey: 'phone',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (value) =>
                        controller.requiredValidator(value, 'sellerRegister.phone'.tr),
                  ),
                  _SellerTextField(
                    label: 'sellerRegister.email'.tr,
                    hint: 'sellerRegister.emailHint'.tr,
                    textController: controller.emailController,
                    errorKey: 'email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: controller.emailValidator,
                  ),
                  Obx(
                    () => _SellerTextField(
                      label: 'sellerRegister.password'.tr,
                      hint: 'sellerRegister.passwordHint'.tr,
                      textController: controller.passwordController,
                      errorKey: 'password',
                      obscureText: controller.hidePassword.value,
                      prefixIcon: Icons.lock_outline_rounded,
                      validator: controller.passwordValidator,
                      suffixIcon: IconButton(
                        onPressed: () {
                          controller.hidePassword.value =
                              !controller.hidePassword.value;
                        },
                        icon: Icon(
                          controller.hidePassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => _SellerTextField(
                      label: 'sellerRegister.confirmPassword'.tr,
                      hint: 'sellerRegister.confirmPasswordHint'.tr,
                      textController: controller.confirmPasswordController,
                      errorKey: 'confirm_password',
                      obscureText: controller.hideConfirmPassword.value,
                      prefixIcon: Icons.lock_reset_rounded,
                      validator: controller.confirmPasswordValidator,
                      suffixIcon: IconButton(
                        onPressed: () {
                          controller.hideConfirmPassword.value =
                              !controller.hideConfirmPassword.value;
                        },
                        icon: Icon(
                          controller.hideConfirmPassword.value
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionCard(
                title: 'sellerRegister.storeSetup'.tr,
                children: [
                  _SellerTextField(
                    label: 'sellerRegister.storeName'.tr,
                    hint: 'sellerRegister.storeNameHint'.tr,
                    textController: controller.shopNameController,
                    errorKey: 'shop_name',
                    prefixIcon: Icons.storefront_outlined,
                    validator: (value) =>
                        controller.requiredValidator(value, 'sellerRegister.storeName'.tr),
                  ),
                  _SellerTextField(
                    label: 'sellerRegister.country'.tr,
                    hint: 'sellerRegister.countryHint'.tr,
                    textController: controller.countryController,
                    errorKey: 'country',
                    prefixIcon: Icons.public_rounded,
                    validator: (value) =>
                        controller.requiredValidator(value, 'sellerRegister.country'.tr),
                  ),
                  _SellerTextField(
                    label: 'sellerRegister.state'.tr,
                    hint: 'sellerRegister.stateHint'.tr,
                    textController: controller.stateController,
                    errorKey: 'state',
                    prefixIcon: Icons.map_outlined,
                    validator: (value) =>
                        controller.requiredValidator(value, 'sellerRegister.state'.tr),
                  ),
                  _SellerTextField(
                    label: 'sellerRegister.city'.tr,
                    hint: 'sellerRegister.cityHint'.tr,
                    textController: controller.cityController,
                    errorKey: 'city',
                    prefixIcon: Icons.location_city_outlined,
                    validator: (value) =>
                        controller.requiredValidator(value, 'sellerRegister.city'.tr),
                  ),
                  _SellerTextField(
                    label: 'sellerRegister.area'.tr,
                    hint: 'sellerRegister.areaHint'.tr,
                    textController: controller.areaController,
                    errorKey: 'area',
                    prefixIcon: Icons.place_outlined,
                  ),
                  _SellerTextField(
                    label: 'sellerRegister.address'.tr,
                    hint: 'sellerRegister.addressHint'.tr,
                    textController: controller.addressController,
                    errorKey: 'address',
                    prefixIcon: Icons.home_work_outlined,
                    validator: (value) =>
                        controller.requiredValidator(value, 'sellerRegister.address'.tr),
                  ),
                  _SellerTextField(
                    label: 'sellerRegister.postalCode'.tr,
                    hint: 'sellerRegister.postalCodeHint'.tr,
                    textController: controller.postalCodeController,
                    errorKey: 'postal_code',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.markunread_mailbox_outlined,
                    validator: (value) =>
                        controller.requiredValidator(value, 'sellerRegister.postalCode'.tr),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Obx(
                () => CheckboxListTile(
                  value: controller.acceptedTerms.value,
                  onChanged: (value) {
                    controller.acceptedTerms.value = value ?? false;
                    controller.clearFieldError('terms');
                  },
                  activeColor: const Color(0xFF0F766E),
                  checkColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    'sellerRegister.terms'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: controller.fieldError('terms') == null
                      ? null
                      : Text(
                          controller.fieldError('terms')!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              Obx(
                () => SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed:
                        controller.isSubmitting.value ? null : controller.submit,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF0F766E),
                      disabledBackgroundColor: const Color(0xFF64748B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                          'sellerRegister.submit'.tr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => Get.offNamed(Routes.LOGIN),
                child: Text(
                  'sellerRegister.haveAccount'.tr,
                  style: TextStyle(
                    color: Color(0xFF2DD4BF),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F766E), Color(0xFF0B3B57)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            CompanyData.companyLogo,
            height: 54,
            width: 130,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 46,
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'sellerRegister.heroTitle'.tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'sellerRegister.heroDescription'.tr,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _SellerTextField extends GetView<SellerRegisterController> {
  const _SellerTextField({
    required this.label,
    required this.hint,
    required this.textController,
    required this.errorKey,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
  });

  final String label;
  final String hint;
  final TextEditingController textController;
  final String errorKey;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final serverError = this.controller.fieldError(errorKey);
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: textController,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          onChanged: (_) => this.controller.clearFieldError(errorKey),
          style: const TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            errorText: serverError,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primaryColor, width: 1.4),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
          ),
        ),
      );
    });
  }
}
