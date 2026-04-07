import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../core/constants.dart';
import '../core/routes.dart';
import '../services/payment_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethod _method = PaymentMethod.esewa;
  String _plan = 'full';
  bool _loading = false;

  final _plans = <String, Map<String, dynamic>>{
    'single': {'title': 'Single Attempt',  'price': AppConstants.singlePrice, 'desc': '1 test · 24-hour access',   'icon': Icons.looks_one_rounded},
    'bundle': {'title': 'Practice Bundle', 'price': AppConstants.bundlePrice, 'desc': '5 sets · 30 days',           'icon': Icons.library_books_rounded},
    'full':   {'title': 'Full Access',     'price': AppConstants.fullPrice,   'desc': 'All categories · Lifetime',  'icon': Icons.star_rounded},
  };

  Future<void> _pay() async {
    setState(() => _loading = true);
    final plan   = _plans[_plan]!;
    final amount = plan['price'] as double;

    if (_method == PaymentMethod.esewa) {
      final params = PaymentService().buildEsewaParams(
        amount: amount,
        productId: 'JFT_${_plan.toUpperCase()}',
        productName: plan['title'] as String,
      );
      if (!mounted) return;
      final status = await Navigator.push<PaymentStatus>(
          context, MaterialPageRoute(builder: (_) => _EsewaWebView(params: params)));
      _done(status);
    } else {
      final url = await PaymentService().initiateKhalti(
        amount: amount,
        orderId: 'JFT_${DateTime.now().millisecondsSinceEpoch}',
        orderName: plan['title'] as String,
      );
      if (!mounted) return;
      if (url == null) { setState(() => _loading = false); _snack('Khalti error. Retry.'); return; }
      final status = await Navigator.push<PaymentStatus>(
          context, MaterialPageRoute(builder: (_) => _KhaltiWebView(url: url)));
      _done(status);
    }
  }

  void _done(PaymentStatus? s) {
    setState(() => _loading = false);
    if (s == PaymentStatus.success) {
      Navigator.pushReplacementNamed(context, AppRoutes.category);
    } else {
      _snack('Payment not completed. Try again.');
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Unlock Access')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFE53935), Color(0xFFC62828)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(children: [
                Text('🎌', style: TextStyle(fontSize: 44)),
                SizedBox(height: 8),
                Text('One-time payment · Unlimited access',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text('No subscriptions. Pay once, test forever.',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
            ),
            const SizedBox(height: 28),
            const Text('Choose Plan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._plans.entries.map((e) => _PlanTile(
                  planKey: e.key, plan: e.value,
                  selected: _plan == e.key,
                  onTap: () => setState(() => _plan = e.key),
                )),
            const SizedBox(height: 24),
            const Text('Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _MethodChip(label: 'eSewa', color: const Color(0xFF60BB46),
                  selected: _method == PaymentMethod.esewa,
                  onTap: () => setState(() => _method = PaymentMethod.esewa))),
              const SizedBox(width: 12),
              Expanded(child: _MethodChip(label: 'Khalti', color: const Color(0xFF5C2D91),
                  selected: _method == PaymentMethod.khalti,
                  onTap: () => setState(() => _method = PaymentMethod.khalti))),
            ]),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _loading ? null : _pay,
              child: _loading
                  ? const SizedBox(height: 20, width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Pay NPR ${(_plans[_plan]!['price'] as double).toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(height: 12),
            const Center(child: Text('🔒 Secure · No recurring charges',
                style: TextStyle(color: Colors.grey, fontSize: 12))),
          ]),
        ),
      );
}

class _PlanTile extends StatelessWidget {
  final String planKey;
  final Map<String, dynamic> plan;
  final bool selected;
  final VoidCallback onTap;
  const _PlanTile({required this.planKey, required this.plan, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? const Color(0xFFE53935) : Colors.grey.shade300, width: selected ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
            color: selected ? const Color(0xFFFFEBEE) : null,
          ),
          child: Row(children: [
            Icon(plan['icon'] as IconData, color: selected ? const Color(0xFFE53935) : Colors.grey),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(plan['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(plan['desc'] as String, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ])),
            Text('Rs. ${(plan['price'] as double).toStringAsFixed(0)}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFE53935))),
          ]),
        ),
      );
}

class _MethodChip extends StatelessWidget {
  final String label; final Color color; final bool selected; final VoidCallback onTap;
  const _MethodChip({required this.label, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: selected ? color : Colors.grey.shade300, width: selected ? 2 : 1),
            borderRadius: BorderRadius.circular(12),
            color: selected ? color.withOpacity(0.1) : null,
          ),
          child: Center(child: Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,
                  color: selected ? color : Colors.grey))),
        ),
      );
}

class _EsewaWebView extends StatefulWidget {
  final Map<String, String> params;
  const _EsewaWebView({required this.params});
  @override
  State<_EsewaWebView> createState() => _EsewaWebViewState();
}

class _EsewaWebViewState extends State<_EsewaWebView> {
  late final WebViewController _ctrl;

  @override
  void initState() {
    super.initState();
    final body = widget.params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(onNavigationRequest: (r) {
        if (r.url.contains('/esewa/success')) { _verify(r.url); return NavigationDecision.prevent; }
        if (r.url.contains('/esewa/failure')) { Navigator.pop(context, PaymentStatus.failed); return NavigationDecision.prevent; }
        return NavigationDecision.navigate;
      }))
      ..loadRequest(Uri.parse(AppConstants.esewaUrl),
          method: LoadRequestMethod.post,
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: body.codeUnits as dynamic);
  }

  Future<void> _verify(String url) async {
    final data = Uri.parse(url).queryParameters['data'] ?? '';
    final status = await PaymentService().verifyEsewa(data);
    if (mounted) Navigator.pop(context, status);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('eSewa Payment')),
        body: WebViewWidget(controller: _ctrl));
}

class _KhaltiWebView extends StatefulWidget {
  final String url;
  const _KhaltiWebView({required this.url});
  @override
  State<_KhaltiWebView> createState() => _KhaltiWebViewState();
}

class _KhaltiWebViewState extends State<_KhaltiWebView> {
  late final WebViewController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(onNavigationRequest: (r) {
        if (r.url.contains('/khalti/callback')) { _verify(r.url); return NavigationDecision.prevent; }
        return NavigationDecision.navigate;
      }))
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _verify(String url) async {
    final pidx   = Uri.parse(url).queryParameters['pidx'] ?? '';
    final status = await PaymentService().verifyKhalti(pidx);
    if (mounted) Navigator.pop(context, status);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Khalti Payment')),
        body: WebViewWidget(controller: _ctrl));
}