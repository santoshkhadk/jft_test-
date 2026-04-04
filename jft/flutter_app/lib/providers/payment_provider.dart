import 'package:flutter/material.dart';
import '../services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  bool _loading = false;
  PaymentStatus? _status;
  String? _error;
  bool get loading        => _loading;
  PaymentStatus? get status => _status;
  String? get error       => _error;

  void setLoading(bool v)          { _loading = v; notifyListeners(); }
  void setStatus(PaymentStatus s)  { _status = s; _loading = false; notifyListeners(); }
  void setError(String e)          { _error = e; _loading = false; notifyListeners(); }
  void reset()                     { _loading = false; _status = null; _error = null; notifyListeners(); }
}