import 'package:flutter/material.dart';

class QuestionProvider extends ChangeNotifier {
  bool _loading = false;
  List<Map<String, dynamic>> _categories  = [];
  List<Map<String, dynamic>> _currentSets = [];

  bool get loading                         => _loading;
  List<Map<String, dynamic>> get categories  => _categories;
  List<Map<String, dynamic>> get currentSets => _currentSets;

  void setLoading(bool v)                              { _loading = v; notifyListeners(); }
  void setCategories(List<Map<String, dynamic>> c)     { _categories = c; notifyListeners(); }
  void setSets(List<Map<String, dynamic>> s)           { _currentSets = s; notifyListeners(); }
}