class DivisionModel {
  final int id;
  final String name;
  final String bnName;
  final String? url;

  DivisionModel({
    required this.id,
    required this.name,
    required this.bnName,
    this.url,
  });

  factory DivisionModel.fromJson(Map<String, dynamic> json) {
    return DivisionModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      bnName: json['bn_name']?.toString() ?? '',
      url: json['url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'bn_name': bnName,
        'url': url,
      };

  String get displayName =>
      bnName.isNotEmpty ? '$name ($bnName)' : name;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) || bnName.toLowerCase().contains(q);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DivisionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DistrictModel {
  final int id;
  final int? divisionId;
  final String name;
  final String bnName;
  final String? lat;
  final String? lon;
  final String? url;

  DistrictModel({
    required this.id,
    this.divisionId,
    required this.name,
    required this.bnName,
    this.lat,
    this.lon,
    this.url,
  });

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      divisionId: json['division_id'] is int
          ? json['division_id'] as int
          : int.tryParse(json['division_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      bnName: json['bn_name']?.toString() ?? '',
      lat: json['lat']?.toString(),
      lon: json['lon']?.toString(),
      url: json['url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'division_id': divisionId,
        'name': name,
        'bn_name': bnName,
        'lat': lat,
        'lon': lon,
        'url': url,
      };

  String get displayName =>
      bnName.isNotEmpty ? '$name ($bnName)' : name;

  num? get numericLat =>
      lat != null && lat!.trim().isNotEmpty ? double.tryParse(lat!.trim()) : null;

  num? get numericLon =>
      lon != null && lon!.trim().isNotEmpty ? double.tryParse(lon!.trim()) : null;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) || bnName.toLowerCase().contains(q);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DistrictModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class UpazilaModel {
  final int id;
  final int? districtId;
  final String name;
  final String bnName;
  final String? url;

  UpazilaModel({
    required this.id,
    this.districtId,
    required this.name,
    required this.bnName,
    this.url,
  });

  factory UpazilaModel.fromJson(Map<String, dynamic> json) {
    return UpazilaModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      districtId: json['district_id'] is int
          ? json['district_id'] as int
          : int.tryParse(json['district_id']?.toString() ?? ''),
      name: json['name']?.toString() ?? '',
      bnName: json['bn_name']?.toString() ?? '',
      url: json['url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'district_id': districtId,
        'name': name,
        'bn_name': bnName,
        'url': url,
      };

  String get displayName =>
      bnName.isNotEmpty ? '$name ($bnName)' : name;

  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    return name.toLowerCase().contains(q) || bnName.toLowerCase().contains(q);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpazilaModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
