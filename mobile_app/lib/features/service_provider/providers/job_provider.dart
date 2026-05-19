// lib/features/service_provider/providers/job_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ease_home_service/core/services/api_client.dart'; // adjust import path as needed
import 'package:cloud_firestore/cloud_firestore.dart';

// Model for a Job Request (simplified)
class JobRequest {
  final String id;
  final String description;
  final String status; // e.g., pending, accepted, declined, countered
  final Map<String, dynamic> details;

  JobRequest({
    required this.id,
    required this.description,
    required this.status,
    required this.details,
  });

  factory JobRequest.fromJson(Map<String, dynamic> json) => JobRequest(
        id: json['id'] as String,
        description: json['description'] as String,
        status: json['status'] as String,
        details: json['details'] as Map<String, dynamic>? ?? {},
      );
}

class JobProvider {
  final ApiClient _api;
  JobProvider(this._api);

  // GET /provider/job-requests
  Future<List<JobRequest>> getJobRequests() async {
    final response = await _api.get('/provider/job-requests');
    final List data = response.data as List;
    return data.map((e) => JobRequest.fromJson(e as Map<String, dynamic>)).toList();
  }

  // PATCH /provider/job-requests/:id
  // action: accept | decline | counter, optional price for counter
  Future<void> respondToJob({
    required String jobId,
    required String action, // "accept", "decline", "counter"
    double? price,
  }) async {
    final payload = {
      'action': action,
      if (price != null) 'price': price,
    };
    await _api.patch('/provider/job-requests/$jobId', data: payload);
  }

  // PATCH /bookings/:id/update-stage (used for job stage updates)
  Future<void> updateJobStage({
    required String bookingId,
    required String stage,
  }) async {
    await _api.patch('/bookings/$bookingId/update-stage', data: {'stage': stage});
  }

  // Firestore stream for active job for a provider
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchActiveJob(String providerId) {
    return FirebaseFirestore.instance
        .collection('providers')
        .doc(providerId)
        .collection('activeJob')
        .snapshots()
        .map((qs) => qs.docs.isNotEmpty ? qs.docs.first : DocumentSnapshot<Map<String, dynamic>>.empty);
  }

  // PATCH /provider/status to update online status
  Future<void> updateOnlineStatus({required bool isOnline}) async {
    await _api.patch('/provider/status', data: {'online': isOnline});
  }

  // POST /provider/dispute/:id/respond
  Future<void> respondToDispute({
    required String disputeId,
    required String position, // e.g., "provider" or "customer"
    required List<String> evidenceUrls,
    required String statement,
    required String resolution,
  }) async {
    final payload = {
      'position': position,
      'evidence_urls': evidenceUrls,
      'statement': statement,
      'resolution': resolution,
    };
    await _api.post('/provider/dispute/$disputeId/respond', data: payload);
  }
}

// Riverpod provider declaration
final jobProvider = Provider<JobProvider>((ref) {
  final api = ref.watch(apiClientProvider);
  return JobProvider(api);
});
