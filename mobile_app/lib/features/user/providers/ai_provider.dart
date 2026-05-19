// lib/features/user/providers/ai_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:ease_home_service/core/services/api_client.dart'; // adjust import if needed

// Simple model classes (can be expanded as needed)
class IntentResponse {
  final Map<String, dynamic> intent;
  final double confidence;
  final List<String> clarificationPrompts;
  IntentResponse({required this.intent, required this.confidence, required this.clarificationPrompts});
  factory IntentResponse.fromJson(Map<String, dynamic> json) => IntentResponse(
        intent: json['intent'] as Map<String, dynamic>,
        confidence: (json['confidence'] as num).toDouble(),
        clarificationPrompts: List<String>.from(json['clarification_prompts'] ?? []),
      );
}

class ProviderRanking {
  final String providerId;
  final double matchScore;
  final Map<String, dynamic> details;
  ProviderRanking({required this.providerId, required this.matchScore, required this.details});
  factory ProviderRanking.fromJson(Map<String, dynamic> json) => ProviderRanking(
        providerId: json['provider_id'] as String,
        matchScore: (json['match_score'] as num).toDouble(),
        details: json['details'] as Map<String, dynamic>,
      );
}

class QuoteResponse {
  final double finalPrice;
  final List<Map<String, dynamic>> breakdown;
  final Map<String, dynamic>? alternativeProvider;
  QuoteResponse({required this.finalPrice, required this.breakdown, this.alternativeProvider});
  factory QuoteResponse.fromJson(Map<String, dynamic> json) => QuoteResponse(
        finalPrice: (json['final_price'] as num).toDouble(),
        breakdown: List<Map<String, dynamic>>.from(json['breakdown'] ?? []),
        alternativeProvider: json['alternative_provider'] as Map<String, dynamic>?,
      );
}

class ScheduleResponse {
  final String status;
  final Map<String, dynamic>? details;
  ScheduleResponse({required this.status, this.details});
  factory ScheduleResponse.fromJson(Map<String, dynamic> json) => ScheduleResponse(
        status: json['status'] as String,
        details: json['details'] as Map<String, dynamic>?,
      );
}

class DisputeAnalysis {
  final String disputeType;
  final String resolution;
  final double confidence;
  DisputeAnalysis({required this.disputeType, required this.resolution, required this.confidence});
  factory DisputeAnalysis.fromJson(Map<String, dynamic> json) => DisputeAnalysis(
        disputeType: json['dispute_type'] as String,
        resolution: json['resolution'] as String,
        confidence: (json['confidence'] as num).toDouble(),
      );
}

class AIRepository {
  final Dio _dio;
  AIRepository(this._dio);

  Future<IntentResponse> sendIntent({required String text, required String lang, required Map<String, dynamic>? userContext}) async {
    final response = await _dio.post('/ai/intent', data: {
      'text': text,
      'lang': lang,
      if (userContext != null) 'user_context': userContext,
    });
    return IntentResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<ProviderRanking>> getProviderRankings({required Map<String, dynamic> intent, required Map<String, double> userLocation, Map<String, dynamic>? filters}) async {
    final response = await _dio.post('/ai/match-providers', data: {
      'intent': intent,
      'user_location': userLocation,
      if (filters != null) 'filters': filters,
    });
    final List list = response.data as List;
    return list.map((e) => ProviderRanking.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<QuoteResponse> getQuote({required String providerId, required Map<String, dynamic> intent, required double distance}) async {
    final response = await _dio.post('/ai/get-quote', data: {
      'provider_id': providerId,
      'intent': intent,
      'distance': distance,
    });
    return QuoteResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ScheduleResponse> scheduleSlot({required String providerId, required Map<String, dynamic> preferredSlot, required Map<String, dynamic> intent}) async {
    final response = await _dio.post('/ai/schedule', data: {
      'provider_id': providerId,
      'preferred_slot': preferredSlot,
      'intent': intent,
    });
    return ScheduleResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DisputeAnalysis> analyzeDispute({required String disputeId, required List<String> evidenceUrls}) async {
    final response = await _dio.post('/ai/analyze-dispute', data: {
      'dispute_id': disputeId,
      'evidence': evidenceUrls,
    });
    return DisputeAnalysis.fromJson(response.data as Map<String, dynamic>);
  }
}

// Riverpod provider exposing AIRepository
final aiProvider = Provider<AIRepository>((ref) {
  final dio = ref.watch(apiClientProvider);
  return AIRepository(dio);
});
