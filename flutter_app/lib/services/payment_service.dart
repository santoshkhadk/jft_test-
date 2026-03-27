import '../models/payment_status.dart';

class PaymentService {
  Future<bool> hasAccess() async => true;

  Future<PaymentStatus> makePayment() async {
    // Placeholder: always returns success
    return PaymentStatus.success;
  }
}

// Dummy Constants
class Constants {
  static const esewaClientId = 'dummy_client_id';
  static const esewaSecret = 'dummy_secret';
  static const paymentCallbackUrl = 'https://dummy.callback';
}

// Dummy SDKs
class EsewaConfig {}
class EsewaFlutterSdk {
  static Future<PaymentStatus> initPayment() async => PaymentStatus.success;
}
class ESewaPayment {}
class DeviceInfoPlugin {
  Future<String> getDeviceId() async => 'dummy_device_id';
}
class ApiService {
  static Future<String> post(String path, Map<String, dynamic> body) async => 'dummy_token';
}
class SecureStorage {
  static Future<void> write(String key, String value) async {}
}