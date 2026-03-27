// result_screen.dart
class ResultScreen extends StatelessWidget {
  final TestResult result;
  // Shows: total score, pass/fail threshold (65% for JFT),
  // time taken, per-category breakdown, and answer review
  
  bool get isPassed => result.percentage >= 65.0;

  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        ScoreCircle(percentage: result.percentage, passed: isPassed),
        CategoryBreakdown(categoryScores: result.byCategory),
        AnswerReviewList(questions: result.questions, answers: result.answers),
      ]),
    );
  }
}