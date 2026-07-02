import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/landing_screen.dart';
import 'services/session_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartStudyApp());
}

class SmartStudyApp extends StatelessWidget {
  const SmartStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartStudy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const StartupGate(),
    );
  }
}

class StartupGate extends StatefulWidget {
  const StartupGate({super.key});

  @override
  State<StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<StartupGate> {
  final _sessionService = SessionService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _sessionService.getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _StartupLoadingScreen();
        }

        final user = snapshot.data;

        if (user == null) {
          return const LandingScreen();
        }

        return HomeScreen(currentUser: user);
      },
    );
  }
}

class _StartupLoadingScreen extends StatelessWidget {
  const _StartupLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
