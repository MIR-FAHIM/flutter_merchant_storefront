class DeliveryManRequestModel {
  final String name;
  final String mobile;
  final int shopId;
  final String? email;
  final String? password;
  final String? fatherName;
  final String? fatherContact;
  final String? emergencyContact;
  final String? address;
  final String? type;
  final double? earning;
  final String? status;
  final bool? isVerified;
  final String? note;

  DeliveryManRequestModel({
    required this.name,
    required this.mobile,
    required this.shopId,
    this.email,
    this.password,
    this.fatherName,
    this.fatherContact,
    this.emergencyContact,
    this.address,
    this.type,
    this.earning,
    this.status,
    this.isVerified,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'mobile': mobile,
      'shop_id': shopId,
      if (email != null && email!.trim().isNotEmpty) 'email': email!.trim(),
      if (password != null && password!.trim().isNotEmpty) 'password': password!.trim(),
      if (fatherName != null && fatherName!.trim().isNotEmpty) 'father_name': fatherName!.trim(),
      if (fatherContact != null && fatherContact!.trim().isNotEmpty) 'father_contact': fatherContact!.trim(),
      if (emergencyContact != null && emergencyContact!.trim().isNotEmpty) 'emergency_contact': emergencyContact!.trim(),
      if (address != null && address!.trim().isNotEmpty) 'address': address!.trim(),
      if (type != null && type!.trim().isNotEmpty) 'type': type!.trim(),
      if (earning != null) 'earning': earning,
      if (status != null && status!.trim().isNotEmpty) 'status': status!.trim(),
      if (isVerified != null) 'is_verified': isVerified,
      if (note != null && note!.trim().isNotEmpty) 'note': note!.trim(),
    };
  }
}

class DeliveryManResponseModel {
  final String? status;
  final String? message;
  final Map<String, dynamic>? data;

  DeliveryManResponseModel({
    this.status,
    this.message,
    this.data,
  });

  factory DeliveryManResponseModel.fromJson(Map<String, dynamic> json) {
    return DeliveryManResponseModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? Map<String, dynamic>.from(json['data'])
          : null,
    );
  }

  bool get isSuccess =>
      status?.toLowerCase() == 'success' ||
      status?.toLowerCase() == 'true' ||
      status == '200' ||
      status == '201';
}

class DeliveryManItem {
  final int? id;
  final String? name;
  final String? mobile;
  final String? email;
  final int? shopId;
  final String? fatherName;
  final String? fatherContact;
  final String? emergencyContact;
  final String? address;
  final String? type;
  final double? earning;
  final String? status;
  final bool? isVerified;
  final String? note;
  final String? avatar;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DeliveryManItem({
    this.id,
    this.name,
    this.mobile,
    this.email,
    this.shopId,
    this.fatherName,
    this.fatherContact,
    this.emergencyContact,
    this.address,
    this.type,
    this.earning,
    this.status,
    this.isVerified,
    this.note,
    this.avatar,
    this.createdAt,
    this.updatedAt,
  });

  factory DeliveryManItem.fromJson(Map<String, dynamic> json) {
    return DeliveryManItem(
      id: _toInt(json['id']),
      name: json['name']?.toString() ?? json['full_name']?.toString(),
      mobile: json['mobile']?.toString() ?? json['phone']?.toString(),
      email: json['email']?.toString(),
      shopId: _toInt(json['shop_id'] ?? json['store_id']),
      fatherName: json['father_name']?.toString(),
      fatherContact: json['father_contact']?.toString(),
      emergencyContact: json['emergency_contact']?.toString(),
      address: json['address']?.toString(),
      type: json['type']?.toString(),
      earning: _toDouble(json['earning']),
      status: json['status']?.toString(),
      isVerified: json['is_verified'] == true ||
          json['is_verified']?.toString() == '1' ||
          json['is_verified']?.toString() == 'true',
      note: json['note']?.toString(),
      avatar: json['avatar']?.toString() ?? json['avatar_original']?.toString(),
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
    );
  }
}

class DeliveryMenListResponseModel {
  final String? status;
  final String? message;
  final List<DeliveryManItem> items;
  final int currentPage;
  final int lastPage;
  final int total;
  final int perPage;

  DeliveryMenListResponseModel({
    this.status,
    this.message,
    this.items = const [],
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
    this.perPage = 20,
  });

  factory DeliveryMenListResponseModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];

    List<DeliveryManItem> parsedItems = [];
    int parsedCurrentPage = 1;
    int parsedLastPage = 1;
    int parsedTotal = 0;
    int parsedPerPage = 20;

    if (rawData is List) {
      parsedItems = rawData
          .whereType<Map>()
          .map((e) => DeliveryManItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      parsedTotal = parsedItems.length;
    } else if (rawData is Map<String, dynamic>) {
      parsedCurrentPage = _toInt(rawData['current_page']) ?? 1;
      parsedLastPage = _toInt(rawData['last_page']) ?? 1;
      parsedTotal = _toInt(rawData['total']) ?? 0;
      parsedPerPage = _toInt(rawData['per_page']) ?? 20;

      final dynamic listObj = rawData['data'] ?? rawData['delivery_men'] ?? rawData['items'];
      if (listObj is List) {
        parsedItems = listObj
            .whereType<Map>()
            .map((e) => DeliveryManItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    }

    return DeliveryMenListResponseModel(
      status: json['status']?.toString(),
      message: json['message']?.toString(),
      items: parsedItems,
      currentPage: parsedCurrentPage,
      lastPage: parsedLastPage,
      total: parsedTotal > 0 ? parsedTotal : parsedItems.length,
      perPage: parsedPerPage,
    );
  }

  bool get isSuccess =>
      status?.toLowerCase() == 'success' ||
      status?.toLowerCase() == 'true' ||
      status == '200' ||
      status == '201';
}

class DeliveryManException implements Exception {
  final int statusCode;
  final String message;

  DeliveryManException({
    required this.statusCode,
    required this.message,
  });

  @override
  String toString() => 'DeliveryManException($statusCode): $message';
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString());
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) return null;
  final String text = value.toString().trim();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}
