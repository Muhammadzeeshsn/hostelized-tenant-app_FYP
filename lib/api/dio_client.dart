// lib/api/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'config.dart';

class DioClient {
  DioClient._();
  static final DioClient I = DioClient._();

  final _storage = const FlutterSecureStorage();
  late final Dio dio =
      Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 20),
            headers: {'Content-Type': 'application/json'},
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              final token = await _storage.read(key: 'accessToken');
              if (token != null)
                options.headers['Authorization'] = 'Bearer $token';
              handler.next(options);
            },
            onError: (e, handler) async {
              // simple auto-refresh
              if (e.response?.statusCode == 401) {
                final refresh = await _storage.read(key: 'refreshToken');
                if (refresh != null) {
                  try {
                    final r = await Dio(
                      BaseOptions(baseUrl: AppConfig.baseUrl),
                    ).post('/auth/refresh', data: {'refreshToken': refresh});
                    final newAccess = r.data['accessToken'] as String?;
                    if (newAccess != null) {
                      await _storage.write(
                        key: 'accessToken',
                        value: newAccess,
                      );
                      e.requestOptions.headers['Authorization'] =
                          'Bearer $newAccess';
                      final clone = await dio.fetch(e.requestOptions);
                      return handler.resolve(clone);
                    }
                  } catch (_) {}
                }
              }
              handler.next(e);
            },
          ),
        );
}
