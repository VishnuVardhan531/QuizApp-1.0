import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';

class QuizDetailsPage extends StatefulWidget {
  const QuizDetailsPage({super.key});

  @override
  State<QuizDetailsPage> createState() => _QuizDetailsPageState();
}

class _QuizDetailsPageState extends State<QuizDetailsPage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _descCtrl;
  bool _isInit = true;

  // Color palette for question cards (cycles)
  static const List<Color> _cardColors = [
    Color(0xFF6A11CB),
    Color(0xFF2575FC),
    Color(0xFF11998E),
    Color(0xFFE94057),
    Color(0xFFF37335),
    Color(0xFF9B59B6),
  ];

  static final Map<String, IconData> _typeIcons = {
    'multiple_choice': Icons.quiz,
    'true_false': Icons.check_circle_outline,
    'type_answer': Icons.keyboard,
    'slider': Icons.linear_scale,
    'puzzle': Icons.extension,
    'audio': Icons.headset,
    'poll': Icons.bar_chart,
    'open_ended': Icons.short_text,
    'word_cloud': Icons.cloud_queue,
    'brainstorm': Icons.lightbulb_outline,
    'coding': Icons.code,
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final quiz = context.read<QuizProvider>();
      _titleCtrl = TextEditingController(text: quiz.title);
      _descCtrl = TextEditingController(text: quiz.description);
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _openQuestion(QuizProvider quiz, int index) {
    quiz.currentQuestionIndex = index;
    Navigator.pushNamed(context, '/question-creation')
        .then((_) => setState(() {}));
  }

  void _addAndOpenNewQuestion(QuizProvider quiz) {
    quiz.addQuestion();
    quiz.currentQuestionIndex = quiz.questions.length - 1;
    Navigator.pushNamed(context, '/question-creation')
        .then((_) => setState(() {}));
  }

  String _typeLabel(String type) {
    const labels = {
      'multiple_choice': 'QUIZ',
      'true_false': 'TRUE / FALSE',
      'type_answer': 'TYPE ANSWER',
      'slider': 'SLIDER',
      'puzzle': 'PUZZLE',
      'audio': 'AUDIO',
      'poll': 'POLL',
      'open_ended': 'OPEN ENDED',
      'word_cloud': 'WORD CLOUD',
      'brainstorm': 'BRAINSTORM',
      'coding': 'CODING',
    };
    return labels[type] ?? type.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: _buildAppBar(quiz),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailsCard(quiz),
            const SizedBox(height: 8),
            _buildQuestionsSection(quiz),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: _buildFab(quiz),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  PreferredSizeWidget _buildAppBar(QuizProvider quiz) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 22),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Create Quiz',
        style: GoogleFonts.outfit(
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: TextButton(
            onPressed: () {
              // TODO: Save to backend
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Quiz "${quiz.title.isEmpty ? "Untitled" : quiz.title}" saved!',
                        style: GoogleFonts.outfit(),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFF11998E),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF6A11CB),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Save', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(QuizProvider quiz) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Quiz Details',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFieldLabel('Quiz Title *'),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _titleCtrl,
                  hint: 'e.g. World History Quiz',
                  icon: Icons.title,
                  onChanged: (v) { quiz.title = v; },
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Description'),
                const SizedBox(height: 8),
                _buildInputField(
                  controller: _descCtrl,
                  hint: 'Optional — describe your quiz',
                  icon: Icons.notes,
                  maxLines: 2,
                  onChanged: (v) { quiz.description = v; },
                ),
                const SizedBox(height: 16),
                _buildFieldLabel('Visibility'),
                const SizedBox(height: 8),
                _buildVisibilitySelector(quiz),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    required Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: GoogleFonts.outfit(fontSize: 15, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.outfit(fontSize: 14, color: Colors.black26),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF6A11CB)),
        filled: true,
        fillColor: const Color(0xFFF5F4FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF6A11CB), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      ),
    );
  }

  Widget _buildVisibilitySelector(QuizProvider quiz) {
    return Row(
      children: ['public', 'private'].map((v) {
        final isSelected = quiz.visibility == v;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => quiz.visibility = v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(right: v == 'public' ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)])
                    : null,
                color: isSelected ? null : const Color(0xFFF5F4FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.black12,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    v == 'public' ? Icons.public : Icons.lock_outline,
                    size: 18,
                    color: isSelected ? Colors.white : Colors.black38,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    v == 'public' ? 'Public' : 'Private',
                    style: GoogleFonts.outfit(
                      color: isSelected ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionsSection(QuizProvider quiz) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Questions',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF6A11CB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${quiz.questions.length} questions',
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF6A11CB),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (quiz.questions.isEmpty) _buildEmptyState(quiz),
          if (quiz.questions.isNotEmpty)
            ...List.generate(quiz.questions.length, (i) {
              return _buildQuestionCard(quiz, i);
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyState(QuizProvider quiz) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black12,
          style: BorderStyle.solid,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6A11CB).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.quiz_outlined,
                size: 36, color: Color(0xFF6A11CB)),
          ),
          const SizedBox(height: 12),
          Text(
            'No questions yet',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Tap the button below to add your first question',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 13, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuizProvider quiz, int index) {
    final q = quiz.questions[index];
    final color = _cardColors[index % _cardColors.length];
    final icon = _typeIcons[q.type] ?? Icons.quiz;
    final label = _typeLabel(q.type);
    final hasText = q.questionText.isNotEmpty;

    return GestureDetector(
      onTap: () => _openQuestion(quiz, index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            // Color accent bar
            Container(
              width: 5,
              height: 72,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            // Question number badge
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasText ? q.questionText : 'Tap to enter question...',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: hasText ? Colors.black87 : Colors.black26,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(icon, size: 13, color: color),
                        const SizedBox(width: 4),
                        Text(
                          label,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.hourglass_empty, size: 12, color: Colors.black38),
                        const SizedBox(width: 2),
                        Text(
                          '${q.timeLimit}s',
                          style: GoogleFonts.outfit(fontSize: 11, color: Colors.black38),
                        ),
                        const SizedBox(width: 10),
                        Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          '${q.points}',
                          style: GoogleFonts.outfit(fontSize: 11, color: Colors.black38),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Trailing action
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right,
                  color: color.withOpacity(0.5), size: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFab(QuizProvider quiz) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _addAndOpenNewQuestion(quiz),
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6A11CB).withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add_circle_outline,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    'Add Question',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
