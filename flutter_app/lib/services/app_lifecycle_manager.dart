import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/socket_service.dart';

class AppLifecycleManager extends StatefulWidget {
  final Widget child;
  final String userName;
  final bool isExamMode;

  const AppLifecycleManager({
    super.key, 
    required this.child, 
    required this.userName, 
    required this.isExamMode
  });

  @override
  AppLifecycleManagerState createState() => AppLifecycleManagerState();
}

class AppLifecycleManagerState extends State<AppLifecycleManager> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.isExamMode && (state == AppLifecycleState.paused || state == AppLifecycleState.inactive)) {
      // User left the app! Trigger auto-submit
      final socketService = Provider.of<SocketService>(context, listen: false);
      socketService.notifyExamExit(widget.userName);
      
      // Optionally show a dialog or navigate to a "Submitted" screen
      print("Exam Mode Termination: User exited the app.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
