import 'package:ecom_delivery_flutter/app/models/chat_model.dart';
import 'package:ecom_delivery_flutter/app/models/seller_customer_list_model.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_customers/controllers/seller_customer_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/shop_chat/controllers/shop_chat_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class SellerCustomerListView extends GetView<SellerCustomerController> {
  const SellerCustomerListView({super.key});

  @override
  Widget build(BuildContext context) {
    if (controller.preferredCustomers.isEmpty &&
        !controller.isLoadingCustomers.value &&
        controller.fetchError.value.isEmpty) {
      controller.fetchPreferredCustomers();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF111213),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111213),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'My Customers',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add customer',
            onPressed: () => Get.toNamed(Routes.SELLER_CUSTOMER_ADD),
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
          IconButton(
            tooltip: 'Refresh',
            onPressed: controller.refreshCustomers,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoadingCustomers.value &&
            controller.preferredCustomers.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.fetchError.value.isNotEmpty &&
            controller.preferredCustomers.isEmpty) {
          return _CustomerStateView(
            icon: Icons.warning_amber_rounded,
            title: 'Could not load customers',
            message: controller.fetchError.value,
            onRetry: controller.refreshCustomers,
          );
        }

        if (controller.preferredCustomers.isEmpty) {
          return _CustomerStateView(
            icon: Icons.people_outline_rounded,
            title: 'No customers added yet.',
            message: 'Create a customer or attach an existing customer.',
            onRetry: controller.refreshCustomers,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshCustomers,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
            itemCount: controller.preferredCustomers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              return SellerCustomerListItem(
                item: controller.preferredCustomers[index],
              );
            },
          ),
        );
      }),
    );
  }
}

class SellerCustomerListItem extends StatelessWidget {
  const SellerCustomerListItem({
    super.key,
    required this.item,
  });

  final SellerPreferredCustomer item;

  @override
  Widget build(BuildContext context) {
    final customer = item.customer;
    final name =
        customer.name.trim().isNotEmpty ? customer.name.trim() : 'Unnamed customer';
    final details = [
      if ((customer.phone ?? '').trim().isNotEmpty) customer.phone!.trim(),
      if (customer.email.trim().isNotEmpty) customer.email.trim(),
    ].join(' - ');
    final phone = customer.phone?.trim() ?? '';

    return InkWell(
      onTap: () => Get.toNamed(
        Routes.SELLER_CUSTOMER_DETAIL,
        arguments: {'customer': item},
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1B1C1E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2E3033)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              child: Text(name[0].toUpperCase()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (details.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      details,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if ((item.createdAt ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Added: ${item.createdAt}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  Text(
                    'Total Orders: ${item.customer.ordersCount}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Message Button
            InkWell(
              onTap: () => _openCustomerChat(item),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 42,
                width: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C2B3E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF38BDF8),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Call Button
            InkWell(
              onTap: phone.isEmpty ? null : () => _callCustomer(phone),
              borderRadius: BorderRadius.circular(12),
              child: Opacity(
                opacity: phone.isEmpty ? 0.45 : 1,
                child: Container(
                  height: 42,
                  width: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF064E3B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.call_rounded,
                    color: Color(0xFF34D399),
                    size: 21,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCustomerChat(SellerPreferredCustomer item) async {
    final customer = item.customer;
    final int customerId = customer.id;
    final String customerPhone = (customer.phone ?? '').trim();
    final String customerName = customer.name.trim();

    if (!Get.isRegistered<ShopChatController>()) {
      Get.put(ShopChatController());
    }
    final chatController = Get.find<ShopChatController>();

    if (chatController.conversations.isEmpty &&
        !chatController.isConversationLoading.value) {
      try {
        await chatController.loadConversations();
      } catch (_) {}
    }

    Conversation? match;
    if (customerId > 0) {
      match = chatController.conversations.firstWhereOrNull(
        (c) => c.customerId == customerId || c.customer?.id == customerId,
      );
    }
    if (match == null && customerPhone.isNotEmpty) {
      final cleanPhone = customerPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPhone.isNotEmpty) {
        match = chatController.conversations.firstWhereOrNull(
          (c) =>
              (c.customer?.phone ?? '').replaceAll(RegExp(r'[^0-9]'), '') ==
              cleanPhone,
        );
      }
    }
    if (match == null && customerName.isNotEmpty) {
      match = chatController.conversations.firstWhereOrNull(
        (c) =>
            (c.customer?.name ?? '').trim().toLowerCase() ==
            customerName.toLowerCase(),
      );
    }

    if (match != null) {
      Get.toNamed(
        Routes.SHOP_CHAT_THREAD,
        arguments: {'conversation': match},
      );
      return;
    }

    // If no conversation exists, open a new conversation with user_id
    if (customerId > 0) {
      try {
        final newConversation = await chatController.openConversationWithUser(
          userId: customerId,
        );
        if (newConversation != null) {
          Get.toNamed(
            Routes.SHOP_CHAT_THREAD,
            arguments: {'conversation': newConversation},
          );
          return;
        }
      } catch (_) {}
    }

    Get.toNamed(
      Routes.SHOP_CHAT_CONVERSATIONS,
      arguments: {
        'customer_id': customerId,
        'user_id': customerId,
        'customer_name': customerName,
        'customer_phone': customerPhone,
      },
    );
  }

  Future<void> _callCustomer(String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanPhone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: cleanPhone);
    final opened = await launchUrl(uri);
    if (!opened) {
      Get.snackbar(
        'Call',
        'Could not open phone dialer.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}

class _CustomerStateView extends StatelessWidget {
  const _CustomerStateView({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF34D399), size: 46),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
