import 'package:ecom_delivery_flutter/app/api_providers/api_manager.dart';
import 'package:ecom_delivery_flutter/app/api_providers/api_url.dart';

class ChallengeRepository {
  final APIManager _apiManager = APIManager();

  /// 1. Fetch Challenges list for a shop
  Future<dynamic> fetchChallenges({
    required dynamic shopId,
  }) async {
    final url = ApiClient.sellerChallenges(shopId);
    final response = await _apiManager.getWithHeader(
      url,
      {'Accept': 'application/json'},
    );
    return response;
  }

  /// 2. Create a new challenge
  Future<Map<String, dynamic>> createChallenge({
    required Map<String, dynamic> body,
  }) async {
    const url = ApiClient.createSellerChallenge;
    final response = await _apiManager.postJsonWithHeaderStatus(url, body, {});
    return response;
  }

  /// 3. Fetch Challenge Statistics
  Future<Map<String, dynamic>> fetchStatistics({
    required dynamic challengeId,
  }) async {
    final url = ApiClient.challengeStatistics(challengeId);
    final response = await _apiManager.getWithHeaderStatus(url, {});
    return response;
  }

  /// 4. Fetch Challenge Participants / Leaderboard
  Future<Map<String, dynamic>> fetchParticipants({
    required dynamic challengeId,
    int page = 1,
    int perPage = 20,
  }) async {
    final url = ApiClient.challengeParticipants(
      challengeId,
      page: page,
      perPage: perPage,
    );
    final response = await _apiManager.getWithHeaderStatus(url, {});
    return response;
  }

  /// 5. Delete a challenge
  Future<Map<String, dynamic>> deleteChallenge({
    required dynamic challengeId,
  }) async {
    final url = ApiClient.deleteSellerChallenge(challengeId);
    final response = await _apiManager.deleteWithHeaderStatus(url, {});
    return response;
  }

  /// 6. Toggle a challenge status
  Future<Map<String, dynamic>> toggleChallengeStatus({
    required dynamic challengeId,
    required bool isActive,
  }) async {
    final url = ApiClient.toggleSellerChallengeStatus(challengeId);
    final response = await _apiManager.patchJsonWithHeaderStatus(
      url,
      {'is_active': isActive},
      {},
    );
    return response;
  }
}
