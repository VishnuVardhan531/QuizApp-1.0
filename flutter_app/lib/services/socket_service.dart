import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';

class SocketService with ChangeNotifier {
  late IO.Socket socket;
  String? currentRoomId;
  List<dynamic> leaderboard = [];
  bool isConnected = false;
  
  // Host Room specific state
  int participantCount = 0;
  List<dynamic> activeParticipants = [];

  void connect(String serverUrl) {
    socket = IO.io(serverUrl, 
      IO.OptionBuilder()
        .setTransports(['websocket']) // for Flutter or the latest socket.io
        .disableAutoConnect()  
        .build()
    );

    socket.connect();

    socket.onConnect((_) {
      isConnected = true;
      notifyListeners();
      print('Connected to Socket Server');
    });

    socket.on('leaderboard_update', (data) {
      leaderboard = data;
      notifyListeners();
    });

    socket.on('room_created', (data) {
      if (data != null && data['pin'] != null) {
        currentRoomId = data['pin'];
        notifyListeners();
      }
    });

    socket.on('participant_update', (data) {
      if (data != null) {
        participantCount = data['count'] ?? 0;
        activeParticipants = data['participants'] ?? [];
        notifyListeners();
      }
    });
    
    socket.on('room_closed', (_) {
      currentRoomId = null;
      participantCount = 0;
      activeParticipants = [];
      notifyListeners();
    });

    socket.onDisconnect((_) {
      isConnected = false;
      notifyListeners();
    });
  }

  void createHostRoom(String quizId, int limit, String hostName) {
    socket.emit('host_quiz', {
      'quizId': quizId,
      'limit': limit,
      'hostName': hostName,
    });
  }

  void closeHostRoom() {
    if (currentRoomId != null) {
      socket.emit('close_room', { 'roomId': currentRoomId });
      currentRoomId = null;
      activeParticipants = [];
      participantCount = 0;
      notifyListeners();
    }
  }

  void joinRoom(String roomId, String userName) {
    currentRoomId = roomId;
    socket.emit('join_room', { 'roomId': roomId, 'userName': userName });
  }

  void submitAnswer(String userName, dynamic answer, int score) {
    if (currentRoomId != null) {
      socket.emit('submit_answer', {
        'roomId': currentRoomId,
        'userName': userName,
        'answer': answer,
        'score': score,
      });
    }
  }

  void notifyExamExit(String userName) {
    if (currentRoomId != null) {
      socket.emit('exam_mode_exit', {
        'roomId': currentRoomId,
        'userName': userName,
      });
    }
  }
}
