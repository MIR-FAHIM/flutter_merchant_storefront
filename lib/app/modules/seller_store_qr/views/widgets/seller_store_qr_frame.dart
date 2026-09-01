import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SellerStoreQrFrame extends StatelessWidget {
  const SellerStoreQrFrame({
    super.key,
    required this.storeName,
    required this.storeUrl,
  });

  final String storeName;
  final String storeUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1080 / 1650,
      child: Container(
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
        ),
        padding: const EdgeInsets.all(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Image.asset(
                CompanyData.companyLogo,
                height: 52,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.storefront_rounded,
                    color: Color(0xFF062B4F),
                    size: 46,
                  );
                },
              ),
              const SizedBox(height: 18),
              Text(
                storeName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF062B4F),
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Scan to shop from our online store',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF315A70),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE0F2F1),
                    width: 2,
                  ),
                ),
                child: QrImageView(
                  data: storeUrl,
                  version: QrVersions.auto,
                  size: 230,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF062B4F),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF062B4F),
                  ),
                ),
              ),
              const Spacer(),

              const SizedBox(height: 8),
              Text(
                storeUrl,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF062B4F),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
