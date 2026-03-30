import 'dart:async';
import 'package:flutter/material.dart';
import '../core/secure_screen.dart';
import '../core/routes.dart';
import '../models/question_set.dart';
import '../models/test_result.dart';

class TestScreen extends StatefulWidget {
  final QuestionSet questionSet;
  const TestScreen({super.key, required this.questionSet});
  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  late int _secs;
  late Timer _timer;
  int _idx = 0;
  final Map<int, int> _answers = {};
  bool _submitting = false;
  late final DateTime _start;
  final _pages = PageController();

  @override
  void initState() {
    super.initState();
    _secs  = widget.questionSet.durationMinutes * 60;
    _start = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_secs <= 0) { _timer.cancel(); _submit(); }
      else setState(() => _secs--);
    });
  }

  @override
  void dispose() { _timer.cancel(); _pages.dispose(); super.dispose(); }

  void _pick(int opt) => setState(() => _answers[_idx] = opt);

  void _goTo(int i) {
    setState(() => _idx = i);
    _pages.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  Future<void> _confirmSubmit() async {
    final unanswered = widget.questionSet.questions.length - _answers.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Submit Test?'),
        content: Text(unanswered > 0
            ? '$unanswered question(s) still unanswered.'
            : 'All questions answered.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Review')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Submit')),
        ],
      ),
    );
    if (ok == true) _submit();
  }

  void _submit() {
    _timer.cancel();
    setState(() => _submitting = true);
    final result = TestResult.calculate(
      setId: widget.questionSet.id,
      setTitle: widget.questionSet.title,
      questions: widget.questionSet.questions,
      answers: _answers,
      timeTaken: DateTime.now().difference(_start),
      passingPercentage: widget.questionSet.passingPercentage,
    );
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.result, arguments: result);
  }

  String get _clock {
    final m = _secs ~/ 60, s = _secs % 60;
    return '\${m.toString().padLeft(2, '0')}:\${s.toString().padLeft(2, '0')}';
  }

  Color get _clockColor =>
      _secs < 300 ? Colors.red : _secs < 600 ? Colors.orange : Colors.green;

  @override
  Widget build(BuildContext context) {
    final qs = widget.questionSet.questions;
    return SecureScreen(
      child: WillPopScope(
        onWillPop: () async {
          final exit = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Exit Test?'),
              content: const Text('Progress will be lost.'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Stay')),
                TextButton(style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => Navigator.pop(context, true), child: const Text('Exit')),
              ],
            ),
          );
          return exit ?? false;
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(widget.questionSet.title, style: const TextStyle(fontSize: 15)),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: _clockColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _clockColor)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.timer, size: 14, color: _clockColor),
                  const SizedBox(width: 4),
                  Text(_clock, style: TextStyle(color: _clockColor, fontWeight: FontWeight.bold)),
                ]),
              ),
            ],
          ),
          body: Column(children: [
            LinearProgressIndicator(
                value: (_idx + 1) / qs.length,
                color: const Color(0xFFE53935),
                backgroundColor: Colors.grey.shade200, minHeight: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('\${_idx + 1} / \${qs.length}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                Text('\${_answers.length} answered', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ]),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pages,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: qs.length,
                onPageChanged: (i) => setState(() => _idx = i),
                itemBuilder: (_, i) {
                  final q   = qs[i];
                  final sel = _answers[i];
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (q.questionTextJa != null)
                            Text(q.questionTextJa!,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          Text(q.questionText,
                              style: TextStyle(
                                  fontSize: q.questionTextJa != null ? 14 : 18,
                                  color: q.questionTextJa != null ? Colors.grey : null)),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(q.options.length, (oi) {
                        final picked = sel == oi;
                        return GestureDetector(
                          onTap: () => _pick(oi),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: picked ? const Color(0xFFE53935) : Colors.grey.shade300,
                                  width: picked ? 2 : 1),
                              borderRadius: BorderRadius.circular(12),
                              color: picked ? const Color(0xFFFFEBEE) : Theme.of(context).cardColor,
                            ),
                            child: Row(children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: picked ? const Color(0xFFE53935) : Colors.grey.shade200,
                                child: Text(String.fromCharCode(65 + oi),
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,
                                        color: picked ? Colors.white : Colors.grey)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(q.options[oi])),
                            ]),
                          ),
                        );
                      }),
                    ]),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(top: BorderSide(color: Colors.grey.shade200))),
              child: Row(children: [
                if (_idx > 0) ...[
                  Expanded(child: OutlinedButton(
                      onPressed: () => _goTo(_idx - 1), child: const Text('← Prev'))),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _submitting ? null
                        : () => _idx == qs.length - 1 ? _confirmSubmit() : _goTo(_idx + 1),
                    child: _submitting
                        ? const SizedBox(height: 18, width: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(_idx == qs.length - 1 ? 'Submit' : 'Next →'),
                  ),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}