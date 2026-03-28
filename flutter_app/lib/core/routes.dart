import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';  // Add other screens as needed

class AppRoutes {
  static const String splash = '/splash';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      // Add cases: case login: return ...;
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Not Found'))),
        );
    }
  }
}
