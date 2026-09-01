import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';
import 'package:ecom_delivery_flutter/app/modules/home/controllers/home_controller.dart';
import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:ecom_delivery_flutter/app/services/auth_service.dart';
import 'package:ecom_delivery_flutter/common/Color.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:badges/badges.dart' as badges;

class ProfileView extends GetView<HomeController> {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        Get.offAllNamed(Routes.ROOT);
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundColor,
          title: const Text("Profile"),
        ),
        body: Obx(() {
          final user = controller.profileData.value;

          if (user.id == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile picture


                // Name
                Text(
                  'User ID: ${user.id.toString()}',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  user.name ?? 'No Name',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 4),

                // Email
                Text(
                  user.email ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),

                // Phone
                Text(
                  user.phone ?? '',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 12),

                if (user.shop?.banner?.url != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: CachedNetworkImage(
                      imageUrl: user.shop!.banner!.url!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],

                if (user.shop?.logo?.url != null) ...[
                  const SizedBox(height: 12),
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    backgroundImage: CachedNetworkImageProvider(user.shop!.logo!.url!),
                  ),
                ],

                // Address
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white),
                  title: Text(user.address ?? 'No Address',
                      style: const TextStyle(color: Colors.white70)),
                ),

                // Designation
                ListTile(
                  leading: const Icon(Icons.work, color: Colors.white),
                  title: Text(
                    user.userType ?? 'No Designation',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.store, color: Colors.white),
                  title: Text(
                    '${user.shop?.name ?? 'No Shop'}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),
 ListTile(
                  leading: const Icon(Icons.store, color: Colors.white),
                  title: Text(
                    'Shop ID:${user.shop?.id ?? 0}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ),

                ListTile(
                  leading: const Icon(Icons.store, color: Colors.white),
                  title: Text(
                    'Shop Code: ${user.shop?.code}',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ),

                if (user.shop?.package == null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.orange.withOpacity(0.4)),
                    ),
                    child: const Text(
                      'Please Buy A package to get started',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ] else ...[
                  ListTile(
                    leading:
                        const Icon(Icons.card_membership, color: Colors.white),
                    title: Text(
                      user.shop?.package?.package?.name ?? 'Package Activated',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    subtitle: Text(
                      user.shop?.package?.status ?? 'Active',
                      style: TextStyle(
                        color: user.shop?.package?.status == 'active'
                            ? Colors.greenAccent
                            : Colors.white60,
                      ),
                    ),
                  ),
                ],

                ListTile(
                  leading:
                      Icon(Icons.exit_to_app, color: AppColors.redTextColor),
                  title: Text('Log Out',
                      style: TextStyle(color: AppColors.redTextColor)),
                  onTap: () {
                    Get.find<AuthService>().removeCurrentUser();
                    Get.toNamed(Routes.SPLASHSCREEN);
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Version ${CompanyData.appVersion}',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
