import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';
import 'package:ecom_delivery_flutter/app/models/location_model.dart';

class SellerRegisterRepository {
  SellerRegisterRepository({APIManager? apiManager})
      : _apiManager = apiManager ?? APIManager();

  final APIManager _apiManager;

  Future<Map<String, dynamic>> createSeller(
    Map<String, dynamic> payload,
  ) {
    var response = _apiManager.postPublicJsonStatus(ApiClient.createSeller, payload);
    return response;
  }

  Future<List<DivisionModel>> getDivisions() async {
    final response = await _apiManager.getPublicJsonStatus(ApiClient.divisions);
    final body = response['body'];

    print("my data 45308 $body");
    if (body is Map && body['data'] is List) {
      return (body['data'] as List)
          .map((e) => DivisionModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<List<DistrictModel>> getDistricts(int divisionId) async {
    final response = await _apiManager
        .getPublicJsonStatus(ApiClient.districtsByDivision(divisionId));
    final body = response['body'];
    if (body is Map && body['data'] is List) {
      return (body['data'] as List)
          .map((e) => DistrictModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  Future<List<UpazilaModel>> getUpazilas(int districtId) async {
    final response = await _apiManager
        .getPublicJsonStatus(ApiClient.upazilasByDistrict(districtId));
    final body = response['body'];
    if (body is Map && body['data'] is List) {
      return (body['data'] as List)
          .map((e) => UpazilaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }
}
