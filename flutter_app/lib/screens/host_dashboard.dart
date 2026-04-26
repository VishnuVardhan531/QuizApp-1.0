import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/socket_service.dart';

class HostDashboard extends StatelessWidget {
  const HostDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A), // Dark premium theme
      appBar: AppBar(
        title: const Text('Host Dashboard - Real-time', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatCard(context, socketService),
            const SizedBox(height: 24),
            const Text(
              'Live Leaderboard',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: socketService.leaderboard.length,
                itemBuilder: (context, index) {
                  final entry = socketService.leaderboard[index];
                  return _buildLeaderboardTile(index, entry);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, SocketService service) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Active Participants', style: TextStyle(color: Colors.white70)),
              Text('${service.leaderboard.length}', style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Icons.people_alt, color: Colors.white, size: 40),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(int index, dynamic entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: index < 3 ? Colors.amber : Colors.blueGrey,
            child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(entry['value'], style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          Text(
            '${entry['score']} pts',
            style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
