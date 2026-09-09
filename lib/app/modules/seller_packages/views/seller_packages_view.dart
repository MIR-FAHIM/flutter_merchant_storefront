import 'package:ecom_delivery_flutter/app/models/seller_store_model.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_packages/controllers/seller_packages_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_packages/views/widgets/subscription_package_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerPackagesView extends GetView<SellerPackagesController> {
  const SellerPackagesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111213),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF111213),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Subscription Packages',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.stores.isEmpty) {
          return const _StateMessage(
            icon: Icons.storefront_outlined,
            message: 'No store found for this seller account.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.fetchSubscriptionPackages();
            await controller.fetchStoreSubscription();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Subscription Packages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose a package to unlock your storefront, products, POS, orders, and reports.',
                  style: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                _StoreDropdown(controller: controller),
                const SizedBox(height: 16),
                _CurrentSubscriptionCard(controller: controller),
                const SizedBox(height: 22),
                if (controller.boughtPackage != null) ...[
                  const Text(
                    'Bought Package',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SubscriptionPackageCard(
                    package: controller.boughtPackage!,
                    isCurrent: true,
                    isLoading: false,
                    onSubscribe: null,
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  controller.boughtPackage == null
                      ? 'Available Packages'
                      : 'Other Packages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                if (controller.otherPackages.isEmpty)
                  _StatePanel(
                    message: controller.boughtPackage == null
                        ? 'No active subscription packages found.'
                        : 'No other active subscription packages found.',
                  )
                else
                  ...controller.otherPackages.map((package) {
                    return SubscriptionPackageCard(
                      package: package,
                      isCurrent: controller.isCurrentPackage(package),
                      isLoading: controller.isSubscribing(package),
                      onSubscribe: controller.subscribingPackageId.value != null
                          ? null
                          : () => controller.subscribe(package),
                    );
                  }),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _StoreDropdown extends StatelessWidget {
  const _StoreDropdown({required this.controller});

  final SellerPackagesController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SellerStoreModel>(
          value: controller.selectedStore.value,
          dropdownColor: const Color(0xFF1B1C1E),
          iconEnabledColor: Colors.white,
          isExpanded: true,
          items: controller.stores.map((store) {
            return DropdownMenuItem<SellerStoreModel>(
              value: store,
              child: Text(
                store.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            );
          }).toList(),
          onChanged: controller.selectStore,
        ),
      ),
    );
  }
}

class _CurrentSubscriptionCard extends StatelessWidget {
  const _CurrentSubscriptionCard({required this.controller});

  final SellerPackagesController controller;

  @override
  Widget build(BuildContext context) {
    final subscription = controller.currentSubscription.value;
    final isLoading = controller.isSubscriptionLoading.value;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF062B4F),
            Color(0xFF078A83),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF078A83).withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.workspace_premium_rounded,
                color: Colors.white,
                size: 28,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  controller.selectedStoreName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isLoading)
            const LinearProgressIndicator(
              minHeight: 4,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )
          else if (subscription == null)
            const Text(
              'Choose a package to unlock your storefront, products, POS, orders, and reports.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            )
          else ...[
            Text(
              subscription.packageName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(status: subscription.status),
                if (subscription.displayDate.isNotEmpty)
                  _InfoChip(
                    icon: Icons.event_available_rounded,
                    label: _remainingDaysText(subscription.displayDate),
                  ),
                _InfoChip(
                  icon: Icons.inventory_2_outlined,
                  label: _limitText(subscription.maxProducts, 'products'),
                ),
                _InfoChip(
                  icon: Icons.receipt_long_outlined,
                  label: _limitText(
                    subscription.maxOrdersPerMonth,
                    'orders/month',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _limitText(int? value, String label) {
    if (value == null || value < 0) return 'Unlimited $label';
    return '$value $label';
  }

  String _remainingDaysText(String dateText) {
    final targetDate = DateTime.tryParse(dateText)?.toLocal();
    if (targetDate == null) return dateText;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    final days = targetDay.difference(today).inDays;

    if (days > 1) return '$days days remaining';
    if (days == 1) return '1 day remaining';
    if (days == 0) return 'Expires today';
    return 'Expired ${days.abs()} day${days.abs() == 1 ? '' : 's'} ago';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isActive = status.toLowerCase() == 'active';
    final color = isActive ? const Color(0xFF34D399) : const Color(0xFFFBBF24);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatePanel extends StatelessWidget {
  const _StatePanel({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFFE5E7EB),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.message,
  });

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: const Color(0xFF078A83), size: 42),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}






