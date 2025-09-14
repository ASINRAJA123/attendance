import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/student_dashboard_screen.dart';
import '../screens/teacher_dashboard_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final loggedIn = await authProvider.tryAutoLogin();
    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (loggedIn) {
      // Explicitly navigate based on role
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (authProvider.userRole == 'teacher') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const TeacherDashboardScreen()),
          );
        } else if (authProvider.userRole == 'student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const StudentDashboardScreen()),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const LoginScreen();
  }
}
