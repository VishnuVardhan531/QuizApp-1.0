import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/socket_service.dart';

class HostPage extends StatefulWidget {
  final String quizId;
  final int limit;

  const HostPage({super.key, required this.quizId, required this.limit});

  @override
  State<HostPage> createState() => _HostPageState();
}

class _HostPageState extends State<HostPage> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final socketService = Provider.of<SocketService>(context, listen: false);
      if (!socketService.isConnected) {
        // Mock server url fallback if not connected
        socketService.connect('http://10.0.2.2:5000'); 
      }
      socketService.createHostRoom(widget.quizId, widget.limit, 'Host Vara');
      setState(() {
        _initialized = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _closeRoom(SocketService socketService) {
    socketService.closeHostRoom();
    Navigator.pop(context); // Go back home
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    final roomId = socketService.currentRoomId;
    final int count = socketService.participantCount;

    return Scaffold(
      appBar: AppBar(
        title: Text('Live Lobby', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            // Confirm exit dialog
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: const Color(0xFF1E1E2E),
                title: Text('Close Lobby?', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                content: Text('Leaving this screen will unconditionally close the live quiz session and disconnect everyone.', style: GoogleFonts.outfit(color: Colors.white70)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _closeRoom(socketService);
                    }, 
                    child: const Text('Close Room', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F0F1A), Color(0xFF1E1E2E)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          if (!_initialized || roomId == null)
            const Center(child: CircularProgressIndicator(color: Color(0xFF2575FC)))
          else
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      Text('Scan to Join', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2575FC).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF2575FC).withOpacity(0.3)),
                        ),
                        child: Text(
                          'PIN: $roomId', 
                          style: GoogleFonts.outfit(color: const Color(0xFF2575FC), fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 4),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Glowing QR Code Container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6A11CB).withOpacity(0.3),
                              blurRadius: 40,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: QrImageView(
                          data: roomId,
                          version: QrVersions.auto,
                          size: 220.0,
                          eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF1a1a2e)),
                          dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.circle, color: Color(0xFF6A11CB)),
                        ),
                      ),
                      const SizedBox(height: 48),
                      
                      // Progress Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Waiting for participants...', style: GoogleFonts.outfit(color: Colors.white54, fontSize: 16)),
                          Text(
                            '$count / ${widget.limit}', 
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Progress Bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: widget.limit == 0 ? 0 : count / widget.limit,
                          minHeight: 12,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            count == widget.limit ? const Color(0xFF38EF7D) : const Color(0xFF2575FC),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Active Participants List
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: count == 0 
                            ? Center(
                                child: Text('Lobby is empty.', style: GoogleFonts.outfit(color: Colors.white30)),
                              )
                            : ListView.builder(
                                itemCount: socketService.activeParticipants.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle_rounded, color: Color(0xFF38EF7D), size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          socketService.activeParticipants[index].toString(),
                                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                            ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Actions row
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.redAccent,
                                side: const BorderSide(color: Colors.redAccent),
                                padding: const EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: () => _closeRoom(socketService),
                              child: Text('Close Room', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 2, // Larger width for primary action
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              onPressed: count > 0 ? () {
                                // Start Quiz Logic (Next Phase)
                                Navigator.pushNamed(context, '/dashboard'); 
                              } : null,
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: count > 0 ? const LinearGradient(
                                    colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                                  ) : null,
                                  color: count == 0 ? Colors.white12 : null,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(vertical: 18),
                                  child: Text('Start Quiz', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
