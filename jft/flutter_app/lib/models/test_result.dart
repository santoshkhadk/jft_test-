import 'question.dart';

class TestResult {
  final int setId;
  final String setTitle;
  final List<Question> questions;
  final Map<int, int> answers;
  final int correctCount;
  final int totalQuestions;
  final double percentage;
  final bool passed;
  final Duration timeTaken;
  final Map<String, double> categoryScores;
  final DateTime completedAt;

  const TestResult({
    required this.setId,
    required this.setTitle,
    required this.questions,
    required this.answers,
    required this.correctCount,
    required this.totalQuestions,
    required this.percentage,
    required this.passed,
    required this.timeTaken,
    required this.categoryScores,
    required this.completedAt,
  });

  static TestResult calculate({
    required int setId,
    required String setTitle,
    required List<Question> questions,
    required Map<int, int> answers,
    required Duration timeTaken,
    double passingPercentage = 65.0,
  }) {
    int correct = 0;
    final Map<String, List<bool>> cat = {};
    for (int i = 0; i < questions.length; i++) {
      final q = questions[i];
      final ok = answers[i] == q.correctOptionIndex;
      if (ok) correct++;
      cat.putIfAbsent(q.category, () => []).add(ok);
    }
    final pct = questions.isEmpty ? 0.0 : (correct / questions.length) * 100;
    final catScores = cat.map((k, v) =>
        MapEntry(k, v.isEmpty ? 0.0 : v.where((x) => x).length / v.length * 100));
    return TestResult(
      setId: setId, setTitle: setTitle, questions: questions,
      answers: answers, correctCount: correct,
      totalQuestions: questions.length, percentage: pct,
      passed: pct >= passingPercentage, timeTaken: timeTaken,
      categoryScores: catScores, completedAt: DateTime.now(),
    );
  }

  String get grade {
    if (percentage >= 90) return 'S';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 65) return 'C';
    return 'F';
  }
}