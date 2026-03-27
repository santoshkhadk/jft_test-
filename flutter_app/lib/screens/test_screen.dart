// test_screen.dart
class TestScreen extends StatefulWidget {
  final QuestionSet questionSet;
  const TestScreen({required this.questionSet});
  // ...
}

class _TestScreenState extends State<TestScreen> {
  late Timer _timer;
  int _secondsLeft = 3600; // 60 min, configurable per set
  int _currentIndex = 0;
  Map<int, int> _answers = {};

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (_secondsLeft == 0) {
        _timer.cancel();
        _submitTest();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  void _submitTest() {
    final result = TestResult.calculate(
      questions: widget.questionSet.questions,
      answers: _answers,
    );
    Navigator.pushReplacement(context,
      MaterialPageRoute(builder: (_) => ResultScreen(result: result)));
  }
  // ...
}