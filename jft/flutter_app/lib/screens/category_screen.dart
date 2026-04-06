import 'package:flutter/material.dart';
import '../core/routes.dart';
import '../services/question_service.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});
  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String? _sel;
  bool _loading = false;
  List<Map<String, dynamic>> _sets = [];

  final _levels = [
    {'key': 'N5',        'label': 'N5 Beginner',  'icon': '🌱', 'color': 0xFF43A047},
    {'key': 'N4',        'label': 'N4 Elementary', 'icon': '📗', 'color': 0xFF1E88E5},
    {'key': 'JFT',       'label': 'JFT Basic',     'icon': '🎌', 'color': 0xFFE53935},
    {'key': 'vocab',     'label': 'Vocabulary',     'icon': '📖', 'color': 0xFF8E24AA},
    {'key': 'grammar',   'label': 'Grammar',        'icon': '✏️', 'color': 0xFFF4511E},
    {'key': 'reading',   'label': 'Reading',        'icon': '📄', 'color': 0xFF00897B},
    {'key': 'listening', 'label': 'Listening',      'icon': '🎧', 'color': 0xFFFFB300},
  ];

  Future<void> _pick(String key) async {
    setState(() { _sel = key; _loading = true; _sets = []; });
    final data = await QuestionService().fetchSetsByCategory(key);
    if (mounted) setState(() { _sets = data; _loading = false; });
  }

  Future<void> _start(int id) async {
    setState(() => _loading = true);
    final set = await QuestionService().fetchQuestionSet(id);
    setState(() => _loading = false);
    if (set != null && mounted) Navigator.pushNamed(context, AppRoutes.test, arguments: set);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Select Category')),
        body: Column(children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 2.6,
                  crossAxisSpacing: 10, mainAxisSpacing: 10),
              itemCount: _levels.length,
              itemBuilder: (_, i) {
                final lv  = _levels[i];
                final sel = _sel == lv['key'];
                return GestureDetector(
                  onTap: () => _pick(lv['key'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: sel ? Color(lv['color'] as int)
                                 : Color(lv['color'] as int).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(lv['color'] as int), width: sel ? 2 : 1),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Row(children: [
                      Text(lv['icon'] as String, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(lv['label'] as String,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12,
                              color: sel ? Colors.white : null))),
                    ]),
                  ),
                );
              },
            ),
          ),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_sets.isNotEmpty)
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _sets.length,
                itemBuilder: (_, i) {
                  final s = _sets[i];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: const CircleAvatar(backgroundColor: Color(0xFFFFEBEE), child: Text('📝')),
                      title: Text(s['title'] as String? ?? ''),
                      subtitle: Text('${s['duration_minutes']} min · ${s['question_count'] ?? 0} questions'),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(minimumSize: const Size(70, 36)),
                        onPressed: () => _start(s['id'] as int),
                        child: const Text('Start'),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Expanded(
              child: Center(child: Text(
                  _sel == null ? 'Select a category to begin.' : 'No sets available yet.',
                  style: const TextStyle(color: Colors.grey))),
            ),
        ]),
      );
}