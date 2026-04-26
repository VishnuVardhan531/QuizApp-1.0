import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';

// ─────────────────────────────────────────────────────────────
// Screen 3: Question Type Selector
// ─────────────────────────────────────────────────────────────
class QuestionTypeSelector extends StatelessWidget {
  const QuestionTypeSelector({super.key});

  static const List<Map<String, dynamic>> _types = [
    {
      'id': 'multiple_choice',
      'label': 'Quiz',
      'desc': 'Classic multiple choice',
      'icon': Icons.quiz,
      'grad': [Color(0xFF6A11CB), Color(0xFF2575FC)],
    },
    {
      'id': 'true_false',
      'label': 'True / False',
      'desc': 'Binary answer',
      'icon': Icons.check_circle_outline,
      'grad': [Color(0xFF11998E), Color(0xFF38EF7D)],
    },
    {
      'id': 'type_answer',
      'label': 'Type Answer',
      'desc': 'Open text field',
      'icon': Icons.keyboard_alt_outlined,
      'grad': [Color(0xFFF37335), Color(0xFFFDA085)],
    },
    {
      'id': 'slider',
      'label': 'Slider',
      'desc': 'Numeric range',
      'icon': Icons.tune,
      'grad': [Color(0xFF2575FC), Color(0xFF6A11CB)],
    },
    {
      'id': 'puzzle',
      'label': 'Puzzle',
      'desc': 'Arrange the pieces',
      'icon': Icons.extension_outlined,
      'grad': [Color(0xFFE94057), Color(0xFFFF6B6B)],
    },
    {
      'id': 'audio',
      'label': 'Audio',
      'desc': 'Sound clip question',
      'icon': Icons.headset_mic_outlined,
      'grad': [Color(0xFF9B59B6), Color(0xFF8E44AD)],
    },
    {
      'id': 'poll',
      'label': 'Poll',
      'desc': 'No right answer',
      'icon': Icons.bar_chart_rounded,
      'grad': [Color(0xFF11998E), Color(0xFF2575FC)],
    },
    {
      'id': 'open_ended',
      'label': 'Open Ended',
      'desc': 'Free text response',
      'icon': Icons.short_text_rounded,
      'grad': [Color(0xFFE94057), Color(0xFF6A11CB)],
    },
    {
      'id': 'word_cloud',
      'label': 'Word Cloud',
      'desc': 'Crowd-sourced words',
      'icon': Icons.cloud_queue_rounded,
      'grad': [Color(0xFF2575FC), Color(0xFF11998E)],
    },
    {
      'id': 'brainstorm',
      'label': 'Brainstorm',
      'desc': 'Idea generation',
      'icon': Icons.lightbulb_outlined,
      'grad': [Color(0xFFF37335), Color(0xFFE94057)],
    },
    {
      'id': 'coding',
      'label': 'Coding',
      'desc': 'Code challenge',
      'icon': Icons.code_rounded,
      'grad': [Color(0xFF6A11CB), Color(0xFFE94057)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final quiz = context.read<QuizProvider>();
    final currentType = quiz.questions[quiz.currentQuestionIndex].type;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF6A11CB), size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question Type',
              style: GoogleFonts.outfit(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Choose how participants will answer',
              style: GoogleFonts.outfit(
                color: Colors.black38,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.1,
        ),
        itemCount: _types.length,
        itemBuilder: (context, index) {
          final type = _types[index];
          final isSelected = currentType == type['id'];
          final grads = type['grad'] as List<Color>;

          return GestureDetector(
            onTap: () {
              quiz.questions[quiz.currentQuestionIndex].type =
                  type['id'] as String;
              Navigator.pop(context);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: grads,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.black.withOpacity(0.08),
                  width: isSelected ? 0 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: grads.first.withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        )
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
              ),
              child: Stack(
                children: [
                  // Background pattern (subtle circles for depth)
                  if (isSelected) ...[
                    Positioned(
                      right: -18,
                      top: -18,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -10,
                      bottom: -10,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                  ],
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withOpacity(0.2)
                                    : grads.first.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                type['icon'] as IconData,
                                size: 24,
                                color: isSelected ? Colors.white : grads.first,
                              ),
                            ),
                            if (isSelected)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check,
                                  size: 14,
                                  color: grads.first,
                                ),
                              ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type['label'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              type['desc'] as String,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: isSelected
                                    ? Colors.white70
                                    : Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
