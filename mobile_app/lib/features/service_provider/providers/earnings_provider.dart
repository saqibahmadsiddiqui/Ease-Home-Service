// Riverpod 2.x provider for service provider earnings & performance
// Uses the shared ApiClient (Dio) from core/services/api_client.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/services/api_client.dart'; // Adjust import path if needed
import 'package:cloud_firestore/cloud_firestore.dart';

// Models
class EarningsResponse {
  final double gross;
  final double platformFee;
  final double net;
  final List<PayoutHistoryItem> payoutHistory;

  EarningsResponse({
    required this.gross,
    required this.platformFee,
    required this.net,
    required this.payoutHistory,
  });

  factory EarningsResponse.fromJson(Map<String, dynamic> json) {
    return EarningsResponse(
      gross: (json['gross'] as num).toDouble(),
      platformFee: (json['platformFee'] as num).toDouble(),
      net: (json['net'] as num).toDouble(),
      payoutHistory: (json['payoutHistory'] as List<dynamic>)
          .map((e) => PayoutHistoryItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PayoutHistoryItem {
  final String id;
  final double amount;
  final DateTime date;

  PayoutHistoryItem({required this.id, required this.amount, required this.date});

  factory PayoutHistoryItem.fromJson(Map<String, dynamic> json) {
    return PayoutHistoryItem(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class PerformanceResponse {
  final double overallScore;
  final Map<String, double> factorBreakdown;
  final String aiInsights;
  final List<double> ratingTrend;

  PerformanceResponse({
    required this.overallScore,
    required this.factorBreakdown,
    required this.aiInsights,
    required this.ratingTrend,
  });

  factory PerformanceResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> breakdown = json['factorBreakdown'] as Map<String, dynamic>;
    return PerformanceResponse(
      overallScore: (json['overallScore'] as num).toDouble(),
      factorBreakdown: breakdown.map((k, v) => MapEntry(k, (v as num).toDouble())),
      aiInsights: json['aiInsights'] as String,
      ratingTrend: (json['ratingTrend'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );
  }
}

class AvailabilitySchedule {
  final List<DaySlot> days;

  AvailabilitySchedule({required this.days});

  Map<String, dynamic> toJson() => {
        'days': days.map((d) => d.toJson()).toList(),
      };
}

class DaySlot {
  final String day; // e.g., "MON"
  final String startTime; // HH:mm format
  final String endTime;

  DaySlot({required this.day, required this.startTime, required this.endTime});

  Map<String, dynamic> toJson() => {
        'day': day,
        'startTime': startTime,
        'endTime': endTime,
      };
}

// Provider definition
final earningsProvider = Provider<EarningsService>((ref) {
  final api = ref.watch(apiClientProvider);
  return EarningsService(api);
});

class EarningsService {
  final ApiClient _api;
  EarningsService(this._api);

  // GET /provider/earnings
  Future<EarningsResponse> getEarnings({required String period}) async {
    final response = await _api.get('/provider/earnings', queryParameters: {'period': period});
    return EarningsResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // GET /provider/performance
  Future<PerformanceResponse> getPerformance() async {
    final response = await _api.get('/provider/performance');
    return PerformanceResponse.fromJson(response.data as Map<String, dynamic>);
  }

  // GET /provider/calendar (availability)
  Future<AvailabilitySchedule> getAvailability() async {
    final response = await _api.get('/provider/calendar');
    final data = response.data as Map<String, dynamic>;
    final days = (data['days'] as List<dynamic>)
        .map((e) => DaySlot(
            day: e['day'] as String,
            startTime: e['startTime'] as String,
            endTime: e['endTime'] as String))
        .toList();
    return AvailabilitySchedule(days: days);
  }

  // PUT /provider/availability
  Future<void> updateAvailability({required AvailabilitySchedule schedule, required List<String> daysOff}) async {
    final payload = {
      'schedule': schedule.toJson(),
      'daysOff': daysOff,
    };
    await _api.put('/provider/availability', data: payload);
  }

  // GET /ai/demand-forecast/:providerId
  Future<Map<String, dynamic>> getDemandForecast({required String providerId}) async {
    final response = await _api.get('/ai/demand-forecast/$providerId');
    return response.data as Map<String, dynamic>;
  }

  // Firestore stream for active job (if needed for UI)
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchActiveJob(String providerId) {
    return FirebaseFirestore.instance
        .collection('providers')
        .doc(providerId)
        .collection('activeJob')
        .snapshots()
        .map((qs) => qs.docs.isNotEmpty ? qs.docs.first : DocumentSnapshot<Map<String, dynamic>>.empty);
  }
}
