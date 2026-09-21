import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';
import 'package:ecom_delivery_flutter/app/models/profile_model.dart';
import 'package:ecom_delivery_flutter/app/modules/home/controllers/home_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:ecom_delivery_flutter/common/Color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class ProfileView extends GetView<HomeController> {
  const ProfileView({Key? key}) : super(key: key);

  /// Safe location builder avoiding null crashes and handling division, district, upazila
  String _buildLocation(ProfileData user) {
    final parts = <String>[];

    final div = (user.division?.bnName?.trim().isNotEmpty == true)
        ? user.division!.bnName!.trim()
        : (user.division?.name?.trim().isNotEmpty == true
            ? user.division!.name!.trim()
            : (user.shop?.division?.bnName?.trim().isNotEmpty == true
                ? user.shop!.division!.bnName!.trim()
                : user.shop?.division?.name?.trim()));

    final dist = (user.district?.bnName?.trim().isNotEmpty == true)
        ? user.district!.bnName!.trim()
        : (user.district?.name?.trim().isNotEmpty == true
            ? user.district!.name!.trim()
            : (user.shop?.districtModel?.bnName?.trim().isNotEmpty == true
                ? user.shop!.districtModel!.bnName!.trim()
                : user.shop?.districtModel?.name?.trim()));

    final upz = (user.upazila?.bnName?.trim().isNotEmpty == true)
        ? user.upazila!.bnName!.trim()
        : (user.upazila?.name?.trim().isNotEmpty == true
            ? user.upazila!.name!.trim()
            : (user.shop?.upazila?.bnName?.trim().isNotEmpty == true
                ? user.shop!.upazila!.bnName!.trim()
                : user.shop?.upazila?.name?.trim()));

    if (div != null && div.isNotEmpty) parts.add(div);
    if (dist != null && dist.isNotEmpty) parts.add(dist);
    if (upz != null && upz.isNotEmpty) parts.add(upz);

    return parts.join(' - ');
  }

  void _copyToClipboard(BuildContext context, String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'কপি হয়েছে',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF242526),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.check_circle_outline, color: Colors.greenAccent),
    );
  }

  /// Share merchant app with seller referral / shop code
  void _shareMerchantApp(String? code) {
    final hasCode = code != null && code.trim().isNotEmpty;
    final referralPart = hasCode
        ? '\n🎁 আমার রেফারেল কোড: ${code.trim()}\n\n💡 নোট: নতুন সেলার হিসেবে MyZoo মার্চেন্ট অ্যাপে রেজিস্ট্রেশনের সময় এই রেফারেল কোডটি ব্যবহার করুন।\n'
        : '';

    final shareMessage =
        '🛍️ MyZoo মার্চেন্ট অ্যাপে যোগ দিন এবং অনলাইনে আপনার ব্যবসা সহজে পরিচালনা ও বৃদ্ধি করুন!\n'
        '$referralPart\n'
        '📲 এখনই মার্চেন্ট অ্যাপটি ডাউনলোড করুন:\n'
        'https://play.google.com/store/apps/details?id=com.myzoo.marchant&pli=1';

    Share.share(
      shareMessage,
      subject: 'MyZoo মার্চেন্ট অ্যাপ ও রেফারেল কোড',
    );
  }

  /// Share customer app with shop name & shop code
  void _shareCustomerApp(ProfileData user) {
    final shop = user.shop;
    final shopName = shop?.name ?? shop?.shopName ?? user.name ?? 'আমাদের দোকান';
    final shopCode = shop?.code?.trim();

    final codePart = (shopCode != null && shopCode.isNotEmpty)
        ? '\n🔑 শপ কোড: $shopCode\n\n👉 MyZoo কাস্টমার অ্যাপে এই কোডটি দিয়ে আমাদের দোকানটি যুক্ত (Add) করে নিন এবং ঘরে বসেই সহজে কেনাকাটা করুন!\n'
        : '';

    final message =
        '✨ প্রিয় গ্রাহক,\n'
        'এখন ঘরে বসেই আমাদের দোকান থেকে কেনাকাটা করুন খুব সহজে!\n\n'
        '🛍️ দোকান: $shopName\n'
        '$codePart\n'
        '📲 এখনই MyZoo কাস্টমার অ্যাপটি ডাউনলোড করুন:\n'
        'https://play.google.com/store/apps/details?id=com.myzoo.customer';

    Share.share(
      message,
      subject: '$shopName - MyZoo কাস্টমার অ্যাপ',
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2026),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.redAccent, size: 24),
            SizedBox(width: 8),
            Text(
              'লগআউট',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: const Text(
          'আপনি কি নিশ্চিত যে আপনি আপনার অ্যাকাউন্ট থেকে লগআউট করতে চান?',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('বাতিল', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('হ্যাঁ, লগআউট'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Get.find<AuthService>().removeCurrentUser();
      Get.offAllNamed(Routes.SPLASHSCREEN);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Get.offAllNamed(Routes.ROOT);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF111213),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFF111213),
          iconTheme: const IconThemeData(color: Colors.white),
          title: const Text(
            "প্রোফাইল",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'রিফ্রেশ করুন',
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: () => controller.getProfile(),
            ),
          ],
        ),
        body: Obx(() {
          final user = controller.profileData.value;

          if (user.id == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white70),
            );
          }

          final locationText = _buildLocation(user);
          final shopName = user.shop?.name ?? user.shop?.shopName ?? user.name ?? 'আমার দোকান';
          final shopCode = user.shop?.code;
          final bannerUrl = user.shop?.banner?.url;
          final logoUrl = user.shop?.logo?.url;

          return RefreshIndicator(
            color: AppColors.primaryColor,
            backgroundColor: const Color(0xFF1B1C1E),
            onRefresh: () async {
              controller.getProfile();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- 1. Store Header & Identity Card ---
                  _buildStoreHeaderCard(
                    context: context,
                    user: user,
                    shopName: shopName,
                    shopCode: shopCode,
                    bannerUrl: bannerUrl,
                    logoUrl: logoUrl,
                    locationText: locationText,
                  ),

                  const SizedBox(height: 16),

                  // --- 2. Subscription / Package Smart Card ---
                  _buildPackageSmartCard(context, user),

                  const SizedBox(height: 16),

                  // --- 3. Referral & App Share Card ---
                  _buildReferralShareCard(context, user),

                  const SizedBox(height: 16),

                  // --- 4. Store Information Section ---
                  _buildStoreInfoCard(context, user),

                  const SizedBox(height: 16),

                  // --- 5. Seller & Contact Details Section ---
                  _buildSellerInfoCard(context, user),

                  const SizedBox(height: 16),

                  // --- 6. Quick Actions Section ---
                  _buildQuickActionsCard(context, user),

                  const SizedBox(height: 24),

                  // --- 7. Version Info ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.verified_user_outlined, size: 14, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(width: 6),
                      Text(
                        'সংস্করণ ${CompanyData.appVersion}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Store Header Card containing Banner, Logo, Name, ID, Shop Code, and Location
  Widget _buildStoreHeaderCard({
    required BuildContext context,
    required ProfileData user,
    required String shopName,
    required String? shopCode,
    required String? bannerUrl,
    required String? logoUrl,
    required String locationText,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Banner area
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              if (bannerUrl != null && bannerUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: bannerUrl,
                  height: 130,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 130,
                    color: const Color(0xFF242731),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white30),
                    ),
                  ),
                  errorWidget: (context, url, error) => _buildDefaultBanner(),
                )
              else
                _buildDefaultBanner(),

              // Overlaid gradient on banner for smooth contrast
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),
              ),

              // Shop Logo / Avatar overlapping the banner bottom
              Positioned(
                bottom: -32,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1B1C1E),
                    border: Border.all(color: Colors.white.withOpacity(0.15), width: 2),
                  ),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xFF242731),
                    backgroundImage: (logoUrl != null && logoUrl.isNotEmpty)
                        ? CachedNetworkImageProvider(logoUrl)
                        : null,
                    child: (logoUrl == null || logoUrl.isEmpty)
                        ? const Icon(Icons.storefront_rounded, size: 36, color: Colors.white70)
                        : null,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 38),

          // Shop Name & Verification
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  shopName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),

                // Seller Name & User Type Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.name ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (user.userType != null && user.userType!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFF2DD4BF).withOpacity(0.3)),
                        ),
                        child: Text(
                          user.userType ?? 'সেলার',
                          style: const TextStyle(
                            color: Color(0xFF2DD4BF),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 10),

                // Location Badge (Null-safe!)
                if (locationText.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF242731),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Color(0xFF2DD4BF)),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            locationText,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFFE2E8F0),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],

                // Chips Row: ID & Shop Code
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    // User ID chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'ইউজার আইডি: #${user.id ?? ''}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    // Shop Code with Copy
                    if (shopCode != null && shopCode.isNotEmpty)
                      InkWell(
                        onTap: () => _copyToClipboard(
                          context,
                          shopCode,
                          'শপ কোড "$shopCode" কপি করা হয়েছে',
                        ),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3A8A).withOpacity(0.35),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.qr_code_2, size: 14, color: Color(0xFF93C5FD)),
                              const SizedBox(width: 4),
                              Text(
                                'কোড: $shopCode',
                                style: const TextStyle(
                                  color: Color(0xFFBFDBFE),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.copy, size: 12, color: Color(0xFF93C5FD)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDefaultBanner() {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF0D9488),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.store_mall_directory_rounded,
          size: 48,
          color: Colors.white.withOpacity(0.12),
        ),
      ),
    );
  }

  /// Smart Subscription / Package Card with Bangla Call to Action
  Widget _buildPackageSmartCard(BuildContext context, ProfileData user) {
    final package = user.shop?.package;

    // When no package is active
    if (package == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF451A03).withOpacity(0.6),
              const Color(0xFF78350F).withOpacity(0.35),
              const Color(0xFF1B1C1E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.orange.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.orangeAccent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'দোকান চালু করতে প্যাকেজ কিনুন',
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'প্যাকেজ সক্রিয় নেই',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'আপনার দোকানের পণ্য আপলোড, অর্ডার ম্যানেজমেন্ট ও অন্যান্য সব ফিচার সক্রিয় করতে এবং বিক্রি শুরু করতে অনুগ্রহ করে একটি সাবস্ক্রিপশন প্যাকেজ কিনুন।',
              style: TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Get.toNamed(Routes.SELLER_PACKAGES),
                icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                label: const Text(
                  'প্যাকেজ কিনুন',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // When a package is active
    final packageName = package.package?.name ?? 'সাবস্ক্রিপশন প্যাকেজ';
    final isActive = package.status == 'active';
    final statusText = isActive ? 'সক্রিয়' : (package.status ?? 'সক্রিয়');
    final price = package.price ?? package.package?.price ?? 0;
    final billingCycle = package.billingCycle ?? package.package?.billingCycle ?? 'মাসিক';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isActive
              ? const Color(0xFF10B981).withOpacity(0.3)
              : Colors.orange.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (isActive ? const Color(0xFF10B981) : Colors.orange).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified_rounded,
                      color: isActive ? const Color(0xFF10B981) : Colors.orangeAccent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        packageName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '৳ $price / $billingCycle',
                        style: const TextStyle(
                          color: Color(0xFF2DD4BF),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (isActive ? const Color(0xFF10B981) : Colors.orange).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: (isActive ? const Color(0xFF10B981) : Colors.orange).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: isActive ? const Color(0xFF34D399) : Colors.orangeAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: Colors.white.withOpacity(0.06), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'প্যাকেজ পরিবর্তন বা আপগ্রেড করতে চান?',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              InkWell(
                onTap: () => Get.toNamed(Routes.SELLER_PACKAGES),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'প্যাকেজ পরিবর্তন',
                        style: TextStyle(
                          color: Color(0xFF60A5FA),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF60A5FA)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Referral & App Share Card with Note for Other Sellers
  Widget _buildReferralShareCard(BuildContext context, ProfileData user) {
    final code = user.referralCode ?? (user.referralCode != null ? user.referralCode.toString() : '');
    final hasCode = code.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F766E).withOpacity(0.35),
            const Color(0xFF134E4A).withOpacity(0.2),
            const Color(0xFF1B1C1E),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2DD4BF).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2DD4BF).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: Color(0xFF2DD4BF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'অ্যাপ শেয়ার ও রেফারেল',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'অন্যান্য সেলারদের সাথে অ্যাপ শেয়ার করুন',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Code display box
          if (hasCode) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF111213),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'আপনার রেফারেল কোড',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          code,
                          style: const TextStyle(
                            color: Color(0xFF2DD4BF),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    onPressed: () => _copyToClipboard(
                      context,
                      code,
                      'রেফারেল কোড "$code" কপি করা হয়েছে',
                    ),
                    icon: const Icon(Icons.copy, size: 14),
                    label: const Text('কপি', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Seller note container
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.amber.withOpacity(0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded, color: Colors.amber, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '💡 নোট: নতুন সেলাররা যখন MyZoo মার্চেন্ট অ্যাপে রেজিস্ট্রেশন করবেন, তখন তাদেরকে আপনার এই রেফারেল কোডটি ব্যবহার করতে বলুন।',
                    style: TextStyle(
                      color: Colors.amber.shade100,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Primary Share Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () => _shareMerchantApp(code),
              icon: const Icon(Icons.share_rounded, size: 18),
              label: const Text(
                'রেফারেল কোডসহ অ্যাপ শেয়ার করুন',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Store Information Card
  Widget _buildStoreInfoCard(BuildContext context, ProfileData user) {
    final shop = user.shop;
    final address = shop?.address ?? user.address;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.storefront_outlined, color: Color(0xFF2DD4BF), size: 20),
              SizedBox(width: 8),
              Text(
                'দোকানের তথ্য',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            title: 'দোকানের নাম',
            value: shop?.name ?? shop?.shopName ?? 'দেওয়া নেই',
          ),
          _buildInfoRow(
            icon: Icons.confirmation_number_outlined,
            title: 'শপ আইডি',
            value: shop?.id != null ? '#${shop!.id}' : 'দেওয়া নেই',
          ),
          if (shop?.code != null && shop!.code!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.qr_code,
              title: 'শপ কোড',
              value: shop.code!,
              trailing: IconButton(
                icon: const Icon(Icons.copy, size: 16, color: Colors.white60),
                onPressed: () => _copyToClipboard(
                  context,
                  shop.code!,
                  'শপ কোড "${shop.code}" কপি করা হয়েছে',
                ),
                tooltip: 'কপি করুন',
              ),
            ),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            title: 'ঠিকানা',
            value: (address != null && address.isNotEmpty) ? address : 'দেওয়া নেই',
          ),
          if (shop?.phone != null && shop!.phone!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.phone_outlined,
              title: 'দোকানের ফোন',
              value: shop.phone!,
            ),
          if (shop?.email != null && shop!.email!.isNotEmpty)
            _buildInfoRow(
              icon: Icons.email_outlined,
              title: 'দোকানের ইমেইল',
              value: shop.email!,
            ),
        ],
      ),
    );
  }

  /// Seller / Personal Information Card
  Widget _buildSellerInfoCard(BuildContext context, ProfileData user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.person_outline_rounded, color: Color(0xFF38BDF8), size: 20),
              SizedBox(width: 8),
              Text(
                'ব্যক্তিগত ও যোগাযোগ তথ্য',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            icon: Icons.person_pin_outlined,
            title: 'নাম',
            value: user.name ?? 'দেওয়া নেই',
          ),
          _buildInfoRow(
            icon: Icons.phone_android_outlined,
            title: 'মোবাইল নম্বর',
            value: user.phone ?? 'দেওয়া নেই',
            trailing: (user.phone != null && user.phone!.isNotEmpty)
                ? IconButton(
                    icon: const Icon(Icons.copy, size: 16, color: Colors.white60),
                    onPressed: () => _copyToClipboard(
                      context,
                      user.phone!,
                      'ফোন নম্বর "${user.phone}" কপি করা হয়েছে',
                    ),
                    tooltip: 'কপি করুন',
                  )
                : null,
          ),
          _buildInfoRow(
            icon: Icons.alternate_email_rounded,
            title: 'ইমেইল',
            value: user.email ?? 'দেওয়া নেই',
          ),
          _buildInfoRow(
            icon: Icons.work_outline_rounded,
            title: 'অ্যাকাউন্টের ধরন',
            value: user.userType ?? 'সেলার',
          ),
        ],
      ),
    );
  }

  /// Quick Actions & Logout Card
  Widget _buildQuickActionsCard(BuildContext context, ProfileData user) {
    final code = user.shop?.code ?? (user.referralCode != null ? user.referralCode.toString() : '');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          ListTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.card_membership_rounded, color: Color(0xFF60A5FA), size: 20),
            ),
            title: const Text(
              'সাবস্ক্রিপশন প্যাকেজ',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: const Text(
              'প্যাকেজসমূহ দেখুন ও আপগ্রেড করুন',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white38),
            onTap: () => Get.toNamed(Routes.SELLER_PACKAGES),
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2DD4BF).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.share_rounded, color: Color(0xFF2DD4BF), size: 20),
            ),
            title: const Text(
              'মার্চেন্ট অ্যাপ শেয়ার করুন',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: const Text(
              'রেফারেল কোডসহ নতুন সেলারদের ইনভাইট করুন',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white38),
            onTap: () => _shareMerchantApp(code),
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF38BDF8), size: 20),
            ),
            title: const Text(
              'কাস্টমার অ্যাপ শেয়ার করুন',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
            ),
            subtitle: const Text(
              'শপ কোডসহ কাস্টমারদের কেনাকাটার আমন্ত্রণ জানান',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white38),
            onTap: () => _shareCustomerApp(user),
          ),
          Divider(color: Colors.white.withOpacity(0.06), height: 1, indent: 16, endIndent: 16),
          ListTile(
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            ),
            title: const Text(
              'লগআউট',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: const Text(
              'অ্যাকাউন্ট থেকে লগআউট করুন',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.redAccent),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  /// Reusable row widget for card items
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: Colors.white38),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
