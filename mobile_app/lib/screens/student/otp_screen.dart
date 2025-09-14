// screens/student/otp_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/snackbar_helper.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
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
      setState(() => _isLoading = false);
      return;
    }
    try {
      final result = await _apiService.markAttendance(_otpController.text, token);
      final message = result['message'] ?? 'Attendance marked successfully!';
      showSnackBar(context, message);
      _otpController.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Enter the OTP from your teacher',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                          onPressed: _markAttendance,
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Mark My Attendance'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}