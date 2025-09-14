import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../api/api_service.dart';
import '../utils/snackbar_helper.dart';

class TeacherDashboardScreen extends StatefulWidget {
  const TeacherDashboardScreen({super.key});

  @override
  State<TeacherDashboardScreen> createState() => _TeacherDashboardScreenState();
}

class _TeacherDashboardScreenState extends State<TeacherDashboardScreen> {
  final ApiService _apiService = ApiService();
  String? _otp;
  int _countdown = 10;
  Timer? _timer;
  bool _isLoading = false;

  void _startTimer() {
    _countdown = 10;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown > 0) {
        setState(() => _countdown--);
      } else {
        _timer?.cancel();
        setState(() => _otp = null);
      }
    });
  }

  Future<void> _generateOtp() async {
    setState(() => _isLoading = true);
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) {
      showSnackBar(context, 'Authentication error.', isError: true);
      return;
    }
    try {
      final otp = await _apiService.generateOtp(token);
      setState(() => _otp = otp);
      _startTimer();
    } catch (e) {
      showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_otp != null) ...[
              const Text('Show this OTP to your students:', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Text(_otp!, style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, letterSpacing: 12)),
              const SizedBox(height: 20),
              Text('Expires in $_countdown seconds', style: const TextStyle(fontSize: 18, color: Colors.red)),
            ] else ...[
              if (_isLoading)
                const CircularProgressIndicator()
              else
                ElevatedButton(
                  onPressed: _generateOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 25),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Generate OTP', style: TextStyle(fontSize: 22)),
                ),
            ],
          ],
        ),
      ),
    );
  }
}