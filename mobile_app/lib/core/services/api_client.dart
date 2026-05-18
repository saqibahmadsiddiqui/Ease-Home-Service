import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Provider for the Dio HTTP client
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: dotenv.env['BACKEND_URL'] ?? 'http://localhost:8000',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    contentType: 'application/json',
    responseType: ResponseType.json,
  ));

  // Attach JWT interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await ref.read(authTokenProvider.future);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioError err, handler) async {
      // If 401, attempt token refresh
      if (err.response?.statusCode == 401) {
        final refreshed = await ref.read(authRepositoryProvider).refreshToken();
        if (refreshed != null) {
          // retry original request with new token
          err.requestOptions.headers['Authorization'] = 'Bearer $refreshed';
          final cloneReq = await dio.request(err.requestOptions.path,
              data: err.requestOptions.data,
              queryParameters: err.requestOptions.queryParameters,
              options: Options(
                method: err.requestOptions.method,
                headers: err.requestOptions.headers,
              ));
          return handler.resolve(cloneReq);
        }
      }
      return handler.next(err);
    },
  ));

  return dio;
});

/// Simple token holder – refreshed via AuthRepository
final authTokenProvider = StateProvider<String?>((ref) => null);

/// Repository exposing auth‑related network calls
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.read));

class AuthRepository {
  final Reader _read;
  AuthRepository(this._read);

  Future<String?> refreshToken() async {
    try {
      final response = await _read(dioProvider).post('/auth/refresh');
      final newToken = response.data['access_token'] as String?;
      if (newToken != null) {
        _read(authTokenProvider.notifier).state = newToken;
        return newToken;
      }
    } catch (e) {
      // ignore – caller will handle unauthenticated state
    }
    return null;
  }
}
