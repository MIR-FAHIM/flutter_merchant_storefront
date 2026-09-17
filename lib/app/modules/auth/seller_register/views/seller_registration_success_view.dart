import 'package:ecom_delivery_flutter/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerRegistrationSuccessView extends StatelessWidget {
  const SellerRegistrationSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments is Map ? Get.arguments as Map : {};
    final autoLoggedIn = args['auto_logged_in'] == true;
    final shop = args['shop'] is Map ? args['shop'] as Map : {};
    final shopName = (shop['name'] ?? shop['shop_name'] ?? 'আপনার MyZoo দোকান')
        .toString();

    return Scaffold(
      backgroundColor: const Color(0xFF111213),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: const Color(0xFF111213),
        title: const Text(
          'দোকান তৈরি সম্পন্ন হয়েছে',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1C1E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2E3033)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      color: const Color(0x242DD4BF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF2DD4BF),
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'বিক্রেতা এবং দোকান সফলভাবে তৈরি হয়েছে',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$shopName প্রস্তুত। আপনার স্টোর প্রোফাইল সম্পূর্ণ করুন, সাবস্ক্রিপশন প্যাকেজ বেছে নিন, পণ্য যোগ করুন এবং গ্রাহকদের সাথে দোকানের লিংক শেয়ার করুন।',
                    style: const TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontSize: 13.5,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const _NextStepsCard(),
            const SizedBox(height: 18),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  if (autoLoggedIn) {
                    Get.offAllNamed(Routes.ROOT);
                  } else {
                    Get.offAllNamed(Routes.LOGIN);
                  }
                },
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF0F766E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  autoLoggedIn
                      ? 'বিক্রেতা ড্যাশবোর্ডে যান'
                      : 'বিক্রেতা ড্যাশবোর্ডে লগইন করুন',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NextStepsCard extends StatelessWidget {
  const _NextStepsCard();

  @override
  Widget build(BuildContext context) {
    final steps = [
      'বিক্রেতা ড্যাশবোর্ডে লগইন করুন',
      'সাবস্ক্রিপশন প্যাকেজ নির্বাচন বা নিশ্চিত করুন',
      'দোকানের প্রোফাইল সম্পূর্ণ করুন',
      'ক্যাটাগরি সক্রিয় করুন',
      'পণ্য যোগ করুন',
      'দোকানের লিংক বা QR কোড শেয়ার করুন',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1C1E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2E3033)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'পরবর্তী পদক্ষেপসমূহ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < steps.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 24,
                    width: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      steps[index],
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
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
