import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/payment_screen.dart';
import '../screens/category_screen.dart';
import '../screens/test_screen.dart';
import '../screens/result_screen.dart';
import '../models/question_set.dart';
import '../models/test_result.dart';

class AppRoutes {
  static const String splash   = '/';
  static const String login    = '/login';
  static const String payment  = '/payment';
  static const String category = '/category';
  static const String test     = '/test';
  static const String result   = '/result';

  static Route<dynamic> generateRoute(RouteSettings s) {
    switch (s.name) {
      case splash:   return _go(const SplashScreen());
      case login:    return _go(const LoginScreen());
      case payment:  return _go(const PaymentScreen());
      case category: return _go(const CategoryScreen());
      case test:     return _go(TestScreen(questionSet: s.arguments as QuestionSet));
      case result:   return _go(ResultScreen(result: s.arguments as TestResult));
      default:       return _go(const SplashScreen());
    }
  }

  static MaterialPageRoute _go(Widget w) => MaterialPageRoute(builder: (_) => w);
}