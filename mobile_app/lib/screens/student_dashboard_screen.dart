import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_service.dart';
import '../providers/auth_provider.dart';
import '../utils/snackbar_helper.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final _otpController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _markAttendance() async {
    if (_otpController.text.length != 6) {
      showSnackBar(context, 'Please enter a valid 6-digit OTP.', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) {
      showSnackBar(context, 'Authentication error.', isError: true);
      return;
    }
    try {
      final message = await _apiService.markAttendance(_otpController.text, token);
      showSnackBar(context, message);
      _otpController.clear();
      FocusScope.of(context).unfocus(); // Dismiss keyboard
    } catch (e) {
      showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${authProvider.user?.name ?? ''}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authProvider.logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Enter the OTP from your teacher', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            TextField(
              controller: _otpController,
              maxLength: 6,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, letterSpacing: 16),
              decoration: const InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
                hintText: '______',
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _markAttendance,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text('Mark My Attendance'),
                  ),
          ],
        ),
      ),
    );
  }
}