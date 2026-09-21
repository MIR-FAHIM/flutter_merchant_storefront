import 'package:ecom_delivery_flutter/app/models/baki/baki_summary_model.dart';
import 'package:ecom_delivery_flutter/app/models/pos/pos_cart_model.dart';
import 'package:ecom_delivery_flutter/app/models/seller_customer_list_model.dart';
import 'package:ecom_delivery_flutter/app/modules/pos/controllers/pos_cart_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_customers/repositories/seller_customer_repository.dart';
import 'package:ecom_delivery_flutter/app/repositories/baki_repository.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:ecom_delivery_flutter/common/ui.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PosCustomerItem {
  final int id;
  final String name;
  final String phone;
  final String? email;

  PosCustomerItem({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
  });
}

class PosCheckoutModal extends StatefulWidget {
  const PosCheckoutModal({
    super.key,
    required this.controller,
  });

  final PosCartController controller;

  static Future<void> show(BuildContext context, PosCartController controller) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1B1C1E),
      barrierColor: Colors.black.withOpacity(0.65),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PosCheckoutModal(controller: controller),
    );
  }

  @override
  State<PosCheckoutModal> createState() => _PosCheckoutModalState();
}

class _PosCheckoutModalState extends State<PosCheckoutModal> {
  late TextEditingController _paidAmountController;
  late TextEditingController _customerNameController;
  late TextEditingController _customerPhoneController;
  late TextEditingController _noteController;
  final TextEditingController _customerSearchController = TextEditingController();

  String _selectedPaymentMethod = 'cash';
  DateTime? _selectedDueDate;
  int? _selectedCustomerId;
  PosCustomerItem? _selectedCustomer;
  List<PosCustomerItem> _allCustomers = [];
  bool _isLoadingCustomers = false;
  bool _showCustomerDropdown = false;
  bool _isManualCustomerEntry = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {'id': 'cash', 'labelKey': 'pos.paymentMethod.cash', 'icon': Icons.payments_outlined},
    {'id': 'bkash', 'labelKey': 'pos.paymentMethod.bkash', 'icon': Icons.account_balance_wallet_outlined},
    {'id': 'nagad', 'labelKey': 'pos.paymentMethod.nagad', 'icon': Icons.send_to_mobile_outlined},
    {'id': 'baki', 'labelKey': 'pos.paymentMethod.baki', 'icon': Icons.history_edu_outlined},
    {'id': 'bank', 'labelKey': 'pos.paymentMethod.bank', 'icon': Icons.account_balance_outlined},
    {'id': 'card', 'labelKey': 'pos.paymentMethod.card', 'icon': Icons.credit_card_outlined},
  ];

  @override
  void initState() {
    super.initState();
    final subtotal = widget.controller.subtotal;
    _paidAmountController = TextEditingController(
      text: subtotal % 1 == 0 ? subtotal.toInt().toString() : subtotal.toStringAsFixed(2),
    );
    _paidAmountController.addListener(() {
      if (mounted) setState(() {});
    });
    _customerNameController = TextEditingController(
      text: widget.controller.activeCart.value?.customerName ?? '',
    );
    _customerPhoneController = TextEditingController(
      text: widget.controller.activeCart.value?.customerPhone ?? '',
    );
    _noteController = TextEditingController();
    _customerSearchController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadCustomers();
  }

  @override
  void dispose() {
    _paidAmountController.dispose();
    _customerNameController.dispose();
    _customerPhoneController.dispose();
    _noteController.dispose();
    _customerSearchController.dispose();
    super.dispose();
  }

  List<PosCustomerItem> get _filteredCustomers {
    final query = _customerSearchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _allCustomers.take(8).toList();
    }
    return _allCustomers.where((c) {
      final nameMatches = c.name.toLowerCase().contains(query);
      final phoneMatches = c.phone.contains(query);
      return nameMatches || phoneMatches;
    }).toList();
  }

  Future<void> _loadCustomers() async {
    setState(() => _isLoadingCustomers = true);
    final List<PosCustomerItem> loaded = [];

    // 1. Fetch preferred customers from SellerCustomerRepository
    try {
      final sellerId = Get.find<AuthService>().currentUser.value.data?.user?.id ?? 0;
      if (sellerId > 0) {
        final data = await SellerCustomerRepository().getPreferredCustomers(sellerId: sellerId);
        final pagination = SellerPreferredCustomerPagination.fromJson(data);
        for (final pref in pagination.data) {
          final cid = pref.customer.id > 0 ? pref.customer.id : pref.customerUserId;
          if (cid > 0 && !loaded.any((c) => c.id == cid)) {
            loaded.add(PosCustomerItem(
              id: cid,
              name: pref.customer.name,
              phone: pref.customer.phone ?? '',
              email: pref.customer.email,
            ));
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading preferred customers for POS: $e');
    }

    // 2. Fetch Baki summary customers
    try {
      final storeId = widget.controller.currentStoreId;
      if (storeId.isNotEmpty) {
        final response = await BakiRepository().fetchBakiSummary(storeId: storeId);
        final statusCode = response['status_code'] as int? ?? 500;
        if (statusCode >= 200 && statusCode < 300) {
          final body = response['body'];
          if (body is Map && body['data'] is Map) {
            final bakiSummary = BakiSummaryData.fromJson(
              Map<String, dynamic>.from(body['data']),
            );
            for (final bCust in bakiSummary.customers) {
              if (bCust.customerId != null && !loaded.any((c) => c.id == bCust.customerId)) {
                loaded.add(PosCustomerItem(
                  id: bCust.customerId!,
                  name: bCust.name ?? 'Customer #${bCust.customerId}',
                  phone: bCust.phone ?? '',
                  email: bCust.email,
                ));
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading Baki customers for POS: $e');
    }

    if (mounted) {
      setState(() {
        _allCustomers = loaded;
        _isLoadingCustomers = false;

        // Auto-match if cart had existing customer details
        final cartCustName = widget.controller.activeCart.value?.customerName?.trim();
        final cartCustPhone = widget.controller.activeCart.value?.customerPhone?.trim();
        if (_selectedCustomer == null && (cartCustName?.isNotEmpty == true || cartCustPhone?.isNotEmpty == true)) {
          final matched = _allCustomers.firstWhereOrNull(
            (c) => (cartCustPhone != null && cartCustPhone.isNotEmpty && c.phone == cartCustPhone) ||
                   (cartCustName != null && cartCustName.isNotEmpty && c.name.toLowerCase() == cartCustName.toLowerCase()),
          );
          if (matched != null) {
            _selectedCustomer = matched;
            _selectedCustomerId = matched.id;
            _customerNameController.text = matched.name;
            _customerPhoneController.text = matched.phone;
          }
        }
      });
    }
  }

  void _showAddCustomerDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: _customerSearchController.text.trim());
    final phoneCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (dlgCtx) {
        return StatefulBuilder(
          builder: (context, setDlgState) {
            return Dialog(
              backgroundColor: _cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: _borderColor),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _accentColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.person_add_alt_1_rounded, color: _accentColor, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'baki.addNewCustomer'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: '${'pos.customerName'.tr} *',
                        labelStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                        filled: true,
                        fillColor: _inputBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: '${'pos.customerPhone'.tr} *',
                        labelStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                        filled: true,
                        fillColor: _inputBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: addressCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Address (Optional)',
                        labelStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                        filled: true,
                        fillColor: _inputBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSaving ? null : () => Navigator.of(dlgCtx).pop(),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: _borderColor),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: Text('pos.cancel'.tr, style: const TextStyle(color: Colors.white70)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isSaving ? null : () async {
                              final name = nameCtrl.text.trim();
                              final phone = phoneCtrl.text.trim();
                              if (name.isEmpty || phone.isEmpty) {
                                Get.showSnackbar(Ui.ErrorSnackBar(
                                  title: 'common.error'.tr,
                                  message: 'Name and Phone number are required',
                                ));
                                return;
                              }

                              setDlgState(() => isSaving = true);
                              try {
                                final repo = SellerCustomerRepository();
                                final res = await repo.addCustomer(payload: {
                                  'name': name,
                                  'phone': phone,
                                  if (addressCtrl.text.trim().isNotEmpty) 'address': addressCtrl.text.trim(),
                                });

                                if (res.customer?.id != null) {
                                  final newCustomer = PosCustomerItem(
                                    id: res.customer!.id!,
                                    name: res.customer!.name ?? name,
                                    phone: res.customer!.phone ?? phone,
                                    email: res.customer!.email,
                                  );

                                  if (mounted) {
                                    setState(() {
                                      _allCustomers.insert(0, newCustomer);
                                      _selectedCustomer = newCustomer;
                                      _selectedCustomerId = newCustomer.id;
                                      _customerNameController.text = newCustomer.name;
                                      _customerPhoneController.text = newCustomer.phone;
                                      _customerSearchController.clear();
                                      _showCustomerDropdown = false;
                                    });
                                  }

                                  Navigator.of(dlgCtx).pop();
                                  Get.showSnackbar(Ui.SuccessSnackBar(
                                    title: 'common.success'.tr,
                                    message: res.message ?? 'Customer added and selected',
                                  ));
                                } else {
                                  throw Exception('Customer ID not returned');
                                }
                              } catch (e) {
                                setDlgState(() => isSaving = false);
                                Get.showSnackbar(Ui.ErrorSnackBar(
                                  title: 'common.error'.tr,
                                  message: e.toString().replaceAll('Exception: ', ''),
                                ));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentColor,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                                  )
                                : Text('pos.save'.tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static const Color _cardColor = Color(0xFF1B1C1E);
  static const Color _inputBg = Color(0xFF242528);
  static const Color _borderColor = Color(0xFF2E3033);
  static const Color _accentColor = Color(0xFF34D399);

  Future<void> _handleCheckout() async {
    final paidAmount = double.tryParse(_paidAmountController.text.trim()) ?? 0.0;
    final customerName = _customerNameController.text.trim();
    final customerPhone = _customerPhoneController.text.trim();
    final note = _noteController.text.trim();
    final subtotal = widget.controller.subtotal;

    // If payment method is 'baki' OR partial payment (paid_amount < subtotal), customer selection is strictly required
    final isBakiOrPartial = _selectedPaymentMethod == 'baki' || paidAmount < subtotal;
    if (isBakiOrPartial) {
      if (_selectedCustomerId == null) {
        Get.showSnackbar(Ui.ErrorSnackBar(
          title: 'baki.bakiKhata'.tr,
          message: 'baki.validationBakiCustomer'.tr,
        ));
        setState(() => _showCustomerDropdown = true);
        return;
      }
    }

    final formattedDueDate = _selectedDueDate != null
        ? "${_selectedDueDate!.year.toString().padLeft(4, '0')}-${_selectedDueDate!.month.toString().padLeft(2, '0')}-${_selectedDueDate!.day.toString().padLeft(2, '0')}"
        : null;

    final result = await widget.controller.checkout(
      paymentMethod: _selectedPaymentMethod,
      paidAmount: paidAmount,
      customerName: customerName.isNotEmpty ? customerName : null,
      customerPhone: customerPhone.isNotEmpty ? customerPhone : null,
      note: note.isNotEmpty ? note : null,
      dueDate: formattedDueDate,
      customerId: _selectedCustomerId,
    );

    if (result != null && mounted) {
      Navigator.of(context).pop(); // Close checkout sheet
      _showOrderSuccessDialog(result);
    }
  }

  void _showOrderSuccessDialog(PosCheckoutResponse order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          backgroundColor: _cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: _borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _accentColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: _accentColor,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'pos.orderCompleted'.tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${'pos.orderNum'.tr}${order.orderNumber ?? order.id ?? ''}',
                  style: const TextStyle(
                    color: Color(0xFF60A5FA),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _inputBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'pos.totalPaid'.tr,
                        style: const TextStyle(color: Color(0xFF9CA3AF),
                            fontSize: 13),
                      ),
                      Text(
                        '৳${(order.total ?? 0.0).toStringAsFixed((order.total ??
                            0.0) % 1 == 0 ? 0 : 2)}',
                        style: const TextStyle(
                          color: _accentColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'pos.startNewSale'.tr,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
        );
  }

  @override
  Widget build(BuildContext context) {
    final subtotal = widget.controller.subtotal;
    final totalItems = widget.controller.totalItems;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grab handle
              Center(
                child: Container(
                  height: 4,
                  width: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4B5563),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Title and Payable Amount
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'pos.posCheckout'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '$totalItems ${'pos.items'.tr} • ${widget.controller.selectedCounter.value}',
                        style: const TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _accentColor.withOpacity(0.4)),
                    ),
                    child: Text(
                      '৳${subtotal.toStringAsFixed(subtotal % 1 == 0 ? 0 : 2)}',
                      style: const TextStyle(
                        color: _accentColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(color: _borderColor, height: 1),
              const SizedBox(height: 14),

              // Payment Methods
              Text(
                'pos.selectPaymentMethod'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _paymentMethods.map((pm) {
                  final isSelected = _selectedPaymentMethod == pm['id'];
                  return ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          pm['icon'] as IconData,
                          size: 15,
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          (pm['labelKey'] as String).tr,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: _accentColor,
                    backgroundColor: _inputBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isSelected ? _accentColor : _borderColor,
                      ),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPaymentMethod = pm['id'] as String;
                          if (_selectedPaymentMethod == 'baki') {
                            _paidAmountController.text = '0.0';
                            if (_selectedCustomer == null) {
                              _showCustomerDropdown = true;
                            }
                          } else if (_paidAmountController.text == '0.0' || _paidAmountController.text == '0') {
                            final subtotal = widget.controller.subtotal;
                            _paidAmountController.text = subtotal % 1 == 0
                                ? subtotal.toInt().toString()
                                : subtotal.toStringAsFixed(2);
                          }
                        });
                      }
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Paid Amount Field
              Text(
                'pos.paidAmount'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _paidAmountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  prefixText: '৳ ',
                  prefixStyle: const TextStyle(color: _accentColor, fontWeight: FontWeight.w900),
                  filled: true,
                  fillColor: _inputBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                    borderSide: const BorderSide(color: _accentColor),
                  ),
                ),
              ),

              // Dynamic Remaining Due Card
              Builder(builder: (_) {
                final currentPaid = double.tryParse(_paidAmountController.text.trim()) ?? 0.0;
                final remainingDue = (subtotal - currentPaid) > 0 ? (subtotal - currentPaid) : 0.0;
                if (remainingDue <= 0) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'baki.remainingDue'.tr,
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '৳${remainingDue.toStringAsFixed(remainingDue % 1 == 0 ? 0 : 2)}',
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 14),

              // Due Date Picker (Optional)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'baki.dueDate'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_selectedDueDate != null)
                    GestureDetector(
                      onTap: () => setState(() => _selectedDueDate = null),
                      child: Text(
                        'pos.cancel'.tr,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDueDate ?? now.add(const Duration(days: 7)),
                    firstDate: now,
                    lastDate: now.add(const Duration(days: 730)),
                    builder: (ctx, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: _accentColor,
                            onPrimary: Colors.black,
                            surface: _cardColor,
                            onSurface: Colors.white,
                          ),
                          dialogBackgroundColor: _cardColor,
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => _selectedDueDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: _inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: _selectedDueDate != null ? _accentColor : const Color(0xFF9CA3AF),
                        size: 16,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _selectedDueDate != null
                            ? "${_selectedDueDate!.day.toString().padLeft(2, '0')}/${_selectedDueDate!.month.toString().padLeft(2, '0')}/${_selectedDueDate!.year}"
                            : 'baki.selectDueDate'.tr,
                        style: TextStyle(
                          color: _selectedDueDate != null ? Colors.white : const Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: _selectedDueDate != null ? FontWeight.w800 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Customer Selection Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'baki.customer'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Builder(builder: (_) {
                        final currentPaid = double.tryParse(_paidAmountController.text.trim()) ?? 0.0;
                        final isDue = _selectedPaymentMethod == 'baki' || currentPaid < subtotal;
                        if (!isDue) return const SizedBox.shrink();

                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'pos.requiredForBaki'.tr,
                                style: const TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                  if (_selectedCustomer == null)
                    InkWell(
                      onTap: () => _showAddCustomerDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _accentColor.withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.person_add_alt_1_rounded, color: _accentColor, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              'baki.addNewCustomer'.tr,
                              style: const TextStyle(
                                color: _accentColor,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Selected Customer Card OR Search Selector
              if (_selectedCustomer != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _inputBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedPaymentMethod == 'baki' ? _accentColor.withOpacity(0.6) : _borderColor,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: _accentColor.withOpacity(0.2),
                        child: Text(
                          _selectedCustomer!.name.isNotEmpty ? _selectedCustomer!.name[0].toUpperCase() : '?',
                          style: const TextStyle(color: _accentColor, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _selectedCustomer!.name,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _accentColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'ID: #${_selectedCustomer!.id}',
                                    style: const TextStyle(color: _accentColor, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedCustomer!.phone.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                _selectedCustomer!.phone,
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _selectedCustomer = null;
                            _selectedCustomerId = null;
                            _customerNameController.clear();
                            _customerPhoneController.clear();
                            _customerSearchController.clear();
                            _showCustomerDropdown = true;
                          });
                        },
                        icon: const Icon(Icons.edit, size: 13, color: Color(0xFF60A5FA)),
                        label: Text(
                          'baki.changeCustomer'.tr,
                          style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _customerSearchController,
                      onTap: () {
                        setState(() => _showCustomerDropdown = true);
                      },
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'baki.searchCustomerHint'.tr,
                        hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                        prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 18),
                        suffixIcon: _isLoadingCustomers
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: Center(
                                  child: SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white54),
                                  ),
                                ),
                              )
                            : (_customerSearchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.white54, size: 16),
                                    onPressed: () {
                                      _customerSearchController.clear();
                                      setState(() {});
                                    },
                                  )
                                : null),
                        filled: true,
                        fillColor: _inputBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _accentColor)),
                      ),
                    ),

                    // Filtered customer suggestions dropdown
                    if (_showCustomerDropdown) ...[
                      const SizedBox(height: 6),
                      Container(
                        constraints: const BoxConstraints(maxHeight: 180),
                        decoration: BoxDecoration(
                          color: const Color(0xFF242528),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _borderColor),
                        ),
                        child: _filteredCustomers.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'baki.noCustomersFound'.tr,
                                      style: const TextStyle(color: Colors.white60, fontSize: 12),
                                    ),
                                    TextButton(
                                      onPressed: () => _showAddCustomerDialog(context),
                                      child: Text(
                                        '+ ${'baki.addNewCustomer'.tr}',
                                        style: const TextStyle(color: _accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemCount: _filteredCustomers.length,
                                separatorBuilder: (_, __) => const Divider(color: _borderColor, height: 1),
                                itemBuilder: (context, idx) {
                                  final cust = _filteredCustomers[idx];
                                  return ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      radius: 14,
                                      backgroundColor: _accentColor.withOpacity(0.15),
                                      child: Text(
                                        cust.name.isNotEmpty ? cust.name[0].toUpperCase() : '?',
                                        style: const TextStyle(color: _accentColor, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(cust.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                                    subtitle: Text(cust.phone, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 12),
                                    onTap: () {
                                      setState(() {
                                        _selectedCustomer = cust;
                                        _selectedCustomerId = cust.id;
                                        _customerNameController.text = cust.name;
                                        _customerPhoneController.text = cust.phone;
                                        _showCustomerDropdown = false;
                                        _customerSearchController.clear();
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                    ],

                    // Manual customer details for non-baki orders if seller wants
                    if (_selectedPaymentMethod != 'baki' && (subtotal - (double.tryParse(_paidAmountController.text.trim()) ?? 0.0) <= 0)) ...[
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          setState(() => _isManualCustomerEntry = !_isManualCustomerEntry);
                        },
                        child: Row(
                          children: [
                            Icon(
                              _isManualCustomerEntry ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 16,
                              color: Colors.white54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'baki.manualCustomer'.tr,
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (_isManualCustomerEntry) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _customerNameController,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'pos.customerName'.tr,
                                  hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                                  filled: true,
                                  fillColor: _inputBg,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                controller: _customerPhoneController,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'pos.customerPhone'.tr,
                                  hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                                  filled: true,
                                  fillColor: _inputBg,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ],
                ),

              const SizedBox(height: 14),

              // Sale Note
              TextField(
                controller: _noteController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'pos.addNoteOptional'.tr,
                  hintStyle: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                  filled: true,
                  fillColor: _inputBg,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _borderColor),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Complete Sale Button
              Obx(() {
                final isProcessing = widget.controller.isCheckingOut.value;
                return SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isProcessing ? null : _handleCheckout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: isProcessing
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            '${'pos.completeSale'.tr} (৳${subtotal.toStringAsFixed(subtotal % 1 == 0 ? 0 : 2)})',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
