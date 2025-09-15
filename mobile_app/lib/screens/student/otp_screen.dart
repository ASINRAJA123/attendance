// screens/student/otp_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/snackbar_helper.dart';
import 'package:flutter/services.dart'; // For input formatters

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
    FocusScope.of(context).unfocus();
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
    } catch (e) {
      showSnackBar(context, e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Icon and Header
                Icon(
                  Icons.pin_outlined,
                  size: 48,
                  color: theme.primaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Mark Your Attendance',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code provided by your teacher.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // 2. Themed OTP Input
                TextField(
                  controller: _otpController,
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 16,
                    color: theme.primaryColor,
                  ),
                  decoration: const InputDecoration(
                    counterText: '',
                    hintText: '• • • • • •',
                    hintStyle: TextStyle(letterSpacing: 16),
                  ),
                ),
                const SizedBox(height: 32),

                // 3. Animated Submission Button
                SizedBox(
                  width: double.infinity,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            key: const ValueKey('button'),
                            onPressed: _markAttendance,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('Submit Attendance'),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}