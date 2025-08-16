// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quiz_provider.dart';
import 'quiz_screen.dart';
import 'leaderboard_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz App')),
      body: FutureBuilder<void>(
        future: Provider.of<QuizProvider>(context, listen: false).loadCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading categories'));
          }
          return Consumer<QuizProvider>(
            builder: (context, provider, child) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Select Category:'),
                    DropdownButton<String>(
                      value: provider.selectedCategory,
                      onChanged: (value) => provider.selectCategory(value!),
                      items: [
                        const DropdownMenuItem<String>(
                          value: 'All',
                          child: Text('All'),
                        ),
                        ...provider.categories.map((cat) => DropdownMenuItem<String>(
                          value: cat['name'],
                          child: Text(cat['name']),
                        )),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: provider.selectedCategory != null
                          ? () {
                        provider.startQuiz();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const QuizScreen()),
                        );
                      }
                          : null,
                      child: const Text('Start Quiz'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LeaderboardScreen()),
                      ),
                      child: const Text('Leaderboard'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}