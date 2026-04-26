import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help Center'), backgroundColor: Colors.transparent, elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Common Questions', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _helpTile('How to create a quiz?', 'Click the "Create Quiz" button on the home screen and follow the steps.'),
          _helpTile('How to join a room?', 'Use the "Join Quiz" button and enter the Room ID or scan the QR code.'),
          _helpTile('What is Exam Mode?', 'Exam mode prevents participants from leaving the app during the quiz.'),
          _helpTile('Can I use AI to generate quizzes?', 'Yes! Just provide a document or link in the creation screen.'),
        ],
      ),
    );
  }

  Widget _helpTile(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.cyanAccent)),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: const TextStyle(color: Colors.white70)),
        )
      ],
    );
  }
}
