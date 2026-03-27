import 'package:flutter/material.dart';
import '../services/payment_service.dart';

class QuestionProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _currentSets = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get categories => _categories;
  List<Map<String, dynamic>> get currentSets => _currentSets;

  void setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void setCategories(List<Map<String, dynamic>> cats) {
    _categories = cats;
    notifyListeners();
  }

  void setSets(List<Map<String, dynamic>> sets) {
    _currentSets = sets;
    notifyListeners();
  }

  void setError(String e) {
    _error = e;
    _isLoading = false;
    notifyListeners();
  }
}