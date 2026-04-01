import 'question.dart';

class QuestionSet {
  final int id;
  final String title;
  final String titleJa;
  final String category;
  final String level;
  final int durationMinutes;
  final List<Question> questions;
  final double passingPercentage;

  const QuestionSet({
    required this.id,
    required this.title,
    required this.titleJa,
    required this.category,
    required this.level,
    required this.durationMinutes,
    required this.questions,
    this.passingPercentage = 65.0,
  });

  factory QuestionSet.fromJson(Map<String, dynamic> j) => QuestionSet(
        id:             j['id'] as int,
        title:          j['title'] as String,
        titleJa:        j['title_ja'] as String? ?? '',
        category:       j['category'] as String,
        level:          j['level'] as String,
        durationMinutes:j['duration_minutes'] as int,
        questions:      (j['questions'] as List)
            .map((q) => Question.fromJson(q as Map<String, dynamic>))
            .toList(),
        passingPercentage: (j['passing_percentage'] as num?)?.toDouble() ?? 65.0,
      );
}