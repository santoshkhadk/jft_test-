import 'package:flutter/material.dart';
import '../services/payment_service.dart';

// ─── Auth Provider ────────────────────────────────────────────────────────
class AuthProvider extends ChangeNotifier {
  bool _hasAccess = false;
  bool _isChecking = true;

  bool get hasAccess => _hasAccess;
  bool get isChecking => _isChecking;

  Future<void> checkAccess() async {
    _isChecking = true;
    notifyListeners();
    _hasAccess = await PaymentService().hasAccess();
    _isChecking = false;
    notifyListeners();
  }

  void grantAccess() {
    _hasAccess = true;
    notifyListeners();
  }

  void revokeAccess() {
    _hasAccess = false;
    notifyListeners();
  }
}