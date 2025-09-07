// lib/screens/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'results_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  // Extract LaTeX content from a string (e.g., "What is \\(2 + 2\\)?" -> "2 + 2")
  String? _extractLaTeX(String text) {
    final RegExp latexRegExp = RegExp(r'\\\(.*?(?<=\\)\)|\[.*?(?<=\\])');
    final match = latexRegExp.firstMatch(text);
    if (match != null) {
      final latex = match.group(0);
      if (latex != null) {
        return latex.substring(2, latex.length - 2); // Remove \\( and \\)
      }
    }
    return null;
  }

  // Split text and LaTeX for rendering
  Widget _buildMixedContent(String text) {
    final latex = _extractLaTeX(text);
    if (latex == null) {
      return Text(
        text.isEmpty ? 'Invalid question' : text,
        style: const TextStyle(fontSize: 16),
        textAlign: TextAlign.center,
      );
    }
    final plainText = text.replaceAll(RegExp(r'\\\(.*?(?<=\\)\)|\[.*?(?<=\\])'), '');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (plainText.isNotEmpty)
          Text(
            plainText,
            style: const TextStyle(fontSize: 16),
          ),
        Math.tex(
          latex,
          textStyle: const TextStyle(fontSize: 16),
          onErrorFallback: (e) {
            debugPrint('Math.tex error (question): $e');
            return Text(latex, style: const TextStyle(fontSize: 16));
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.questions.isEmpty) {
            debugPrint('No questions available in provider');
            return const Center(child: Text('No questions available'));
          }
          if (provider.currentQuestionIndex >= provider.questions.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultsScreen(
                    score: provider.score,
                    total: provider.questions.length,
                  ),
                ),
              );
            });
            return const SizedBox();
          }
          final question = provider.questions[provider.currentQuestionIndex];
          debugPrint('Rendering question: ${question['question']}');
          debugPrint('Options: ${question['options']}');
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Column(
              key: ValueKey<int>(provider.currentQuestionIndex),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LinearProgressIndicator(
                  value: (provider.currentQuestionIndex + 1) / provider.questions.length,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Q${provider.currentQuestionIndex + 1}/${provider.questions.length}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: provider.timeNotifier,
                  builder: (_, time, __) => Text(
                    'Time left: $time s',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                // Question rendering
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: _buildMixedContent(question['question'] ?? 'Invalid question'),
                    ),
                  ),
                ),
                // Options rendering
                Expanded(
                  flex: 2,
                  child: ListView(
                    children: List.generate(4, (i) {
                      final option = question['options']?[i] ?? 'Invalid option';
                      return ListTile(
                        title: _buildMixedContent(option),
                        tileColor: provider.selectedAnswers[provider.currentQuestionIndex] == i
                            ? Colors.green.withOpacity(0.3)
                            : null,
                        onTap: provider.answerLocked ? null : () => provider.selectAnswer(i),
                      );
                    }),
                  ),
                ),
                if (provider.answerLocked)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: provider.currentQuestionIndex < provider.questions.length - 1
                          ? provider.nextQuestion
                          : () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResultsScreen(
                              score: provider.score,
                              total: provider.questions.length,
                            ),
                          ),
                        );
                      },
                      child: const Text('Next'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}