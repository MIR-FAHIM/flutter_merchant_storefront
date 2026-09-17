import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  static const _background = Color(0xFF111213);
  static const _surface = Color(0xFF1B1C1E);
  static const _border = Color(0xFF343638);
  static const _accent = Color(0xFF0F766E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: constraints.maxHeight - 48),
              child: Center(
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Image.asset(
                          CompanyData.companyLogo,
                          width: 132,
                          height: 132,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                            size: 72,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'login.title'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'login.subtitle'.tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFADB8B8),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Form(
                        key: controller.loginFormKey,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              initialValue: controller.mobileNumber.value,
                              onChanged: (value) =>
                                  controller.mobileNumber.value = value.trim(),
                              validator: (value) => (value ?? '').trim().isEmpty
                                  ? 'login.emailMobileRequired'.tr
                                  : null,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [
                                AutofillHints.username,
                                AutofillHints.email,
                                AutofillHints.telephoneNumber,
                              ],
                              style: const TextStyle(color: Colors.white),
                              decoration: _decoration(
                                label: 'login.emailOrMobile'.tr,
                                hint: 'login.emailMobileHint'.tr,
                                icon: Icons.alternate_email_rounded,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Obx(
                              () => TextFormField(
                                onChanged: (value) =>
                                    controller.password.value = value,
                                validator: (value) => (value ?? '').isEmpty
                                    ? 'login.passwordRequired'.tr
                                    : null,
                                onFieldSubmitted: (_) => controller.login(),
                                obscureText: controller.hidePassword.value,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                style: const TextStyle(color: Colors.white),
                                decoration: _decoration(
                                  label: 'login.password'.tr,
                                  hint: 'login.passwordHint'.tr,
                                  icon: Icons.lock_outline_rounded,
                                ).copyWith(
                                  suffixIcon: IconButton(
                                    tooltip: controller.hidePassword.value
                                        ? 'login.showPassword'.tr
                                        : 'login.hidePassword'.tr,
                                    onPressed: () =>
                                        controller.hidePassword.toggle(),
                                    icon: Icon(
                                      controller.hidePassword.value
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFFADB8B8),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Obx(
                              () => SizedBox(
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: controller.isLoggingIn.value
                                      ? null
                                      : controller.login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _accent,
                                    disabledBackgroundColor: _accent,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: controller.isLoggingIn.value
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          'login.submit'.tr,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      Row(
                        children: [
                          const Expanded(child: Divider(color: _border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'login.newSeller'.tr,
                              style: const TextStyle(
                                color: Color(0xFFADB8B8),
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: _border)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: () => Get.toNamed(Routes.SELLER_REGISTER),
                          icon: const Icon(Icons.storefront_outlined, size: 20),
                          label: Text('login.createStore'.tr),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: _border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Version ${CompanyData.appVersion}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF879291),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: _surface,
      labelStyle: const TextStyle(color: Color(0xFFADB8B8)),
      hintStyle: const TextStyle(color: Color(0xFF879291)),
      prefixIconColor: const Color(0xFFADB8B8),
      errorMaxLines: 2,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _accent, width: 1.5),
      ),
    );
  }
}
