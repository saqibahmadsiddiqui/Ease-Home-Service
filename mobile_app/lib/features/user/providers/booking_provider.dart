// lib/features/user/providers/booking_provider.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ease_home_service/core/services/api_client.dart'; // adjust import path if needed

// Model for Booking (simplified)
class Booking {
  final String id;
  final String stage;
  Booking({required this.id, required this.stage});
  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: json['id'] as String,
        stage: json['stage'] as String,
      );
}

// State class
class BookingState {
  final List<Booking> history;
  final Booking? current;
  final bool loading;
  final String? error;
  BookingState({this.history = const [], this.current, this.loading = false, this.error});

  BookingState copyWith({
    List<Booking>? history,
    Booking? current,
    bool? loading,
    String? error,
  }) =>
      BookingState(
        history: history ?? this.history,
        current: current ?? this.current,
        loading: loading ?? this.loading,
        error: error,
      );
}

class BookingNotifier extends StateNotifier<BookingState> {
  final Dio _dio;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _bookingSub;

  BookingNotifier(this._dio) : super(BookingState());

  // API: create booking
  Future<void> createBooking({
    required String intentId,
    required String providerId,
    required String slot,
    required String quoteId,
  }) async {
    state = state.copyWith(loading: true);
    try {
      final response = await _dio.post('/bookings/create', data: {
        'intent_id': intentId,
        'provider_id': providerId,
        'slot': slot,
        'quote_id': quoteId,
      });
      final booking = Booking.fromJson(response.data);
      _listenToBooking(booking.id);
      state = state.copyWith(current: booking, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  // API: confirm booking
  Future<void> confirmBooking(String bookingId) async {
    state = state.copyWith(loading: true);
    try {
      await _dio.patch('/bookings/$bookingId/confirm');
      // stage change will be observed via listener
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  // API: update stage (including cancel)
  Future<void> updateStage(String bookingId, String stage) async {
    state = state.copyWith(loading: true);
    try {
      await _dio.patch('/bookings/$bookingId/update-stage', data: {'stage': stage});
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  // convenience cancel method
  Future<void> cancelBooking(String bookingId) async =>
      updateStage(bookingId, 'CANCELLED');

  // API: complete booking
  Future<void> completeBooking({
    required String bookingId,
    required List<String> checklist,
    required List<String> evidenceUrls,
    required double finalAmount,
  }) async {
    state = state.copyWith(loading: true);
    try {
      await _dio.post('/bookings/$bookingId/complete', data: {
        'checklist': checklist,
        'evidence_urls': evidenceUrls,
        'final_amount': finalAmount,
      });
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  // API: submit review
  Future<void> submitReview({
    required String bookingId,
    required int rating,
    required String text,
    required List<String> photos,
    required List<String> chips,
  }) async {
    state = state.copyWith(loading: true);
    try {
      await _dio.post('/bookings/$bookingId/review', data: {
        'rating': rating,
        'text': text,
        'photos': photos,
        'chips': chips,
      });
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  // API: get booking history
  Future<void> getHistory({Map<String, dynamic>? filters}) async {
    state = state.copyWith(loading: true);
    try {
      final response = await _dio.get('/bookings/history', queryParameters: filters);
      final List<Booking> list = (response.data as List)
          .map((e) => Booking.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(history: list, loading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), loading: false);
    }
  }

  // API: get receipt
  Future<Map<String, dynamic>?> getReceipt(String bookingId) async {
    try {
      final response = await _dio.get('/bookings/$bookingId/receipt');
      return response.data as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // Firestore realtime listener for a specific booking
  void _listenToBooking(String bookingId) {
    _bookingSub?.cancel();
    _bookingSub = _firestore
        .collection('bookings')
        .doc(bookingId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        final updated = Booking.fromJson(data);
        state = state.copyWith(current: updated);
      }
    });
  }

  @override
  void dispose() {
    _bookingSub?.cancel();
    super.dispose();
  }
}

// Provider declaration (adjust the provider name as needed)
final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final dio = ref.watch(apiClientProvider);
  return BookingNotifier(dio);
});
