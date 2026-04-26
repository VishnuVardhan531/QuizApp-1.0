import 'package:flutter/material.dart';

class JoinQuizPage extends StatefulWidget {
  const JoinQuizPage({super.key});

  @override
  State<JoinQuizPage> createState() => _JoinQuizPageState();
}

class _JoinQuizPageState extends State<JoinQuizPage> {
  final TextEditingController _roomIdController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Quiz'), backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildScannerPlaceholder(),
            const SizedBox(height: 40),
            const Text('OR ENTER ROOM ID', style: TextStyle(color: Colors.white54, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            TextField(
              controller: _roomIdController,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
              decoration: InputDecoration(
                hintText: 'XXXXXX',
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2575FC),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  // Navigate to Lobby/Quiz with Room ID
                  Navigator.pushNamed(context, '/dashboard'); // Mock navigation
                },
                child: const Text('Join Room', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerPlaceholder() {
    return Container(
      width: double.infinity,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white12),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 60, color: Colors.blue),
              SizedBox(height: 12),
              Text('Scanning for QR Code...', style: TextStyle(color: Colors.white54)),
            ],
          ),
          // Scanner overlay corners
          _buildCorner(top: 20, left: 20),
          _buildCorner(top: 20, right: 20, isRight: true),
          _buildCorner(bottom: 20, left: 20, isBottom: true),
          _buildCorner(bottom: 20, right: 20, isBottom: true, isRight: true),
        ],
      ),
    );
  }

  Widget _buildCorner({double? top, double? bottom, double? left, double? right, bool isBottom = false, bool isRight = false}) {
    return Positioned(
      top: top, bottom: bottom, left: left, right: right,
      child: Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: !isBottom ? const BorderSide(color: Colors.blue, width: 4) : BorderSide.none,
            bottom: isBottom ? const BorderSide(color: Colors.blue, width: 4) : BorderSide.none,
            left: !isRight ? const BorderSide(color: Colors.blue, width: 4) : BorderSide.none,
            right: isRight ? const BorderSide(color: Colors.blue, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
