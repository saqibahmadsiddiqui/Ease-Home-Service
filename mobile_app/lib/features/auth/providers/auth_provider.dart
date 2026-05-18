import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../core/services/api_client.dart';
import '../../core/constants/app_strings.dart'; // assume contains role strings

/// Holds the current authenticated user information
class AuthUser {
  final String uid;
  final String role; // "user", "provider", "admin"
  final String? name;
  final String? phone;

  const AuthUser({required this.uid, required this.role, this.name, this.phone});

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        uid: json['uid'] as String,
        role: json['role'] as String,
        name: json['full_name'] as String?,
        phone: json['phone'] as String?,
      );
}

/// StateNotifier for auth flow
class AuthNotifier extends StateNotifier<AsyncValue<AuthUser?>> {
  final Reader _read;
  AuthNotifier(this._read) : super(const AsyncValue.loading()) {
    // Attempt to load stored token/user on start
    _init();
  }

  Future<void> _init() async {
    final token = _read(authTokenProvider).state;
    if (token != null && token.isNotEmpty) {
      await fetchCurrentUser();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> register({required String phone, required String role, required String name}) async {
    state = const AsyncValue.loading();
    try {
      final response = await _read(dioProvider).post('/auth/register', data: {
        'phone': phone,
        'role': role,
        'name': name,
        // Assume client already obtained a Firebase ID token via native SDK and passes it
        'firebase_id_token': await _obtainFirebaseIdToken(),
      });
      final data = response.data as Map<String, dynamic>;
      _read(authTokenProvider.notifier).state = data['access_token'] as String?;
      await fetchCurrentUser();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> verifyOtp({required String phone}) async {
    state = const AsyncValue.loading();
    try {
      final response = await _read(dioProvider).post('/auth/verify-otp', data: {
        'phone': phone,
        'firebase_id_token': await _obtainFirebaseIdToken(),
      });
      final data = response.data as Map<String, dynamic>;
      _read(authTokenProvider.notifier).state = data['access_token'] as String?;
      await fetchCurrentUser();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      final response = await _read(dioProvider).get('/auth/me');
      final user = AuthUser.fromJson(response.data as Map<String, dynamic>);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signOut() async {
    _read(authTokenProvider.notifier).state = null;
    state = const AsyncValue.data(null);
    // Optionally clear any persisted token storage
  }

  // Placeholder – in a real app this would call Firebase Auth SDK to get the current ID token
  Future<String> _obtainFirebaseIdToken() async {
    // For demonstration, return an empty string; the native side must implement.
    return '';
  }
}

/// Riverpod provider for AuthNotifier
final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<AuthUser?>>((ref) => AuthNotifier(ref.read));
