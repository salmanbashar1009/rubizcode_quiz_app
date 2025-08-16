// lib/screens/quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_tex/flutter_tex.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'results_screen.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.questions.isEmpty) return const SizedBox();
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
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(opacity: animation, child: child);
            },
            child: Column(
              key: ValueKey<int>(provider.currentQuestionIndex),
              children: [
                LinearProgressIndicator(
                  value: (provider.currentQuestionIndex + 1) / provider.questions.length,
                  // color: Colors.green,
                ),
                Text('Q${provider.currentQuestionIndex + 1}/${provider.questions.length}'),
                ValueListenableBuilder<int>(
                  valueListenable: provider.timeNotifier,
                  builder: (_, time, __) => Text('Time left: $time s'),
                ),
                TeXView(
                  child: TeXViewDocument(
                    question['question'],
                    style:  TeXViewStyle(
                      contentColor: Colors.black,
                      fontStyle: TeXViewFontStyle(
                        fontSize: 20,
                      ),
                      padding: TeXViewPadding.all(10),
                    ),
                  ),
                ),
                ...List.generate(4, (i) => ListTile(
                  title: TeXView(
                    child: TeXViewDocument(
                      question['options'][i],
                      style: const TeXViewStyle(
                        padding: TeXViewPadding.all(5),
                      ),
                    ),
                  ),
                  tileColor: provider.selectedAnswers[provider.currentQuestionIndex] == i
                      ? Colors.green
                      : null,
                  onTap: provider.answerLocked ? null : () => provider.selectAnswer(i),
                )),
                if (provider.answerLocked)
                  ElevatedButton(
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
              ],
            ),
          );
        },
      ),
    );
  }
}