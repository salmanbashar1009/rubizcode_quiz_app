// lib/screens/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'results_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  /// Build question (supports text + LaTeX + optional text_after)
  Widget _buildQuestion(Map<String, dynamic> question) {
    final text = question['text'] ?? '';
    final latex = question['latex'] ?? '';
    final textAfter = question['text_after'] ?? '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (text.isNotEmpty)
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        if (latex.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Math.tex(
              latex,
              textStyle: const TextStyle(fontSize: 16),
              onErrorFallback: (e) {
                debugPrint('Math.tex error (question): $e');
                return Text(latex, style: const TextStyle(fontSize: 16));
              },
            ),
          ),
        if (textAfter.isNotEmpty)
          Text(
            textAfter,
            style: const TextStyle(fontSize: 16),
          ),
      ],
    );
  }

  /// Build option (supports text + LaTeX)
  Widget _buildOption(Map<String, dynamic> option) {
    final String text = option['text'] ?? '';
    final String latex = option['latex'] ?? '';

    return Row(
      children: [
        if (text.isNotEmpty)
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        if (latex.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Math.tex(
              latex,
              textStyle: const TextStyle(fontSize: 16),
              onErrorFallback: (e) {
                debugPrint('Math.tex error (option): $e');
                return Text(latex, style: const TextStyle(fontSize: 16));
              },
            ),
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
          debugPrint('Rendering question: $question');

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
                  value: (provider.currentQuestionIndex + 1) /
                      provider.questions.length,
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
                    child: Center(child: _buildQuestion(question)),
                  ),
                ),
                // Options rendering
                Expanded(
                  flex: 2,
                  child: ListView.builder(
                    itemCount: (question['options'] as List).length,
                    itemBuilder: (context, i) {
                      final option =
                      question['options']?[i] as Map<String, dynamic>?;

                      if (option == null) {
                        return const ListTile(
                          title: Text('Invalid option'),
                        );
                      }

                      return ListTile(
                        title: _buildOption(option),
                        tileColor: provider.selectedAnswers[
                        provider.currentQuestionIndex] ==
                            i
                            ? Colors.green.withAlpha(100)
                            : null,
                        onTap: provider.answerLocked
                            ? null
                            : () => provider.selectAnswer(i),
                      );
                    },
                  ),
                ),
                if (provider.answerLocked)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed:
                      provider.currentQuestionIndex <
                          provider.questions.length - 1
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
