// lib/screens/leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/score.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: FutureBuilder<Box>(
        future: Hive.openBox('leaderboard'),  // already open, but for safety
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final box = snapshot.data!;
            List<Score> scores = box.values.cast<Score>().toList()
              ..sort((a, b) => b.score.compareTo(a.score));
            return ListView.builder(
              itemCount: scores.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(scores[i].name),
                trailing: Text(scores[i].score.toString()),
              ),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}