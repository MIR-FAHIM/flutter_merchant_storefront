import 'package:ecom_delivery_flutter/app/models/seller_customer_list_model.dart';
import 'package:ecom_delivery_flutter/app/models/seller_customer_model.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_customers/repositories/seller_customer_repository.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerCustomerController extends GetxController {
  SellerCustomerController({
    SellerCustomerRepository? repository,
  }) : _repository = repository ?? SellerCustomerRepository();

  final SellerCustomerRepository _repository;

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final addressController = TextEditingController();
  final passwordController = TextEditingController();
  final existingCustomerIdController = TextEditingController();

  final isSaving = false.obs;
  final errorMessage = ''.obs;

  final isLoadingCustomers = false.obs;
  final fetchError = ''.obs;
  final preferredCustomers = <SellerPreferredCustomer>[].obs;
  final preferredCustomersPagination = Rxn<SellerPreferredCustomerPagination>();
  final selectedCustomer = Rxn<SellerPreferredCustomer>();
  final customerOrders = <SellerCustomerOrder>[].obs;
  final isLoadingCustomerOrders = false.obs;
  final customerOrdersError = ''.obs;
  int _customerOrderPage = 1;
  int _customerOrderLastPage = 1;

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    passwordController.dispose();
    existingCustomerIdController.dispose();
    super.onClose();
  }

  Future<void> createNewCustomer() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final email = emailController.text.trim();
    final address = addressController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty && phone.isEmpty && email.isEmpty) {
      errorMessage.value = 'Please enter customer name, phone, or email.';
      return;
    }

    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      errorMessage.value = 'Please enter a valid email address.';
      return;
    }

    final payload = <String, dynamic>{
      if (name.isNotEmpty) 'name': name,
      if (phone.isNotEmpty) 'phone': phone,
      if (email.isNotEmpty) 'email': email,
      if (address.isNotEmpty) 'address': address,
      if (password.isNotEmpty) 'password': password,
    };

    await _submit(payload);
  }

  Future<void> attachExistingCustomer() async {
    final customerUserId = existingCustomerIdController.text.trim();
    if (customerUserId.isEmpty) {
      errorMessage.value = 'Please enter customer user id.';
      return;
    }

    await _submit({'customer_user_id': customerUserId});
  }

  Future<void> _submit(Map<String, dynamic> payload) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      errorMessage.value = '';
      final result = await _repository.addCustomer(payload: payload);
      Get.snackbar(
        'Success',
        result.message ?? 'Customer added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      _clearForm();
    } on SellerCustomerException catch (error) {
      if (error.statusCode == 401) {
        Get.offAllNamed(Routes.LOGIN);
        return;
      }
      errorMessage.value = _friendlyError(error.statusCode, error.message);
    } catch (error) {
      errorMessage.value = 'Customer add failed. Please try again.';
    } finally {
      isSaving.value = false;
    }
  }

  /// Fetches preferred customers for [sellerId], parses the response into
  /// [SellerPreferredCustomerPagination], and stores the flattened list in
  /// [preferredCustomers].
  Future<void> fetchPreferredCustomers({required int sellerId}) async {
    if (isLoadingCustomers.value) return;

    try {
      isLoadingCustomers.value = true;
      fetchError.value = '';

      final data = await _repository.getPreferredCustomers(sellerId: sellerId);
      final pagination = SellerPreferredCustomerPagination.fromJson(data);

      preferredCustomersPagination.value = pagination;
      preferredCustomers.assignAll(pagination.data);
    } on SellerCustomerException catch (error) {
      if (error.statusCode == 401) {
        Get.offAllNamed(Routes.LOGIN);
        return;
      }
      fetchError.value = _friendlyError(error.statusCode, error.message);
    } catch (error) {
      fetchError.value = 'Unable to load preferred customers. Please try again.';
    } finally {
      isLoadingCustomers.value = false;
    }
  }

  void setSelectedCustomer(SellerPreferredCustomer customer) {
    selectedCustomer.value = customer;
    customerOrders.clear();
    customerOrdersError.value = '';
    _customerOrderPage = 1;
    _customerOrderLastPage = 1;
  }

  Future<void> fetchCustomerOrders({
    required int shopId,
    required int userId,
    bool refresh = false,
  }) async {
    if (isLoadingCustomerOrders.value) return;
    if (shopId <= 0 || userId <= 0) {
      customerOrders.clear();
      customerOrdersError.value = 'Shop or customer information is missing.';
      return;
    }
    if (refresh) {
      _customerOrderPage = 1;
      _customerOrderLastPage = 1;
    } else if (_customerOrderPage > _customerOrderLastPage) {
      return;
    }

    try {
      isLoadingCustomerOrders.value = true;
      customerOrdersError.value = '';

      final page = await _repository.getCustomerOrdersByShop(
        shopId: shopId,
        userId: userId,
        page: _customerOrderPage,
      );

      if (refresh) customerOrders.clear();
      customerOrders.addAll(page.orders);
      _customerOrderPage = page.currentPage + 1;
      _customerOrderLastPage = page.lastPage;
    } on SellerCustomerException catch (error) {
      if (error.statusCode == 401) {
        Get.offAllNamed(Routes.LOGIN);
        return;
      }
      customerOrdersError.value = _friendlyError(error.statusCode, error.message);
    } catch (_) {
      customerOrdersError.value = 'Unable to load customer orders.';
    } finally {
      isLoadingCustomerOrders.value = false;
    }
  }

  String _friendlyError(int statusCode, String message) {
    switch (statusCode) {
      case 403:
        return 'You do not have permission.';
      case 404:
        return 'Seller, customer, or order not found.';
      case 422:
        return message;
      default:
        return message.isNotEmpty ? message : 'Customer add failed.';
    }
  }

  void _clearForm() {
    nameController.clear();
    phoneController.clear();
    emailController.clear();
    addressController.clear();
    passwordController.clear();
    existingCustomerIdController.clear();
  }
}
