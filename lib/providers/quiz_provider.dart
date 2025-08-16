// lib/providers/quiz_provider.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../models/score.dart';

class QuizProvider extends ChangeNotifier {
  List<Map<String, dynamic>> categories = [];
  String? selectedCategory = 'All'; // Default to "All"
  List<Map<String, dynamic>> questions = [];
  int currentQuestionIndex = 0;
  List<int?> selectedAnswers = [];
  int score = 0;
  Timer? _timer;
  int timeLeft = 15;
  bool answerLocked = false;
  final ValueNotifier<int> timeNotifier = ValueNotifier(15);

  QuizProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final String response = await rootBundle.loadString('assets/questions.json');
      final data = json.decode(response);
      categories = (data['categories'] as List)
          .map((cat) => {
        'name': cat['name'] as String,
        'questions': List<Map<String, dynamic>>.from(cat['questions']),
      })
          .toList();
      notifyListeners();
    } catch (e) {
      // Handle JSON loading errors (e.g., file not found, malformed JSON)
      debugPrint('Error loading categories: $e');
    }
  }

  void selectCategory(String category) {
    selectedCategory = category;
    notifyListeners();
  }

  void startQuiz() {
    if (selectedCategory == null) return;
    if (selectedCategory == 'All') {
      // Combine questions from all categories
      questions = categories
          .expand((cat) => cat['questions'] as List<Map<String, dynamic>>)
          .toList();
    } else {
      questions = categories
          .firstWhere((cat) => cat['name'] == selectedCategory)['questions'];
    }
    selectedAnswers = List<int?>.filled(questions.length, null);
    currentQuestionIndex = 0;
    score = 0;
    answerLocked = false;
    startTimer();
    notifyListeners();
  }

  void startTimer() {
    timeLeft = 15;
    timeNotifier.value = 15;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      timeLeft--;
      timeNotifier.value = timeLeft;
      if (timeLeft <= 0) {
        nextQuestion();
      }
    });
  }

  void selectAnswer(int optionIndex) {
    if (answerLocked) return;
    selectedAnswers[currentQuestionIndex] = optionIndex;
    answerLocked = true;
    if (optionIndex == questions[currentQuestionIndex]['correct']) {
      score++;
    }
    notifyListeners();
  }

  void nextQuestion() {
    _timer?.cancel();
    answerLocked = false;
    if (currentQuestionIndex < questions.length - 1) {
      currentQuestionIndex++;
      startTimer();
      notifyListeners();
    }
  }

  Future<void> saveScore(String name, int finalScore) async {
    final box = Hive.box('leaderboard');
    await box.add(Score(name, finalScore));
  }
}