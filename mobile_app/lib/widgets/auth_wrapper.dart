import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../screens/student_dashboard_screen.dart';
import '../screens/teacher_dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isAuthenticated) {
      if (authProvider.userRole == 'teacher') {
        return const TeacherDashboardScreen();
      } else if (authProvider.userRole == 'student') {
        return const StudentDashboardScreen();
      }
    }
    
    return const LoginScreen();
  }
}