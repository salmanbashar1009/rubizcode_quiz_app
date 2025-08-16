// test/score_test.dart
import 'package:flutter_test/flutter_test.dart';

int calculateScore(List<int?> selectedAnswers, List<Map<String, dynamic>> questions) {
  int score = 0;
  for (int i = 0; i < selectedAnswers.length; i++) {
    if (selectedAnswers[i] == questions[i]['correct']) {
      score++;
    }
  }
  return score;
}

void main() {
  test('Calculates score correctly', () {
    final questions = [
      {'correct': 0},
      {'correct': 1},
      {'correct': 2},
    ];
    final selected = [0, null, 2];
    expect(calculateScore(selected, questions), 2);
  });

  test('Handles all wrong', () {
    final questions = [
      {'correct': 0},
      {'correct': 1},
    ];
    final selected = [1, 0];
    expect(calculateScore(selected, questions), 0);
  });
}