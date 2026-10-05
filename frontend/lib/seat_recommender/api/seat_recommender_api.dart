import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../api/api_client.dart';
import '../models/seat_recommendation.dart';

class SeatRecommenderApi {
  Future<SeatRecommendationResponse> recommend(
    SeatSearchRequest request,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiClient.baseUrl}/api/v1/seats/recommend'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException('Seat search failed (${response.statusCode}).');
    }
    return SeatRecommendationResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
