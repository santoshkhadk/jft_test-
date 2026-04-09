import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constants.dart';

class ApiClient {
  static final ApiClient _i = ApiClient._();
  factory ApiClient() => _i;
  ApiClient._();

  final Dio dio = Dio(BaseOptions(
    baseUrl: AppConstants.apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {'Content-Type': 'application/json'},
  ))
    ..interceptors.add(_TokenInterceptor());
}

class _TokenInterceptor extends Interceptor {
  final _s = const FlutterSecureStorage();

  @override
  Future<void> onRequest(RequestOptions o, RequestInterceptorHandler h) async {
    final t = await _s.read(key: AppConstants.tokenKey);
    if (t != null) o.headers['Authorization'] = 'Token $t';
    h.next(o);
  }
}