import 'package:ecom_delivery_flutter/app/models/delivery/delivery_man_model.dart';
import 'package:ecom_delivery_flutter/app/modules/delivery_man/repositories/delivery_man_repository.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryManController extends GetxController {
  DeliveryManController({
    DeliveryManRepository? repository,
  }) : _repository = repository ?? DeliveryManRepository();

  final DeliveryManRepository _repository;

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final shopIdController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final fatherNameController = TextEditingController();
  final fatherContactController = TextEditingController();
  final emergencyContactController = TextEditingController();
  final addressController = TextEditingController();
  final earningController = TextEditingController(text: '0.00');
  final noteController = TextEditingController();

  final selectedType = 'in_house'.obs;
  final selectedStatus = 'active'.obs;
  final isVerified = false.obs;
  final isPasswordVisible = false.obs;

  final isSaving = false.obs;
  final errorMessage = ''.obs;

  // Delivery Men List State
  final ScrollController listScrollController = ScrollController();
  final RxList<DeliveryManItem> deliveryMenList = <DeliveryManItem>[].obs;
  final RxBool isLoadingList = false.obs;
  final RxBool isMoreLoading = false.obs;
  final RxString listErrorMessage = ''.obs;
  final RxString searchFilter = ''.obs;
  final RxString statusFilter = 'all'.obs;
  final RxInt currentPage = 1.obs;
  final RxInt lastPage = 1.obs;
  final RxInt totalDeliveryMen = 0.obs;

  bool get hasMore => currentPage.value < lastPage.value;

  final typeOptions = const [
    DropdownMenuItem(value: 'in_house', child: Text('In House')),
    DropdownMenuItem(value: 'freelance', child: Text('Freelance')),
    DropdownMenuItem(value: 'third_party', child: Text('Third Party')),
  ];

  final statusOptions = const [
    DropdownMenuItem(value: 'active', child: Text('Active')),
    DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
    DropdownMenuItem(value: 'pending', child: Text('Pending')),
  ];

  @override
  void onInit() {
    super.onInit();
    _initShopId();
    listScrollController.addListener(_onListScroll);
    fetchDeliveryMenList(isRefresh: true);
  }

  @override
  void onClose() {
    listScrollController.removeListener(_onListScroll);
    listScrollController.dispose();
    nameController.dispose();
    mobileController.dispose();
    shopIdController.dispose();
    emailController.dispose();
    passwordController.dispose();
    fatherNameController.dispose();
    fatherContactController.dispose();
    emergencyContactController.dispose();
    addressController.dispose();
    earningController.dispose();
    noteController.dispose();
    super.onClose();
  }

  void _initShopId() {
    try {
      shopIdController.text =
          Get.find<AuthService>().currentUser.value.data!.user!.shop!.id.toString();
    } catch (e) {
      debugPrint('Error resolving shop ID: $e');
    }
  }

  void _onListScroll() {
    if (!listScrollController.hasClients) return;
    final double pos = listScrollController.position.pixels;
    final double max = listScrollController.position.maxScrollExtent;
    if (pos >= max - 250) {
      fetchMoreDeliveryMenList();
    }
  }

  Future<void> fetchDeliveryMenList({bool isRefresh = false}) async {
    if (isLoadingList.value || isMoreLoading.value) return;

    try {
      listErrorMessage.value = '';
      if (isRefresh) {
        currentPage.value = 1;
      }

      isLoadingList.value = deliveryMenList.isEmpty;

      final String resolvedShopId = shopIdController.text.isNotEmpty
          ? shopIdController.text.trim()
          : (Get.find<AuthService>().currentUser.value.data?.user?.shop?.id?.toString() ?? '');

      final response = await _repository.getDeliveryMenByShop(
        shopId: resolvedShopId,
        search: searchFilter.value,
        status: statusFilter.value,
        page: currentPage.value,
        perPage: 20,
      );

      if (response.isSuccess || response.items.isNotEmpty) {
        deliveryMenList.assignAll(response.items);
        currentPage.value = response.currentPage;
        lastPage.value = response.lastPage;
        totalDeliveryMen.value = response.total;
      } else {
        deliveryMenList.clear();
        listErrorMessage.value = response.message ?? 'Failed to load delivery men';
      }
    } catch (e) {
      deliveryMenList.clear();
      listErrorMessage.value = e.toString();
      debugPrint('fetchDeliveryMenList error: $e');
    } finally {
      isLoadingList.value = false;
    }
  }

  Future<void> fetchMoreDeliveryMenList() async {
    if (!hasMore || isLoadingList.value || isMoreLoading.value) return;

    try {
      isMoreLoading.value = true;
      listErrorMessage.value = '';

      final int nextPage = currentPage.value + 1;
      final String resolvedShopId = shopIdController.text.isNotEmpty
          ? shopIdController.text.trim()
          : (Get.find<AuthService>().currentUser.value.data?.user?.shop?.id?.toString() ?? '');

      final response = await _repository.getDeliveryMenByShop(
        shopId: resolvedShopId,
        search: searchFilter.value,
        status: statusFilter.value,
        page: nextPage,
        perPage: 20,
      );

      if (response.isSuccess || response.items.isNotEmpty) {
        deliveryMenList.addAll(response.items);
        currentPage.value = response.currentPage;
        lastPage.value = response.lastPage;
        totalDeliveryMen.value = response.total;
      }
    } catch (e) {
      debugPrint('fetchMoreDeliveryMenList error: $e');
    } finally {
      isMoreLoading.value = false;
    }
  }

  Future<void> submitDeliveryMan() async {
    if (!formKey.currentState!.validate()) return;

    final String name = nameController.text.trim();
    final String mobile = mobileController.text.trim();
    final int? shopId = int.tryParse(shopIdController.text.trim()) ??
        Get.find<AuthService>().currentUser.value.data?.user?.shop?.id;

    if (name.isEmpty) {
      errorMessage.value = 'Delivery Man full name is required.';
      return;
    }

    if (mobile.isEmpty) {
      errorMessage.value = 'Mobile number is required.';
      return;
    }

    if (shopId == null || shopId <= 0) {
      errorMessage.value = 'Valid Shop ID is required.';
      return;
    }

    final email = emailController.text.trim();
    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      errorMessage.value = 'Please enter a valid email address.';
      return;
    }

    final password = passwordController.text.trim();
    if (password.isNotEmpty && password.length < 6) {
      errorMessage.value = 'Password must be at least 6 characters.';
      return;
    }

    final double earning = double.tryParse(earningController.text.trim()) ?? 0.00;

    final request = DeliveryManRequestModel(
      name: name,
      mobile: mobile,
      shopId: shopId,
      email: email.isNotEmpty ? email : null,
      password: password.isNotEmpty ? password : null,
      fatherName: fatherNameController.text.trim(),
      fatherContact: fatherContactController.text.trim(),
      emergencyContact: emergencyContactController.text.trim(),
      address: addressController.text.trim(),
      type: selectedType.value,
      earning: earning,
      status: selectedStatus.value,
      isVerified: isVerified.value,
      note: noteController.text.trim(),
    );

    await _executeSubmit(request);
  }

  Future<void> _executeSubmit(DeliveryManRequestModel request) async {
    if (isSaving.value) return;

    try {
      isSaving.value = true;
      errorMessage.value = '';

      final response = await _repository.addDeliveryMan(request: request);

      if (response.isSuccess) {
        Get.snackbar(
          'Success',
          response.message ?? 'Delivery Man added successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1B1C1E),
          colorText: const Color(0xFF34D399),
          duration: const Duration(seconds: 3),
        );
        resetForm();
        fetchDeliveryMenList(isRefresh: true);
        Get.back(); // Return to list view
      } else {
        errorMessage.value = response.message ?? 'Failed to add Delivery Man.';
      }
    } on DeliveryManException catch (error) {
      errorMessage.value = error.message;
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred. Please try again.';
      debugPrint('submitDeliveryMan error: $e');
    } finally {
      isSaving.value = false;
    }
  }

  void resetForm() {
    nameController.clear();
    mobileController.clear();
    emailController.clear();
    passwordController.clear();
    fatherNameController.clear();
    fatherContactController.clear();
    emergencyContactController.clear();
    addressController.clear();
    earningController.text = '0.00';
    noteController.clear();
    selectedType.value = 'in_house';
    selectedStatus.value = 'active';
    isVerified.value = false;
    errorMessage.value = '';
    _initShopId();
  }
}
