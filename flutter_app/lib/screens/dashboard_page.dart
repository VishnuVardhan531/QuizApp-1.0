import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/socket_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    // Mock leaderboards if empty
    final displayData = socketService.leaderboard.isNotEmpty 
        ? socketService.leaderboard 
        : [
            {'value': 'Player One', 'score': 1200},
            {'value': 'Player Two', 'score': 850},
            {'value': 'Player Three', 'score': 600},
          ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      appBar: AppBar(
        title: const Text('Live Status', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard(displayData.length),
            const SizedBox(height: 32),
            const Text('Sub-second Leaderboard', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: displayData.length,
                itemBuilder: (context, index) {
                  final entry = displayData[index];
                  return _buildParticipantTile(index + 1, entry['value'], entry['score']);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(int count) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Participants', style: TextStyle(color: Colors.white70)),
              Text('$count', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          const Icon(Icons.flash_on, size: 48, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildParticipantTile(int rank, String name, dynamic score) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: rank <= 3 ? Colors.amber : Colors.white12,
            child: Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
          Text('$score pts', style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
