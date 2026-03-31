import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:uuid/uuid.dart';
import '../core/constants.dart';
import '../core/api_client.dart';

enum PaymentMethod { esewa, khalti }
enum PaymentStatus { success, failed, cancelled }

class PaymentService {
  static final PaymentService _i = PaymentService._();
  factory PaymentService() => _i;
  PaymentService._();

  final _dio     = ApiClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<bool> hasAccess() async {
    final token    = await _storage.read(key: AppConstants.tokenKey);
    if (token == null) return false;
    try {
      final deviceId = await getDeviceId();
      final r = await _dio.post('/auth/validate-token/',
          data: {'token': token, 'device_id': deviceId});
      return r.data['valid'] == true;
    } catch (_) { return false; }
  }

  Map<String, String> buildEsewaParams({
    required double amount, required String productId, required String productName,
  }) {
    final txnId = const Uuid().v4();
    final msg   = 'total_amount=$amount,transaction_uuid=$txnId,product_code=${AppConstants.esewaClientId}';
    final sig   = base64.encode(
        Hmac(sha256, utf8.encode(AppConstants.esewaSecretKey))
            .convert(utf8.encode(msg)).bytes);
    return {
      'amount': amount.toStringAsFixed(2),
      'tax_amount': '0',
      'total_amount': amount.toStringAsFixed(2),
      'transaction_uuid': txnId,
      'product_code': AppConstants.esewaClientId,
      'product_service_charge': '0',
      'product_delivery_charge': '0',
      'success_url': '\${AppConstants.apiBaseUrl}/payments/esewa/success/',
      'failure_url': '\${AppConstants.apiBaseUrl}/payments/esewa/failure/',
      'signed_field_names': 'total_amount,transaction_uuid,product_code',
      'signature': sig,
    };
  }

  Future<PaymentStatus> verifyEsewa(String encodedData) async {
    try {
      final deviceId = await getDeviceId();
      final r = await _dio.post('/payments/esewa/verify/',
          data: {'encoded_data': encodedData, 'device_id': deviceId});
      if (r.data['success'] == true) {
        await _storage.write(key: AppConstants.tokenKey, value: r.data['access_token'] as String);
        return PaymentStatus.success;
      }
      return PaymentStatus.failed;
    } catch (_) { return PaymentStatus.failed; }
  }

  Future<String?> initiateKhalti({
    required double amount, required String orderId, required String orderName,
  }) async {
    try {
      final r = await _dio.post('/payments/khalti/initiate/', data: {
        'amount': (amount * 100).toInt(),
        'purchase_order_id': orderId,
        'purchase_order_name': orderName,
        'return_url': '\${AppConstants.apiBaseUrl}/payments/khalti/callback/',
        'website_url': 'https://jftmocktest.com',
      });
      return r.data['payment_url'] as String?;
    } catch (_) { return null; }
  }

  Future<PaymentStatus> verifyKhalti(String pidx) async {
    try {
      final deviceId = await getDeviceId();
      final r = await _dio.post('/payments/khalti/verify/',
          data: {'pidx': pidx, 'device_id': deviceId});
      if (r.data['success'] == true) {
        await _storage.write(key: AppConstants.tokenKey, value: r.data['access_token'] as String);
        return PaymentStatus.success;
      }
      return PaymentStatus.failed;
    } catch (_) { return PaymentStatus.failed; }
  }

  Future<String> getDeviceId() async {
    final stored = await _storage.read(key: AppConstants.deviceIdKey);
    if (stored != null) return stored;
    final info = DeviceInfoPlugin();
    String id;
    try { id = (await info.androidInfo).id; }
    catch (_) {
      try { id = (await info.iosInfo).identifierForVendor ?? const Uuid().v4(); }
      catch (_) { id = const Uuid().v4(); }
    }
    await _storage.write(key: AppConstants.deviceIdKey, value: id);
    return id;
  }
}