import 'package:ecom_delivery_flutter/app/models/seller_store_model.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_store_qr/controllers/seller_store_qr_controller.dart';
import 'package:ecom_delivery_flutter/app/modules/seller_store_qr/views/widgets/seller_store_qr_frame.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerStoreQrView extends GetView<SellerStoreQrController> {
  const SellerStoreQrView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111213),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF111213),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Store QR Download',
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

        if (controller.errorText.value.isNotEmpty &&
            controller.stores.isEmpty) {
          return _StateMessage(
            icon: Icons.lock_outline_rounded,
            message: controller.errorText.value,
          );
        }

        if (controller.stores.isEmpty) {
          return const _StateMessage(
            icon: Icons.storefront_outlined,
            message: 'No store found for this seller account.',
          );
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [



              if (controller.hasSelectedStore &&
                  !controller.selectedStoreHasSlug) ...[
                const SizedBox(height: 14),
                const _WarningMessage(
                  message:
                      'This store does not have a public slug yet. Please update the store profile first.',
                ),
              ],
              const SizedBox(height: 18),
              RepaintBoundary(
                key: controller.posterKey,
                child: SellerStoreQrFrame(
                  storeName: controller.selectedStoreName,
                  storeUrl: controller.selectedStoreHasSlug
                      ? controller.publicStoreUrl
                      : 'https://myzoo.asia/store',
                ),
              ),
              const SizedBox(height: 18),
              _ActionButtons(controller: controller),
            ],
          ),
        );
      }),
    );
  }
}

class _StoreDropdown extends StatelessWidget {
  const _StoreDropdown({required this.controller});

  final SellerStoreQrController controller;

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

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.controller});

  final SellerStoreQrController controller;

  @override
  Widget build(BuildContext context) {
    final isDisabled =
        controller.isSaving.value || !controller.selectedStoreHasSlug;

    return Column(
      children: [
        _PrimaryActionButton(
          icon: Icons.download_rounded,
          label: controller.isSaving.value
              ? 'Preparing QR Frame'
              : 'Download QR Frame',
          onTap: isDisabled ? null : controller.downloadQrFrame,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _SecondaryActionButton(
                icon: Icons.copy_rounded,
                label: 'Copy Store URL',
                onTap: isDisabled ? null : controller.copyStoreUrl,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SecondaryActionButton(
                icon: Icons.ios_share_rounded,
                label: 'Share QR / Store URL',
                onTap: isDisabled ? null : controller.shareQrOrUrl,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _SecondaryActionButton(
          icon: Icons.open_in_browser_rounded,
          label: 'Open Public Store',
          onTap: isDisabled ? null : controller.openPublicStore,
        ),
      ],
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF078A83),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF2E3033),
          disabledForegroundColor: const Color(0xFF9CA3AF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 19),
        label: Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          disabledForegroundColor: const Color(0xFF6B7280),
          side: const BorderSide(color: Color(0xFF2E3033)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _WarningMessage extends StatelessWidget {
  const _WarningMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF4A3413),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFBBF24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFFFBBF24),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
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
