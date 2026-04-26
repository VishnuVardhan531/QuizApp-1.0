import 'package:flutter/material.dart';

class QuizQuestion {
  String questionText;
  String type; // 'multiple_choice', 'true_false', etc.
  List<String> options;
  int correctAnswerIndex;
  List<int> correctAnswerIndices; // for multiselection
  String? imagePath;
  int timeLimit; // in seconds
  int points;
  bool multiselect;

  QuizQuestion({
    this.questionText = '',
    this.type = 'multiple_choice',
    List<String>? options,
    this.correctAnswerIndex = 0,
    List<int>? correctAnswerIndices,
    this.imagePath,
    this.timeLimit = 20,
    this.points = 100,
    this.multiselect = false,
  })  : options = options ?? ['', '', '', ''],
        correctAnswerIndices =
            correctAnswerIndices ?? [0];

  QuizQuestion clone() {
    return QuizQuestion(
      questionText: questionText,
      type: type,
      options: List.from(options),
      correctAnswerIndex: correctAnswerIndex,
      correctAnswerIndices: List.from(correctAnswerIndices),
      imagePath: imagePath,
      timeLimit: timeLimit,
      points: points,
      multiselect: multiselect,
    );
  }

  bool isCorrect(int index) {
    if (multiselect) return correctAnswerIndices.contains(index);
    return correctAnswerIndex == index;
  }

  void toggleCorrect(int index) {
    if (multiselect) {
      if (correctAnswerIndices.contains(index)) {
        correctAnswerIndices.remove(index);
      } else {
        correctAnswerIndices.add(index);
      }
    } else {
      correctAnswerIndex = index;
      correctAnswerIndices = [index];
    }
  }
}

class QuizProvider with ChangeNotifier {
  String title = '';
  String description = '';
  String visibility = 'public';
  List<QuizQuestion> questions = [];
  int currentQuestionIndex = 0;

  void addQuestion() {
    questions.add(QuizQuestion());
    notifyListeners();
  }

  void duplicateQuestion(int index) {
    if (index >= 0 && index < questions.length) {
      questions.insert(index + 1, questions[index].clone());
      notifyListeners();
    }
  }

  void deleteQuestion(int index) {
    if (questions.length > 1) {
      questions.removeAt(index);
      if (currentQuestionIndex >= questions.length) {
        currentQuestionIndex = questions.length - 1;
      }
    } else {
      questions[0] = QuizQuestion();
    }
    notifyListeners();
  }

  void updateQuestion(int index, QuizQuestion newQuestion) {
    if (index >= 0 && index < questions.length) {
      questions[index] = newQuestion;
      notifyListeners();
    }
  }

  void setQuizDetails(String t, String d, String v) {
    title = t;
    description = d;
    visibility = v;
    notifyListeners();
  }

  void reorderQuestion(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex--;
    final q = questions.removeAt(oldIndex);
    questions.insert(newIndex, q);
    notifyListeners();
  }
}
