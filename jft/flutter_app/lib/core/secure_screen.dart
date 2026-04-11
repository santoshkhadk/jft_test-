import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SecureScreen extends StatefulWidget {
  final Widget child;
  const SecureScreen({super.key, required this.child});
  @override
  State<SecureScreen> createState() => _SecureScreenState();
}

class _SecureScreenState extends State<SecureScreen> with WidgetsBindingObserver {
  static const _ch = MethodChannel('com.jft.mocktest/secure');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ch.invokeMethod('enable').catchError((_) {});
  }

  @override
  void dispose() {
    _ch.invokeMethod('disable').catchError((_) {});
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _ch.invokeMethod('enable').catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}