import 'dart:typed_data';
import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';
import 'package:ecom_delivery_flutter/common/Color.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SellerStoreQrFrame extends StatelessWidget {
  const SellerStoreQrFrame({
    super.key,
    required this.storeName,
    required this.storeUrl,
    required this.storeCode,
    this.qrBytes,
    this.companyLogo = CompanyData.officialCompanyLogo,
  });

  final String storeName;
  final String storeUrl;
  final String storeCode;
  final Uint8List? qrBytes;
  final String? companyLogo;

  @override
  Widget build(BuildContext context) {
    final String logoAsset = (companyLogo != null && companyLogo!.isNotEmpty)
        ? companyLogo!
        : CompanyData.officialCompanyLogo;

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
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Image.asset(
                logoAsset,
                height: 52,
                color: AppColors.backgroundBlueColor,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.storefront_rounded,
                    color: Color(0xFF062B4F),
                    size: 46,
                  );
                },
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 8),
              if (storeCode.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF062B4F).withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF078A83).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Text(
                        storeCode.toUpperCase().startsWith('CODE:') || storeCode.toUpperCase().startsWith('STORE')
                            ? storeCode
                            : 'Code: $storeCode',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF062B4F),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
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
                child: qrBytes != null && qrBytes!.isNotEmpty
                    ? Image.memory(
                        qrBytes!,
                        width: 230,
                        height: 230,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) {
                          return _buildVectorQr();
                        },
                      )
                    : _buildVectorQr(),
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

  Widget _buildVectorQr() {
    return QrImageView(
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
    );
  }
}
