import 'package:ecom_delivery_flutter/app/modules/delivery_man/controllers/delivery_man_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryManAddView extends GetView<DeliveryManController> {
  const DeliveryManAddView({super.key});

  static const Color _bgColor = Color(0xFF111213);
  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _accentColor = Color(0xFF34D399);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: _bgColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add Delivery Man',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Info Banner
                _HeaderCard(),

                const SizedBox(height: 16),

                // Error Message Banner
                Obx(() {
                  if (controller.errorMessage.value.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.redAccent.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Section 1: Required & Basic Credentials
                _FormSection(
                  title: 'Required Credentials',
                  icon: Icons.person_add_alt_1_rounded,
                  children: [
                    _InputField(
                      controller: controller.nameController,
                      label: 'Full Name *',
                      hint: 'e.g. Rahim Ahmed',
                      icon: Icons.badge_outlined,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter delivery man name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _InputField(
                      controller: controller.mobileController,
                      label: 'Primary Phone / Mobile *',
                      hint: 'e.g. 01711223344',
                      icon: Icons.phone_android_rounded,
                      keyboardType: TextInputType.phone,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter mobile number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _InputField(
                      controller: controller.shopIdController,
                      label: 'Assigned Shop ID *',
                      hint: 'e.g. 3',
                      icon: Icons.storefront_rounded,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter Shop ID';
                        }
                        if (int.tryParse(val.trim()) == null) {
                          return 'Shop ID must be a valid integer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    _InputField(
                      controller: controller.emailController,
                      label: 'Email Address (Optional)',
                      hint: 'e.g. rahim@example.com',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 14),
                    Obx(() => _InputField(
                          controller: controller.passwordController,
                          label: 'Password (Optional - min 6 chars)',
                          hint: 'Leave empty for default (password123)',
                          icon: Icons.lock_outline_rounded,
                          obscureText: !controller.isPasswordVisible.value,
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: const Color(0xFF9CA3AF),
                              size: 20,
                            ),
                            onPressed: () {
                              controller.isPasswordVisible.toggle();
                            },
                          ),
                        )),
                  ],
                ),

                const SizedBox(height: 18),

                // Section 2: Delivery & Account Type Configuration
                _FormSection(
                  title: 'Account & Delivery Config',
                  icon: Icons.tune_rounded,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Delivery Type',
                                style: TextStyle(
                                  color: Color(0xFFD1D5DB),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Obx(() => DropdownButtonFormField<String>(
                                    initialValue: controller.selectedType.value,
                                    dropdownColor: _cardColor,
                                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                                    decoration: _dropdownDecoration(),
                                    items: controller.typeOptions,
                                    onChanged: (val) {
                                      if (val != null) controller.selectedType.value = val;
                                    },
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Account Status',
                                style: TextStyle(
                                  color: Color(0xFFD1D5DB),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Obx(() => DropdownButtonFormField<String>(
                                    initialValue: controller.selectedStatus.value,
                                    dropdownColor: _cardColor,
                                    style: const TextStyle(color: Colors.white, fontSize: 13.5),
                                    decoration: _dropdownDecoration(),
                                    items: controller.statusOptions,
                                    onChanged: (val) {
                                      if (val != null) controller.selectedStatus.value = val;
                                    },
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: _borderColor),
                    const SizedBox(height: 10),
                    Obx(() => SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Account Verification Status',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(
                            controller.isVerified.value
                                ? 'Account marked as Verified'
                                : 'Account unverified (default)',
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 12,
                            ),
                          ),
                          value: controller.isVerified.value,
                          activeThumbColor: _accentColor,
                          onChanged: (val) => controller.isVerified.value = val,
                        )),
                  ],
                ),

                const SizedBox(height: 18),

                // Section 3: Personal & Emergency Contact Details
                _FormSection(
                  title: 'Personal & Emergency Contact',
                  icon: Icons.contact_phone_outlined,
                  children: [
                    _InputField(
                      controller: controller.fatherNameController,
                      label: "Father's Full Name (Optional)",
                      hint: "e.g. Abdul Ahmed",
                      icon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    _InputField(
                      controller: controller.fatherContactController,
                      label: "Father's Phone Number (Optional)",
                      hint: "e.g. 01800000000",
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    _InputField(
                      controller: controller.emergencyContactController,
                      label: 'Emergency Contact Phone (Optional)',
                      hint: 'e.g. 01900000000',
                      icon: Icons.contact_emergency_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    _InputField(
                      controller: controller.addressController,
                      label: 'Residential Address (Optional)',
                      hint: 'House, Road, Area, City...',
                      icon: Icons.home_outlined,
                      maxLines: 2,
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Section 4: Financials & Notes
                _FormSection(
                  title: 'Financials & Notes',
                  icon: Icons.payments_outlined,
                  children: [
                    _InputField(
                      controller: controller.earningController,
                      label: 'Initial Earning Amount (Optional)',
                      hint: '0.00',
                      icon: Icons.account_balance_wallet_outlined,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 14),
                    _InputField(
                      controller: controller.noteController,
                      label: 'Internal Remarks / Notes (Optional)',
                      hint: 'Additional notes or details...',
                      icon: Icons.note_outlined,
                      maxLines: 2,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Submit Button
                Obx(() => SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accentColor,
                          foregroundColor: Colors.black,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: controller.isSaving.value ? null : controller.submitDeliveryMan,
                        icon: controller.isSaving.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.black,
                                ),
                              )
                            : const Icon(Icons.person_add_rounded, size: 20),
                        label: Text(
                          controller.isSaving.value ? 'Creating Account...' : 'Save Delivery Man',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static InputDecoration _dropdownDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: const Color(0xFF141517),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _accentColor, width: 1.5),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              color: Color(0xFF34D399),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Register Delivery Man',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Add a new delivery driver to handle shop orders.',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  const _FormSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF34D399)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFF2E3033)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.validator,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD1D5DB),
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 13.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 19),
            suffixIcon: suffixIcon,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
