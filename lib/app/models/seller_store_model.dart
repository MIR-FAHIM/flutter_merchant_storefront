import 'package:ecom_delivery_flutter/app/models/subscription_package_model.dart';

class SellerStoreModel {
  final dynamic id;
  final String name;
  final String? slug;
  final String? logo;
  final StoreSubscription? package;

SellerStoreModel({
    this.id,
    required this.name,
    this.slug,
    this.logo,
    this.package,
});

  factory SellerStoreModel.fromJson(Map<String, dynamic> json) {
    return SellerStoreModel(
      id: json['id'],
      name: _firstText(json, ['shop_name', 'name', 'store_name']) ??
          'MyZoo Store',
      slug: _firstText(json, ['slug', 'shop_slug', 'store_slug']),
      logo: _firstText(json, ['logo', 'shop_logo', 'store_logo']),
      package: json['package'] is Map
          ? StoreSubscription.fromJson(
              Map<String, dynamic>.from(json['package']),
            )
          : null,
    );
  }

  bool get hasSlug => slug != null && slug!.trim().isNotEmpty;
}

String? _firstText(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value == null) continue;

    final text = value.toString().trim();
    if (text.isNotEmpty && text.toLowerCase() != 'null') {
      return text;
    }
  }

  return null;
}


