import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'services/socket_service.dart';
import 'providers/quiz_provider.dart';
import 'screens/login_page.dart';
import 'screens/signin_page.dart';
import 'screens/home_page.dart';
import 'screens/profile_page.dart';
import 'screens/dashboard_page.dart';
import 'screens/settings_page.dart';
import 'screens/help_page.dart';
import 'screens/contact_us_page.dart';
import 'screens/create_quiz_page.dart';
import 'screens/quiz_details_page.dart';
import 'screens/question_creation_page.dart';
import 'screens/question_type_selector.dart';
import 'screens/join_quiz_page.dart';
import 'screens/host_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocketService()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
      ],
      child: const QuizApp(),
    ),
  );
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuizApp Premium',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6A11CB),
        scaffoldBackgroundColor: const Color(0xFF0F0F1A),
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6A11CB),
          secondary: Color(0xFF2575FC),
          surface: Color(0xFF1E1E2E),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignInPage(),
        '/home': (context) => const HomePage(),
        '/profile': (context) => const ProfilePage(),
        '/dashboard': (context) => const DashboardPage(),
        '/settings': (context) => const SettingsPage(),
        '/help': (context) => const HelpPage(),
        '/contact': (context) => const ContactUsPage(),
        '/create-quiz': (context) => const CreateQuizPage(),
        '/quiz-details': (context) => const QuizDetailsPage(),
        '/question-creation': (context) => const QuestionCreationPage(),
        '/type-selector': (context) => const QuestionTypeSelector(),
        '/join-quiz': (context) => const JoinQuizPage(),
        '/host': (context) => const HostPage(),
      },
    );
  }
}
