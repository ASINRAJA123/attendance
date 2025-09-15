// screens/teacher/teacher_otp_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../api/api_service.dart';
import '../../utils/snackbar_helper.dart';

class TeacherOtpScreen extends StatefulWidget {
  const TeacherOtpScreen({super.key});

  @override
  State<TeacherOtpScreen> createState() => _TeacherOtpScreenState();
}

class _TeacherOtpScreenState extends State<TeacherOtpScreen> {
  final ApiService _apiService = ApiService();

  final List<String> _periods = [
    '09:00 AM - 10:00 AM', '10:00 AM - 11:00 AM', '11:00 AM - 12:00 PM',
    '01:00 PM - 02:00 PM', '02:00 PM - 03:00 PM',
  ];
  String? _selectedPeriod;

  String? _otp;
  int _countdown = 60; // Increased to 60 seconds for practicality
  Timer? _timer;
  bool _isLoading = false;

  void _startTimer() {
    _countdown = 60;
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
          _selectedPeriod = null;
        });
      }
    });
  }

  Future<void> _generateOtp() async {
    if (_selectedPeriod == null) {
      showSnackBar(context, 'Please select a period.', isError: true);
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
      final otp = await _apiService.generateOtp(_selectedPeriod!, token);
      setState(() => _otp = otp);
      _startTimer();
      HapticFeedback.lightImpact(); // Give user feedback
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
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: _otp == null
            ? _buildOtpGenerationCard(theme, primaryColor)
            : _buildOtpDisplayCard(theme, primaryColor),
      ),
    );
  }

  // Widget for the OTP Generation State
  Widget _buildOtpGenerationCard(ThemeData theme, Color primaryColor) {
    return Card(
      key: const ValueKey('generate'),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Generate New OTP', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Select a period to generate a one-time password for student attendance.',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const Divider(height: 32),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: _periods.map((period) {
                final isSelected = _selectedPeriod == period;
                return ChoiceChip(
                  label: Text(period),
                  selected: isSelected,
                  onSelected: (selected) => setState(() => _selectedPeriod = selected ? period : null),
                  selectedColor: primaryColor,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                  pressElevation: 5.0,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _selectedPeriod != null ? _generateOtp : null,
                      icon: const Icon(Icons.vpn_key_outlined),
                      label: const Text('Generate OTP'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for the OTP Display State
  Widget _buildOtpDisplayCard(ThemeData theme, Color primaryColor) {
    final seconds = (_countdown % 60).toString().padLeft(2, '0');

    return Card(
      key: const ValueKey('display'),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text('Active OTP for $_selectedPeriod', style: theme.textTheme.titleMedium),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryColor),
              ),
              child: Text(
                _otp!,
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  letterSpacing: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.timer_outlined, color: Colors.red.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Expires in 00:$seconds',
                  style: theme.textTheme.titleMedium?.copyWith(color: Colors.red.shade700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}