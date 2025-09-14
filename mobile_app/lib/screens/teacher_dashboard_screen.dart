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
  int _countdown = 20;
  Timer? _timer;
  bool _isLoading = false;
  List<String> _students = [];

  void _startTimer() {
    _countdown = 20;
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
        setState(() {
          _otp = null;
          _students.clear();
        });
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

  // Simulated fetch (replace with API call)
  Future<void> _fetchAttendance() async {
  if (_otp == null) return;
  final token = Provider.of<AuthProvider>(context, listen: false).token;
  if (token == null) {
    showSnackBar(context, "Authentication error", isError: true);
    return;
  }
  final students = await _apiService.getMarkedStudents(_otp!, token);
  setState(() => _students = students);
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
      body: RefreshIndicator(
        onRefresh: _fetchAttendance,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_otp != null) ...[
              const Text('Show this OTP to your students:', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Center(
                child: Text(_otp!,
                    style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold, letterSpacing: 12)),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text('Expires in $_countdown seconds',
                    style: const TextStyle(fontSize: 18, color: Colors.red)),
              ),
              const SizedBox(height: 30),
              const Text("Students who marked attendance:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (_students.isEmpty)
                const Text("No student has marked attendance yet.")
              else
                ..._students.map((s) => ListTile(
                      leading: const Icon(Icons.person, color: Colors.blue),
                      title: Text(s),
                    )),
            ] else ...[
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
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
