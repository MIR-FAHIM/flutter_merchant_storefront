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
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: user.avatarOriginal != null
                      ? CachedNetworkImageProvider(
                      "${CompanyData.image_file_url}/${user.avatarOriginal}") // Replace with actual domain
                      : null,
                  child: user.avatarOriginal == null
                      ? const Icon(Icons.person, size: 40, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 12),

                // Name
                Text(
                  user.name ?? 'No Name',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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

                // Address
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.white),
                  title: Text(user.address ?? 'No Address', style: const TextStyle(color: Colors.white70)),
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
                  leading:
                  Icon(Icons.exit_to_app, color: AppColors.redTextColor),
                  title: Text('Log Out',
                      style: TextStyle(color: AppColors.redTextColor)),
                  onTap: () {
                    Get.find<AuthService>().removeCurrentUser();
                    Get.toNamed(Routes.SPLASHSCREEN);
                  },
                ),



              ],
            ),
          );
        }),
      ),
    );
  }
}

