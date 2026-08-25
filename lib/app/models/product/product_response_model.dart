import 'package:ecom_delivery_flutter/app/api_providers/company_data.dart';

class ProductResponseModel {
  final String? status;
  final String? message;
  final ProductPagination? data;

  ProductResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory ProductResponseModel.fromJson(Map<String, dynamic> json) {
    return ProductResponseModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? ProductPagination.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }

  bool get isSuccess => status?.toLowerCase() == 'success';
}

class ProductPagination {
  final int? currentPage;
  final List<ProductData> products;

  final String? firstPageUrl;
  final int? from;
  final int? lastPage;
  final String? lastPageUrl;
  final List<ProductPaginationLink> links;
  final String? nextPageUrl;
  final String? path;
  final int? perPage;
  final String? prevPageUrl;
  final int? to;
  final int? total;

  ProductPagination({
    this.currentPage,
    this.products = const [],
    this.firstPageUrl,
    this.from,
    this.lastPage,
    this.lastPageUrl,
    this.links = const [],
    this.nextPageUrl,
    this.path,
    this.perPage,
    this.prevPageUrl,
    this.to,
    this.total,
  });

  factory ProductPagination.fromJson(Map<String, dynamic> json) {
    return ProductPagination(
      currentPage: _toInt(json['current_page']),
      products: json['data'] is List
          ? (json['data'] as List)
          .whereType<Map>()
          .map(
            (item) => ProductData.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : [],
      firstPageUrl: json['first_page_url']?.toString(),
      from: _toInt(json['from']),
      lastPage: _toInt(json['last_page']),
      lastPageUrl: json['last_page_url']?.toString(),
      links: json['links'] is List
          ? (json['links'] as List)
          .whereType<Map>()
          .map(
            (item) => ProductPaginationLink.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : [],
      nextPageUrl: json['next_page_url']?.toString(),
      path: json['path']?.toString(),
      perPage: _toInt(json['per_page']),
      prevPageUrl: json['prev_page_url']?.toString(),
      to: _toInt(json['to']),
      total: _toInt(json['total']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'data': products.map((item) => item.toJson()).toList(),
      'first_page_url': firstPageUrl,
      'from': from,
      'last_page': lastPage,
      'last_page_url': lastPageUrl,
      'links': links.map((item) => item.toJson()).toList(),
      'next_page_url': nextPageUrl,
      'path': path,
      'per_page': perPage,
      'prev_page_url': prevPageUrl,
      'to': to,
      'total': total,
    };
  }
}

class ProductData {
  final int? id;
  final String? name;
  final String? addedBy;
  final int? userId;
  final int? shopId;
  final int? categoryId;
  final int? brandId;

  final String? photos;
  final String? thumbnailImg;
  final String? videoProvider;
  final String? videoLink;
  final String? tags;
  final String? description;

  final double? unitPrice;
  final double? purchasePrice;

  final int? variantProduct;
  final String? attributes;
  final String? choiceOptions;
  final String? colors;
  final String? variations;

  final int? todaysDeal;
  final int? published;
  final int? approved;
  final String? stockVisibilityState;
  final int? cashOnDelivery;
  final int? featured;
  final int? sellerFeatured;

  final int? currentStock;
  final String? unit;
  final double? weight;
  final int? minQty;
  final int? lowStockQuantity;

  final double? discount;
  final String? discountType;
  final DateTime? discountStartDate;
  final DateTime? discountEndDate;

  final double? startingBid;
  final DateTime? auctionStartDate;
  final DateTime? auctionEndDate;

  final double? tax;
  final String? taxType;
  final String? shippingType;
  final double? shippingCost;
  final int? isQuantityMultiplied;
  final int? estShippingDays;

  final int? numOfSale;

  final String? metaTitle;
  final String? metaDescription;
  final String? metaImg;

  final String? pdf;
  final String? slug;
  final String? sku;
  final int? refundable;
  final int? earnPoint;
  final double? rating;
  final String? barcode;
  final int? showHome;
  final int? digital;
  final int? auctionProduct;
  final String? fileName;
  final String? filePath;
  final String? externalLink;
  final String? externalLinkBtn;
  final int? wholesaleProduct;
  final String? frequentlyBroughtSelectionType;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final ProductImage? primaryImage;
  final List<ProductImage> images;
  final ProductCategory? category;
  final ProductCategory? subCategory;

  final dynamic brand;
  final dynamic productDiscount;

  ProductData({
    this.id,
    this.name,
    this.addedBy,
    this.userId,
    this.shopId,
    this.categoryId,
    this.brandId,
    this.photos,
    this.thumbnailImg,
    this.videoProvider,
    this.videoLink,
    this.tags,
    this.description,
    this.unitPrice,
    this.purchasePrice,
    this.variantProduct,
    this.attributes,
    this.choiceOptions,
    this.colors,
    this.variations,
    this.todaysDeal,
    this.published,
    this.approved,
    this.stockVisibilityState,
    this.cashOnDelivery,
    this.featured,
    this.sellerFeatured,
    this.currentStock,
    this.unit,
    this.weight,
    this.minQty,
    this.lowStockQuantity,
    this.discount,
    this.discountType,
    this.discountStartDate,
    this.discountEndDate,
    this.startingBid,
    this.auctionStartDate,
    this.auctionEndDate,
    this.tax,
    this.taxType,
    this.shippingType,
    this.shippingCost,
    this.isQuantityMultiplied,
    this.estShippingDays,
    this.numOfSale,
    this.metaTitle,
    this.metaDescription,
    this.metaImg,
    this.pdf,
    this.slug,
    this.sku,
    this.refundable,
    this.earnPoint,
    this.rating,
    this.barcode,
    this.showHome,
    this.digital,
    this.auctionProduct,
    this.fileName,
    this.filePath,
    this.externalLink,
    this.externalLinkBtn,
    this.wholesaleProduct,
    this.frequentlyBroughtSelectionType,
    this.createdAt,
    this.updatedAt,
    this.primaryImage,
    this.images = const [],
    this.category,
    this.subCategory,
    this.brand,
    this.productDiscount,
  });

  factory ProductData.fromJson(Map<String, dynamic> json) {
    return ProductData(
      id: _toInt(json['id']),
      name: json['name']?.toString(),
      addedBy: json['added_by']?.toString(),
      userId: _toInt(json['user_id']),
      shopId: _toInt(json['shop_id']),
      categoryId: _toInt(json['category_id']),
      brandId: _toInt(json['brand_id']),
      photos: json['photos']?.toString(),
      thumbnailImg: json['thumbnail_img']?.toString(),
      videoProvider: json['video_provider']?.toString(),
      videoLink: json['video_link']?.toString(),
      tags: json['tags']?.toString(),
      description: json['description']?.toString(),
      unitPrice: _toDouble(json['unit_price']),
      purchasePrice: _toDouble(json['purchase_price']),
      variantProduct: _toInt(json['variant_product']),
      attributes: json['attributes']?.toString(),
      choiceOptions: json['choice_options']?.toString(),
      colors: json['colors']?.toString(),
      variations: json['variations']?.toString(),
      todaysDeal: _toInt(json['todays_deal']),
      published: _toInt(json['published']),
      approved: _toInt(json['approved']),
      stockVisibilityState: json['stock_visibility_state']?.toString(),
      cashOnDelivery: _toInt(json['cash_on_delivery']),
      featured: _toInt(json['featured']),
      sellerFeatured: _toInt(json['seller_featured']),
      currentStock: _toInt(json['current_stock']),
      unit: json['unit']?.toString(),
      weight: _toDouble(json['weight']),
      minQty: _toInt(json['min_qty']),
      lowStockQuantity: _toInt(json['low_stock_quantity']),
      discount: _toDouble(json['discount']),
      discountType: json['discount_type']?.toString(),
      discountStartDate: _toDateTime(json['discount_start_date']),
      discountEndDate: _toDateTime(json['discount_end_date']),
      startingBid: _toDouble(json['starting_bid']),
      auctionStartDate: _toDateTime(json['auction_start_date']),
      auctionEndDate: _toDateTime(json['auction_end_date']),
      tax: _toDouble(json['tax']),
      taxType: json['tax_type']?.toString(),
      shippingType: json['shipping_type']?.toString(),
      shippingCost: _toDouble(json['shipping_cost']),
      isQuantityMultiplied: _toInt(json['is_quantity_multiplied']),
      estShippingDays: _toInt(json['est_shipping_days']),
      numOfSale: _toInt(json['num_of_sale']),
      metaTitle: json['meta_title']?.toString(),
      metaDescription: json['meta_description']?.toString(),
      metaImg: json['meta_img']?.toString(),
      pdf: json['pdf']?.toString(),
      slug: json['slug']?.toString(),
      sku: json['sku']?.toString(),
      refundable: _toInt(json['refundable']),
      earnPoint: _toInt(json['earn_point']),
      rating: _toDouble(json['rating']),
      barcode: json['barcode']?.toString(),
      showHome: _toInt(json['show_home']),
      digital: _toInt(json['digital']),
      auctionProduct: _toInt(json['auction_product']),
      fileName: json['file_name']?.toString(),
      filePath: json['file_path']?.toString(),
      externalLink: json['external_link']?.toString(),
      externalLinkBtn: json['external_link_btn']?.toString(),
      wholesaleProduct: _toInt(json['wholesale_product']),
      frequentlyBroughtSelectionType:
      json['frequently_brought_selection_type']?.toString(),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      primaryImage: json['primary_image'] is Map<String, dynamic>
          ? ProductImage.fromJson(
        Map<String, dynamic>.from(json['primary_image']),
      )
          : null,
      images: json['images'] is List
          ? (json['images'] as List)
          .whereType<Map>()
          .map(
            (item) => ProductImage.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList()
          : [],
      category: json['category'] is Map<String, dynamic>
          ? ProductCategory.fromJson(
        Map<String, dynamic>.from(json['category']),
      )
          : null,
      subCategory: json['sub_category'] is Map<String, dynamic>
          ? ProductCategory.fromJson(
        Map<String, dynamic>.from(json['sub_category']),
      )
          : null,
      brand: json['brand'],
      productDiscount: json['product_discount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'added_by': addedBy,
      'user_id': userId,
      'shop_id': shopId,
      'category_id': categoryId,
      'brand_id': brandId,
      'photos': photos,
      'thumbnail_img': thumbnailImg,
      'video_provider': videoProvider,
      'video_link': videoLink,
      'tags': tags,
      'description': description,
      'unit_price': unitPrice,
      'purchase_price': purchasePrice,
      'variant_product': variantProduct,
      'attributes': attributes,
      'choice_options': choiceOptions,
      'colors': colors,
      'variations': variations,
      'todays_deal': todaysDeal,
      'published': published,
      'approved': approved,
      'stock_visibility_state': stockVisibilityState,
      'cash_on_delivery': cashOnDelivery,
      'featured': featured,
      'seller_featured': sellerFeatured,
      'current_stock': currentStock,
      'unit': unit,
      'weight': weight,
      'min_qty': minQty,
      'low_stock_quantity': lowStockQuantity,
      'discount': discount,
      'discount_type': discountType,
      'discount_start_date': discountStartDate?.toIso8601String(),
      'discount_end_date': discountEndDate?.toIso8601String(),
      'starting_bid': startingBid,
      'auction_start_date': auctionStartDate?.toIso8601String(),
      'auction_end_date': auctionEndDate?.toIso8601String(),
      'tax': tax,
      'tax_type': taxType,
      'shipping_type': shippingType,
      'shipping_cost': shippingCost,
      'is_quantity_multiplied': isQuantityMultiplied,
      'est_shipping_days': estShippingDays,
      'num_of_sale': numOfSale,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'meta_img': metaImg,
      'pdf': pdf,
      'slug': slug,
      'sku': sku,
      'refundable': refundable,
      'earn_point': earnPoint,
      'rating': rating,
      'barcode': barcode,
      'show_home': showHome,
      'digital': digital,
      'auction_product': auctionProduct,
      'file_name': fileName,
      'file_path': filePath,
      'external_link': externalLink,
      'external_link_btn': externalLinkBtn,
      'wholesale_product': wholesaleProduct,
      'frequently_brought_selection_type': frequentlyBroughtSelectionType,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'primary_image': primaryImage?.toJson(),
      'images': images.map((item) => item.toJson()).toList(),
      'category': category?.toJson(),
      'sub_category': subCategory?.toJson(),
      'brand': brand,
      'product_discount': productDiscount,
    };
  }

  String get plainDescription {
    final String html = description ?? '';
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&nbsp;', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  bool get isPublished => published == 1;

  bool get isApproved => approved == 1;

  bool get isOutOfStock => (currentStock ?? 0) <= 0;

  bool get isLowStock {
    final int stock = currentStock ?? 0;
    final int lowStock = lowStockQuantity ?? 0;
    return stock > 0 && lowStock > 0 && stock <= lowStock;
  }

  String imageUrl({
    String baseUrl = CompanyData.image_file_url,
  }) {
    final String? directUrl = primaryImage?.url;

    if (directUrl != null && directUrl.trim().isNotEmpty) {
      return directUrl;
    }

    final String? file = primaryImage?.fileName;

    if (file == null || file.trim().isEmpty) {
      return '';
    }

    return '$baseUrl$file';
  }
}

class ProductImage {
  final int? id;
  final String? fileOriginalName;
  final String? fileName;
  final int? userId;
  final int? fileSize;
  final String? extension;
  final String? type;
  final String? externalLink;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final String? url;

  ProductImage({
    this.id,
    this.fileOriginalName,
    this.fileName,
    this.userId,
    this.fileSize,
    this.extension,
    this.type,
    this.externalLink,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.url,
  });

  factory ProductImage.fromJson(Map<String, dynamic> json) {
    return ProductImage(
      id: _toInt(json['id']),
      fileOriginalName: json['file_original_name']?.toString(),
      fileName: json['file_name']?.toString(),
      userId: _toInt(json['user_id']),
      fileSize: _toInt(json['file_size']),
      extension: json['extension']?.toString(),
      type: json['type']?.toString(),
      externalLink: json['external_link']?.toString(),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      deletedAt: _toDateTime(json['deleted_at']),
      url: json['url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_original_name': fileOriginalName,
      'file_name': fileName,
      'user_id': userId,
      'file_size': fileSize,
      'extension': extension,
      'type': type,
      'external_link': externalLink,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'url': url,
    };
  }
}

class ProductCategory {
  final int? id;
  final int? parentId;
  final int? level;
  final String? name;
  final int? isActive;
  final int? orderLevel;
  final double? commisionRate;
  final String? banner;
  final String? icon;
  final String? coverImage;
  final int? featured;
  final int? top;
  final int? digital;
  final String? slug;
  final String? metaTitle;
  final String? metaDescription;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductCategory({
    this.id,
    this.parentId,
    this.level,
    this.name,
    this.isActive,
    this.orderLevel,
    this.commisionRate,
    this.banner,
    this.icon,
    this.coverImage,
    this.featured,
    this.top,
    this.digital,
    this.slug,
    this.metaTitle,
    this.metaDescription,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: _toInt(json['id']),
      parentId: _toInt(json['parent_id']),
      level: _toInt(json['level']),
      name: json['name']?.toString(),
      isActive: _toInt(json['is_active']),
      orderLevel: _toInt(json['order_level']),
      commisionRate: _toDouble(json['commision_rate']),
      banner: json['banner']?.toString(),
      icon: json['icon']?.toString(),
      coverImage: json['cover_image']?.toString(),
      featured: _toInt(json['featured']),
      top: _toInt(json['top']),
      digital: _toInt(json['digital']),
      slug: json['slug']?.toString(),
      metaTitle: json['meta_title']?.toString(),
      metaDescription: json['meta_description']?.toString(),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'level': level,
      'name': name,
      'is_active': isActive,
      'order_level': orderLevel,
      'commision_rate': commisionRate,
      'banner': banner,
      'icon': icon,
      'cover_image': coverImage,
      'featured': featured,
      'top': top,
      'digital': digital,
      'slug': slug,
      'meta_title': metaTitle,
      'meta_description': metaDescription,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class ProductPaginationLink {
  final String? url;
  final String? label;
  final bool? active;

  ProductPaginationLink({
    this.url,
    this.label,
    this.active,
  });

  factory ProductPaginationLink.fromJson(Map<String, dynamic> json) {
    return ProductPaginationLink(
      url: json['url']?.toString(),
      label: json['label']?.toString(),
      active: _toBool(json['active']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'label': label,
      'active': active,
    };
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is num) return value.toInt();

  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();

  return double.tryParse(value.toString());
}

bool? _toBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is int) return value == 1;

  final String text = value.toString().toLowerCase().trim();

  if (text == 'true' || text == '1') return true;
  if (text == 'false' || text == '0') return false;

  return null;
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;

  final String dateText = value.toString().trim();

  if (dateText.isEmpty) return null;

  return DateTime.tryParse(dateText);
}