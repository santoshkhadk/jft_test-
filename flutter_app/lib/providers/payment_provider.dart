
import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../models/payment_status.dart';
// ─── Payment Provider ─────────────────────────────────────────────────────
class PaymentProvider extends ChangeNotifier {
  bool _isProcessing = false;
  PaymentStatus? _lastStatus;
  String? _error;

  bool get isProcessing => _isProcessing;
  PaymentStatus? get lastStatus => _lastStatus;
  String? get error => _error;

  void setProcessing(bool v) {
    _isProcessing = v;
    notifyListeners();
  }

  void setStatus(PaymentStatus status) {
    _lastStatus = status;
    _isProcessing = false;
    notifyListeners();
  }

  void setError(String e) {
    _error = e;
    _isProcessing = false;
    notifyListeners();
  }

  void reset() {
    _isProcessing = false;
    _lastStatus = null;
    _error = null;
    notifyListeners();
  }
}

