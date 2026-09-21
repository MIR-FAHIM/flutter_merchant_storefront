import 'package:ecom_delivery_flutter/app/modules/seller_customers/controllers/seller_customer_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerCustomerAddView extends StatefulWidget {
  const SellerCustomerAddView({super.key});

  static const Color _bgColor = Color(0xFF111213);
  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _accentColor = Color(0xFF34D399);

  @override
  State<SellerCustomerAddView> createState() => _SellerCustomerAddViewState();
}

class _SellerCustomerAddViewState extends State<SellerCustomerAddView> {
  late final SellerCustomerController controller;

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _passwordController;
  late final TextEditingController _existingCustomerIdController;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<SellerCustomerController>()
        ? Get.find<SellerCustomerController>()
        : Get.put(SellerCustomerController());

    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _passwordController = TextEditingController();
    _existingCustomerIdController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _existingCustomerIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SellerCustomerAddView._bgColor,
      appBar: AppBar(
        backgroundColor: SellerCustomerAddView._bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'sellerCustomers.addCustomer'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderCard(),
              const SizedBox(height: 14),
              if (controller.errorMessage.value.isNotEmpty) ...[
                _ErrorBanner(message: controller.errorMessage.value),
                const SizedBox(height: 14),
              ],
              _FormCard(
                title: 'sellerCustomers.createNewCustomer'.tr,
                children: [
                  _CustomerTextField(
                    label: 'sellerCustomers.name'.tr,
                    controller: _nameController,
                  ),
                  _CustomerTextField(
                    label: 'sellerCustomers.phone'.tr,
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                  ),
                  _CustomerTextField(
                    label: 'sellerCustomers.email'.tr,
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  _CustomerTextField(
                    label: 'sellerCustomers.address'.tr,
                    controller: _addressController,
                    maxLines: 2,
                  ),
                  _CustomerTextField(
                    label: 'sellerCustomers.password'.tr,
                    controller: _passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : () async {
                              final ok = await controller.createNewCustomer(
                                name: _nameController.text,
                                phone: _phoneController.text,
                                email: _emailController.text,
                                address: _addressController.text,
                                password: _passwordController.text,
                              );
                              if (ok && mounted) {
                                _nameController.clear();
                                _phoneController.clear();
                                _emailController.clear();
                                _addressController.clear();
                                _passwordController.clear();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SellerCustomerAddView._accentColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isSaving.value
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'sellerCustomers.saveCustomer'.tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _FormCard(
                title: 'sellerCustomers.attachExistingCustomer'.tr,
                children: [
                  _CustomerTextField(
                    label: 'sellerCustomers.customerUserId'.tr,
                    controller: _existingCustomerIdController,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : () async {
                              final ok =
                                  await controller.attachExistingCustomer(
                                customerUserId:
                                    _existingCustomerIdController.text,
                              );
                              if (ok && mounted) {
                                _existingCustomerIdController.clear();
                              }
                            },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SellerCustomerAddView._accentColor,
                        side: const BorderSide(
                            color: SellerCustomerAddView._accentColor),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'sellerCustomers.attachCustomer'.tr,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
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
}

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF063F3A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF0F766E)),
      ),
      child: Row(
        children: [
          Container(
            height: 46,
            width: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.person_add_alt_1_rounded,
              color: Color(0xFF0F766E),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'sellerCustomers.description'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SellerCustomerAddView._cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SellerCustomerAddView._borderColor),
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
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _CustomerTextField extends StatelessWidget {
  const _CustomerTextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.maxLines = 1,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: obscureText ? 1 : maxLines,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF9CA3AF)),
          filled: true,
          fillColor: const Color(0xFF111213),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: SellerCustomerAddView._borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: SellerCustomerAddView._accentColor),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent.withOpacity(0.35)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
