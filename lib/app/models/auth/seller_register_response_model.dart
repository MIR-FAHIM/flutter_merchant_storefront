class SellerRegisterResponse {
  SellerRegisterResponse({
    required this.statusCode,
    required this.body,
  });

  factory SellerRegisterResponse.fromJson(Map<String, dynamic> response) {
    return SellerRegisterResponse(
      statusCode: response['status_code'] as int? ?? 0,
      body: response['body'],
    );
  }

  final int statusCode;
  final dynamic body;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;

  String get message {
    if (body is Map && body['message'] != null) {
      return body['message'].toString();
    }
    if (isSuccess) return 'Seller and shop created successfully';
    return 'Registration failed. Please try again.';
  }

  Map<String, List<String>> get fieldErrors {
    if (body is! Map || body['errors'] is! Map) return {};

    final errors = <String, List<String>>{};
    (body['errors'] as Map).forEach((key, value) {
      if (value is List) {
        errors[key.toString()] = value.map((item) => item.toString()).toList();
      } else if (value != null) {
        errors[key.toString()] = [value.toString()];
      }
    });
    return errors;
  }

  Map<String, dynamic> get data {
    if (body is Map && body['data'] is Map) {
      return Map<String, dynamic>.from(body['data']);
    }
    return {};
  }
}
