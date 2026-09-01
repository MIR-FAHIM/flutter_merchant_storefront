class StoreCategoryModel {
  final int? id;
  final int? parentId;
  final String name;
  final String slug;
  final String? icon;
  final String? coverImage;
  final String? banner;
  final List<StoreCategoryModel> children;

  StoreCategoryModel({
    this.id,
    this.parentId,
    required this.name,
    required this.slug,
    this.icon,
    this.coverImage,
    this.banner,
    this.children = const [],
  });

  factory StoreCategoryModel.fromJson(Map<String, dynamic> json) {
    final List<StoreCategoryModel> children = (json['children'] is List)
        ? (json['children'] as List)
            .whereType<Map>()
            .map((item) => StoreCategoryModel.fromJson(Map<String, dynamic>.from(item)))
            .toList()
        : <StoreCategoryModel>[];

    return StoreCategoryModel(
      id: int.tryParse(json['id']?.toString() ?? ''),
      parentId: int.tryParse(json['parent_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? 'Category',
      slug: json['slug']?.toString() ?? '',
      icon: json['icon']?.toString(),
      coverImage: json['cover_image']?.toString(),
      banner: json['banner']?.toString(),
      children: children,
    );
  }

  static List<StoreCategoryModel> fromList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => StoreCategoryModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (data is Map) {
      final payload = Map<String, dynamic>.from(data);
      final rootData = payload['data'];
      if (rootData is List) {
        return StoreCategoryModel.fromList(rootData);
      }
      if (rootData is Map) {
        final nestedList = rootData['categories'] ?? rootData['items'] ?? rootData['result'];
        return StoreCategoryModel.fromList(nestedList);
      }
    }

    return const <StoreCategoryModel>[];
  }

  bool get hasChildren => children.isNotEmpty;
}
