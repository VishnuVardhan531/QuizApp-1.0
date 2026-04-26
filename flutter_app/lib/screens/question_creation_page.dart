import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';

// ─────────────────────────────────────────────────────────────
// Screen 2: Question Editor
// ─────────────────────────────────────────────────────────────
class QuestionCreationPage extends StatefulWidget {
  const QuestionCreationPage({super.key});

  @override
  State<QuestionCreationPage> createState() => _QuestionCreationPageState();
}

class _QuestionCreationPageState extends State<QuestionCreationPage>
    with SingleTickerProviderStateMixin {
  late QuizQuestion _q;
  bool _isInit = true;
  late AnimationController _saveAnim;
  late Animation<double> _saveScale;

  // ── 4 persistent controllers for answer options (A, B, C, D) ──
  final List<TextEditingController> _answerCtrls = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  final List<int> _timeOptions = [10, 20, 30, 60, 90, 120];
  final List<int> _pointsOptions = [10, 50, 100, 200, 500];

  // Four answer slot colors (A, B, C, D)
  static const List<Color> _slotColors = [
    Color(0xFFE94057), // A — Red
    Color(0xFF2575FC), // B — Blue
    Color(0xFF11998E), // C — Green
    Color(0xFFF37335), // D — Orange
  ];
  static const List<String> _slotLabels = ['A', 'B', 'C', 'D'];

  @override
  void initState() {
    super.initState();
    _saveAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );
    _saveScale = _saveAnim;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final quiz = context.read<QuizProvider>();
      _q = quiz.questions[quiz.currentQuestionIndex].clone();
      // Initialise answer controllers from the cloned question data
      for (int i = 0; i < 4; i++) {
        _answerCtrls[i].text = _q.options.length > i ? _q.options[i] : '';
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _saveAnim.dispose();
    for (final c in _answerCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _q.imagePath = picked.path);
  }

  Future<int?> _showCustomInputDialog(String title, String unit,
      {int maxVal = 99999}) async {
    final ctrl = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(title,
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Enter $unit',
            suffixText: unit,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A11CB),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              final v = int.tryParse(ctrl.text);
              if (v != null && v > 0 && v <= maxVal) {
                Navigator.pop(ctx, v);
              } else {
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                    content: Text('Enter a value between 1 and $maxVal')));
              }
            },
            child: const Text('OK',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Time picker chip ──
  Widget _buildTimeChip() {
    return GestureDetector(
      onTap: () async {
        final picked = await showModalBottomSheet<int>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _PickerSheet<int>(
            title: '⏱  Select Time',
            values: [..._timeOptions, -1],
            labelBuilder: (v) => v == -1 ? 'Custom...' : '${v}s',
            accentColor: const Color(0xFF6A11CB),
          ),
        );
        if (picked == -1) {
          final custom = await _showCustomInputDialog(
              'Custom Time', 'seconds', maxVal: 3600);
          if (custom != null) setState(() => _q.timeLimit = custom);
        } else if (picked != null) {
          setState(() => _q.timeLimit = picked);
        }
      },
      child: _infoChip(
        icon: Icons.hourglass_empty,
        label: '${_q.timeLimit}s',
        color: const Color(0xFF6A11CB),
      ),
    );
  }

  // ── Points picker chip ──
  Widget _buildPointsChip() {
    return GestureDetector(
      onTap: () async {
        final picked = await showModalBottomSheet<int>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _PickerSheet<int>(
            title: '⭐  Select Points',
            values: [..._pointsOptions, -1],
            labelBuilder: (v) => v == -1 ? 'Custom...' : '$v pts',
            accentColor: Colors.amber,
          ),
        );
        if (picked == -1) {
          final custom = await _showCustomInputDialog(
              'Custom Points', 'pts', maxVal: 10000);
          if (custom != null) setState(() => _q.points = custom);
        } else if (picked != null) {
          setState(() => _q.points = picked);
        }
      },
      child: _infoChip(
        icon: Icons.star,
        iconColor: Colors.amber,
        label: '${_q.points} pts',
        color: Colors.amber,
      ),
    );
  }

  Widget _infoChip({
    required IconData icon,
    required String label,
    required Color color,
    Color? iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: iconColor ?? color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _OptionsSheet(
        currentQuestion: _q,
        onDelete: () {
          final quiz = context.read<QuizProvider>();
          quiz.deleteQuestion(quiz.currentQuestionIndex);
          Navigator.pop(context); // close sheet
          Navigator.pop(context); // go back to list
        },
        onDuplicate: () {
          final quiz = context.read<QuizProvider>();
          // Save current before duplicating
          quiz.updateQuestion(quiz.currentQuestionIndex, _q);
          quiz.duplicateQuestion(quiz.currentQuestionIndex);
          Navigator.pop(context); // close sheet
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(children: [
                const Icon(Icons.file_copy, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Question duplicated!', style: GoogleFonts.outfit()),
              ]),
              backgroundColor: const Color(0xFF6A11CB),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          );
        },
        onChangePoints: () async {
          Navigator.pop(context);
          final custom = await _showCustomInputDialog(
              'Change Points', 'pts', maxVal: 10000);
          if (custom != null) setState(() => _q.points = custom);
        },
        onToggleMultiselect: () {
          Navigator.pop(context);
          setState(() => _q.multiselect = !_q.multiselect);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
              _q.multiselect
                  ? 'Multiselect ON — mark multiple correct answers'
                  : 'Multiselect OFF',
              style: GoogleFonts.outfit(),
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2575FC),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ));
        },
        onPreview: () {
          Navigator.pop(context);
          _showPreviewDialog();
        },
      ),
    );
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Preview', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _q.questionText.isEmpty ? '(No question text)' : _q.questionText,
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            ..._q.options.asMap().entries.map((e) {
              final isCorrect = _q.isCorrect(e.key);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? const Color(0xFF11998E).withOpacity(0.15)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCorrect
                        ? const Color(0xFF11998E)
                        : Colors.transparent,
                  ),
                ),
                child: Row(
                  children: [
                    Text(_slotLabels[e.key],
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isCorrect
                                ? const Color(0xFF11998E)
                                : Colors.black38)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        e.value.isEmpty ? '(empty)' : e.value,
                        style: GoogleFonts.outfit(color: Colors.black87),
                      ),
                    ),
                    if (isCorrect)
                      const Icon(Icons.check_circle,
                          size: 18, color: Color(0xFF11998E)),
                  ],
                ),
              );
            }),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A11CB),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── A/B/C/D Answer Tiles ──
  Widget _buildAnswerGrid() {
    return LayoutBuilder(builder: (context, constraints) {
      final itemW = (constraints.maxWidth - 12) / 2;
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        // Pass the persistent controller to each tile
        children: List.generate(4, (i) => _buildAnswerTile(i, itemW, _answerCtrls[i])),
      );
    });
  }

  Widget _buildAnswerTile(int index, double width, TextEditingController ctrl) {
    final color = _slotColors[index];
    final isCorrect = _q.isCorrect(index);

    return SizedBox(
      width: width,
      child: GestureDetector(
        onLongPress: () {
          setState(() => _q.toggleCorrect(index));
          HapticFeedback.mediumImpact();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isCorrect ? color : color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isCorrect ? color : color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: isCorrect
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: letter + correct toggle
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? Colors.white.withOpacity(0.3)
                            : color.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Center(
                        child: Text(
                          _slotLabels[index],
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isCorrect ? Colors.white : color,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() => _q.toggleCorrect(index));
                        HapticFeedback.selectionClick();
                      },
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          isCorrect
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          key: ValueKey(isCorrect),
                          size: 20,
                          color: isCorrect
                              ? Colors.white
                              : color.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Answer text field
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: TextField(
                  controller: ctrl,
                  maxLines: 2,
                  onChanged: (v) => _q.options[index] = v,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: isCorrect ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Answer ${_slotLabels[index]}...',
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 13,
                      color: isCorrect
                          ? Colors.white54
                          : color.withOpacity(0.4),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeTag() {
    const typeLabels = {
      'multiple_choice': 'Multiple Choice',
      'true_false': 'True / False',
      'type_answer': 'Type Answer',
      'slider': 'Slider',
      'puzzle': 'Puzzle',
      'audio': 'Audio',
      'poll': 'Poll',
      'open_ended': 'Open Ended',
      'word_cloud': 'Word Cloud',
      'brainstorm': 'Brainstorm',
      'coding': 'Coding',
    };
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, '/type-selector').then((_) {
        final quiz = context.read<QuizProvider>();
        setState(() => _q.type = quiz.questions[quiz.currentQuestionIndex].type);
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF6A11CB).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF6A11CB).withOpacity(0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.category_outlined,
                size: 14, color: Color(0xFF6A11CB)),
            const SizedBox(width: 6),
            Text(
              typeLabels[_q.type] ?? _q.type,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: const Color(0xFF6A11CB),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down,
                size: 16, color: Color(0xFF6A11CB)),
          ],
        ),
      ),
    );
  }

  void _saveQuestion(QuizProvider quiz) async {
    await _saveAnim.reverse();
    quiz.updateQuestion(quiz.currentQuestionIndex, _q);
    await _saveAnim.forward();
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.read<QuizProvider>();
    final total = quiz.questions.length;
    final idx = quiz.currentQuestionIndex;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: _buildAppBar(quiz, idx, total),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image / Media Area ──
                  _buildMediaArea(),
                  // ── Info bar: Q number | time chip | points chip ──
                  _buildInfoBar(idx, total),
                  // ── Question text ──
                  _buildQuestionField(),
                  // ── Type tag + multiselect badge ──
                  _buildTagRow(),
                  // ── Answers grid ──
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    child: _buildAnswerGrid(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // ── Bottom Bar: [-] [+] [Save] ──
          _buildBottomBar(quiz, idx),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
      QuizProvider quiz, int idx, int total) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new,
            color: Colors.black87, size: 20),
        onPressed: () {
          quiz.updateQuestion(idx, _q); // auto-save on back
          Navigator.pop(context);
        },
      ),
      title: Text(
        'Question ${idx + 1} of $total',
        style: GoogleFonts.outfit(
          color: Colors.black87,
          fontSize: 17,
          fontWeight: FontWeight.w700,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.black87),
          onPressed: _showOptionsSheet,
          tooltip: 'Options',
        ),
      ],
    );
  }

  Widget _buildMediaArea() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 180,
            color: const Color(0xFFEEEEF5),
            child: _q.imagePath == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                            )
                          ],
                        ),
                        child: const Icon(Icons.add_photo_alternate_outlined,
                            size: 32, color: Color(0xFF6A11CB)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add media',
                        style: GoogleFonts.outfit(
                            color: Colors.black38, fontSize: 13),
                      ),
                    ],
                  )
                : Image.file(File(_q.imagePath!),
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover),
          ),
          if (_q.imagePath != null)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => setState(() => _q.imagePath = null),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      color: Colors.white, size: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBar(int idx, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEEEEE)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F0FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Q ${idx + 1}/$total',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: const Color(0xFF6A11CB),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Spacer(),
          _buildTimeChip(),
          const SizedBox(width: 8),
          _buildPointsChip(),
        ],
      ),
    );
  }

  Widget _buildQuestionField() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      color: Colors.white,
      child: TextFormField(
        initialValue: _q.questionText,
        onChanged: (val) => _q.questionText = val,
        maxLines: null,
        textAlign: TextAlign.center,
        style: GoogleFonts.outfit(
          fontSize: 17,
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Tap to enter your question here...',
          hintStyle: GoogleFonts.outfit(
            color: const Color(0xFFBBBBBB),
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTagRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Row(
        children: [
          _buildTypeTag(),
          const SizedBox(width: 8),
          if (_q.multiselect)
            _infoChip(
              icon: Icons.checklist,
              label: 'Multiselect',
              color: const Color(0xFF2575FC),
            ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(QuizProvider quiz, int idx) {
    final total = quiz.questions.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // [-] Delete / prev
          _bottomIconBtn(
            icon: Icons.remove,
            tooltip: 'Delete question',
            onTap: () {
              if (total > 1) {
                quiz.deleteQuestion(idx);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('At least one question is required!')));
              }
            },
          ),
          const SizedBox(width: 10),
          // [+] Add new
          _bottomIconBtn(
            icon: Icons.add,
            tooltip: 'Add question',
            color: const Color(0xFF2575FC),
            onTap: () {
              quiz.updateQuestion(idx, _q);
              quiz.addQuestion();
              quiz.currentQuestionIndex = quiz.questions.length - 1;
              Navigator.pushReplacementNamed(context, '/question-creation');
            },
          ),
          const Spacer(),
          // [Save]
          ScaleTransition(
            scale: _saveScale,
            child: GestureDetector(
              onTap: () => _saveQuestion(quiz),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF11998E).withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Save',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomIconBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    String? tooltip,
  }) {
    final c = color ?? const Color(0xFFE94057);
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: c.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.withOpacity(0.3)),
          ),
          child: Icon(icon, color: c, size: 22),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Generic bottom-sheet picker
// ─────────────────────────────────────────────────────────────
class _PickerSheet<T> extends StatelessWidget {
  final String title;
  final List<T> values;
  final String Function(T) labelBuilder;
  final Color accentColor;

  const _PickerSheet({
    required this.title,
    required this.values,
    required this.labelBuilder,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 14),
          Text(title,
              style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: values.map((v) {
              final isCustom =
                  v is int && (v as int) == -1;
              return GestureDetector(
                onTap: () => Navigator.pop(context, v),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isCustom
                        ? Colors.grey.shade100
                        : accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isCustom
                          ? Colors.black12
                          : accentColor.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    labelBuilder(v),
                    style: GoogleFonts.outfit(
                      color: isCustom ? Colors.black54 : accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Screen 2 — Options Bottom Sheet (Pic 4)
// ─────────────────────────────────────────────────────────────
class _OptionsSheet extends StatelessWidget {
  final QuizQuestion currentQuestion;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate;
  final VoidCallback onChangePoints;
  final VoidCallback onToggleMultiselect;
  final VoidCallback onPreview;

  const _OptionsSheet({
    required this.currentQuestion,
    required this.onDelete,
    required this.onDuplicate,
    required this.onChangePoints,
    required this.onToggleMultiselect,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 24,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle + close
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Question Options',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.06),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, size: 18),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            const SizedBox(height: 8),
            _optionTile(
              context,
              icon: Icons.visibility_outlined,
              label: 'Preview',
              sublabel: 'See how participants view this question',
              color: const Color(0xFF2575FC),
              onTap: onPreview,
            ),
            _optionTile(
              context,
              icon: Icons.file_copy_outlined,
              label: 'Duplicate Question',
              sublabel: 'Add a copy of this question to the list',
              color: const Color(0xFF6A11CB),
              onTap: onDuplicate,
            ),
            _optionTile(
              context,
              icon: Icons.copy_all_outlined,
              label: 'Duplicate Answers',
              sublabel: 'Copy answer options to clipboard',
              color: const Color(0xFF9B59B6),
              onTap: () {
                Navigator.pop(context);
                // Future enhancement
              },
            ),
            _optionTile(
              context,
              icon: Icons.stars_outlined,
              label: 'Change Points',
              sublabel: 'Currently: ${currentQuestion.points} pts',
              color: Colors.amber.shade700,
              onTap: onChangePoints,
            ),
            _optionTile(
              context,
              icon: Icons.checklist_outlined,
              label: 'Multiselection',
              sublabel: currentQuestion.multiselect
                  ? 'Currently: ON — tap again to turn off'
                  : 'Allow multiple correct answers',
              color: const Color(0xFF11998E),
              trailingWidget: Switch(
                value: currentQuestion.multiselect,
                onChanged: (_) => onToggleMultiselect(),
                activeColor: const Color(0xFF11998E),
              ),
              onTap: onToggleMultiselect,
            ),
            _optionTile(
              context,
              icon: Icons.delete_outline,
              label: 'Delete Question',
              sublabel: 'Remove this question permanently',
              color: const Color(0xFFE94057),
              onTap: onDelete,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _optionTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
    Widget? trailingWidget,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: color == const Color(0xFFE94057)
                          ? color
                          : Colors.black87,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.black38,
                    ),
                  ),
                ],
              ),
            ),
            trailingWidget ??
                Icon(Icons.chevron_right, color: Colors.black26, size: 20),
          ],
        ),
      ),
    );
  }
}
